#[
TODO: not portable, needs instead: `requires "compiler"`
]#
import ../compiler/[ast, idents, msgs, syntaxes, options, pathutils]
# from ../compiler/astalgo import debug
from ../compiler/renderer import renderTree

import std/[os, strformat, strutils]
import std/private/miscdollars # avoids code duplication


type
  HintStateKind* = enum
    # doc comments
    hintBackticks
    hintCodeBlocks
    hintCapitialize
    # functions
    hintFunc
    hintIsMainModule
    # testament
    hintExitcode
    hintAssert

  HintState* = object
    kind: HintStateKind
    info: tuple[file: string, line, col: int]

# code block => runnableExamples
# proc + noSideEffect => func
# assert in a test file => doAssert
# isMainModule in stdlib => recommend moving to tests/stdlib/tfoo.nim
# double backticks => single backticks
# capitalize the first letter
# lots of testament specific checks (eg exitcode: 0 usually useless)

proc initHintState(kind: HintStateKind, file: string, line, col: int): HintState =
  HintState(kind: kind, info: (file, line, col))

template add(
  tabs: var seq[HintState], kind: HintStateKind,
  conf: ConfigRef, file: string, line, col: int
) =
  tabs.add initHintState(kind, file, line, col)

proc add(tabs: var seq[HintState], kind: HintStateKind, conf: ConfigRef, n: PNode) =
  let info = n.info
  let file = conf.toFullPath(info.fileIndex)
  tabs.add(kind, conf, file, info.line.int, info.col.int)

const
  SpecialChars = {'\r', '\n', '`'}
  testsPath = "tests"

proc cleanWhenModule(hintsTable: var seq[HintState], conf: ConfigRef, n: PNode) =
  if n.len > 0 and n[0].kind == nkElifBranch:
    let son = n[0]
    if son[0].kind == nkIdent and cmpIgnoreStyle(son[0].ident.s, "isMainModule") == 0:
      hintsTable.add(hintIsMainModule, conf, n)

proc clean(conf: ConfigRef, n: PNode, hintstable: var seq[HintState]) =
  if n.comment.len != 0:
    var line = n.info.line
    var start = 0
  case n.kind
  of nkImportStmt, nkExportStmt, nkCharLit..nkUInt64Lit,
      nkFloatLit..nkFloat128Lit, nkStrLit..nkTripleStrLit:
    discard
  of nkWhenStmt:
    # Handles the most common case
    # {
    #   "kind": "nkWhenStmt",
    #   "typ": "nil",
    #   "sons": [{
    #     "kind": "nkElifBranch",
    #     "typ": "nil",
    #     "sons": [{
    #       "kind": "nkIdent",
    #       "typ": "nil",
    #       "ident": "isMainModule"
    #     }, {
    #       "kind": "nkStmtList",
    #       "typ": "nil"
    cleanWhenModule(hintsTable, conf, n)
  of nkSym:
    discard
  of nkProcDef:
    for son in n[pragmasPos]:
      if cmpIgnoreStyle(son.ident.s, "noSideEffect") == 0:
        hintsTable.add(hintFunc, conf, n)
        break
    clean(conf, n[bodyPos], hintsTable)
  of nkFuncDef:
    discard
    # debug n
    # echo n.renderTree
  of nkIdent:
    # debug n
    # echo n.renderTree
    discard
  else:
    for s in n.sons:
      clean(conf, s, hintsTable)

proc prettyPrint*(infile, outfile: string, hintsTable: var seq[HintState]) =
  # TODO: is outfile written to?
  var conf = newConfigRef()
  let fileIdx = fileInfoIdx(conf, AbsoluteFile infile)
  let f = splitFile(outfile.expandTilde)
  conf.outFile = RelativeFile f.name & f.ext
  conf.outDir = toAbsoluteDir f.dir
  var parser: Parser
  var cache = newIdentCache()

  if setupParser(parser, fileIdx, cache, conf):
    var ast = parseFile(conf.projectMainIdx, cache, conf)
    clean(conf, ast, hintsTable)
    closeParser(parser)

proc `$`(a: HintState): string =
  result = fmt"[lint] {a.kind}: "
  let loc = a.info
  result.toLocation(loc.file, loc.line, loc.col)

proc main*(fileInput, fileOutput: string) =
  # var infiles = newSeq[string]()
  # var outfiles = newSeq[string]()

  # var backup = false
    # when `on`, create a backup file of input in case
    # `prettyPrint` could over-write it (note that the backup may happen even
    # if input is not actually over-written, when nimpretty is a noop).
    # --backup was un-documented (rely on git instead).

  var hintsTable: seq[HintState]
  prettyPrint(fileInput, fileOutput, hintsTable)

  for item in hintsTable:
    case item.kind
    of HintStateKind.hintIsMainModule:
      echo item
    else:
      echo item

when isMainModule:
  import cligen
  dispatch main
