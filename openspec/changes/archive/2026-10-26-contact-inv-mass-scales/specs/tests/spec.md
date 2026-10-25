## ADDED Requirements

### Requirement: The library has a test suite run by one command
Tests SHALL live under `test/` as a Haxe program with no dependencies beyond the standard library. `bash test/run.sh` SHALL compile and run them with the pinned compiler on `--interp` and SHALL exit non-zero when any check fails, naming the failed check.

#### Scenario: A failing check
- **WHEN** a check of the suite fails
- **THEN** `bash test/run.sh` prints the name of the check and exits non-zero
