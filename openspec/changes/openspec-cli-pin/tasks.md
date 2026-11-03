## 1. Pin and skills

- [x] 1.1 Add `openspec/cli.pin` with `1.16.0`; verify: `cat openspec/cli.pin` equals `openspec --version`.
- [x] 1.2 Regenerate the OpenSpec skills with the pinned CLI (`openspec update`) in `.claude/skills/` and `.agents/skills/`, in the same commit as the pin; verify: every `generatedBy` in `openspec-*/SKILL.md` equals the pin.

## 2. config.yaml rules

- [x] 2.1 Add `rules.specs`, `rules.tasks` and `operations.apply` / `operations.archive` guidance pointing at `AGENTS.md` to `openspec/config.yaml`; verify: `openspec instructions specs --change openspec-cli-pin` and `openspec instructions tasks --change openspec-cli-pin` show the rules.

## 3. Check and CI

- [ ] 3.1 Write `openspec/check.sh`: strict validation of everything (errors and warnings fail), placeholder Purpose, active change without `.openspec.yaml`, skill `generatedBy` ≠ pin, open non-`[human]` task in the archive; it runs the global `openspec` when its version equals the pin, otherwise `npm exec` of the pinned package; verify: each failing case reproduced in a scratch copy makes it fail with the name of the offender, and it passes on the finished branch.
- [ ] 3.2 Add the `openspec` job to `.github/workflows/ci.yml` running `openspec/check.sh`; verify: the job is green on the pushed branch.
- [ ] 3.3 Record the pin, the bump procedure and the check in `AGENTS.md` (Toolchain, Checks, Specs); verify: reading it, every command above is named.

## 4. Spec fixes

- [ ] 4.1 `commit-kinds`: scenario for the self-test requirement; `contact-inv-mass-scales`: split the long requirement (delta specs of this change); verify: after archive, `openspec validate --all --strict` reports nothing.

## Workflow follow-up

- Archive the change as the last commit of the branch, rebase onto `master`, run the checks, merge.
