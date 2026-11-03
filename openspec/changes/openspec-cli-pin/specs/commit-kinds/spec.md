## MODIFIED Requirements

### Requirement: The check proves itself
`.github/scripts/check-commit-kinds-test.sh` SHALL build a throwaway repository with a mixed commit and fail unless the check rejects it; CI runs it before the real check.

#### Scenario: The check stops rejecting mixed commits
- **WHEN** `check-commit-kinds.sh` is changed so that it accepts a commit touching both code and infrastructure
- **THEN** the self-test fails and the `commit-kinds` CI job fails before the real check runs
