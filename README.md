# lint
nimlint makes developing softer.

Ref https://github.com/timotheecour/Nim/issues/415

## lint items
- [ ] code block => runnableExamples
- [x] proc + noSideEffect => func
- [x] assert in a test file => doAssert
- [x] isMainModule in stdlib => recommend moving to tests/stdlib/tfoo.nim
- [ ] double backticks => single backticks
- [ ] capitalize the first letter
- [ ] lots of testament specific checks (eg `exitcode: 0` usually useless)
- [ ] etc, countless things that would be best done as a tool instead of relying on every reviewer to check all of those in every PR (plus for making it easier to improve stdlib + third party projects)

## TODO

- [x] Better messages with filename, line and col number
- [ ] Fix them
- [ ] Github APP integration
