# lint
nimlint makes developing softer.

Ref https://github.com/timotheecour/Nim/issues/415

## lint items

- [x] code block => runnableExamples
- [x] proc + noSideEffect => func
- [x] assert in a test file => doAssert
- [x] isMainModule in stdlib => recommend moving to tests/stdlib/tfoo.nim
- [x] double backticks => single backticks
- [x] the first letter should be upper
- [x] the last char shouldn be in alphabet

## TODO

- [x] Better messages with filename, line and col number
- [ ] Fix them
- [ ] Github APP integration
- [ ] Syntax to ignore lint recommendations, analog to #!nimpretty off
(maybe via a pragma or special #!nimlint:off syntax)
