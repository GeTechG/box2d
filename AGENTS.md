# box2d — agent guide

Independent fork of `openfl/box2d` (the Haxe port of the Box2D 2D physics engine). Its consumers pin it by commit; they do not dictate how it is worked on. This file is the source of truth here.

## Commits
- Every commit is **code** (library sources under `box2D/`, upstream metadata such as `haxelib.json`, `include.xml`, `README.md`, upstream's own workflows) or **infrastructure** (the paths listed in `.github/infra-paths`: this file, `openspec/`, `tools/`). Never both.
- Code commit messages are written as for upstream `openfl/box2d`: a plain imperative summary of the library change, no mention of consumers or their paths.
- OpenSpec artifacts are infrastructure commits and never share a commit with code.
- An upstream PR is a cherry-pick of one task's code commits; keep them self-contained — they must build without any infrastructure commit.
- Changing the list of infrastructure paths is an infrastructure commit.

## Toolchain
- The compiler is a Haxe 5 build of `GeTechG/haxe`, pinned in `tools/haxe-build.pin` (`<build key> <sha256 of the archive>`). Changing the compiler is one commit that changes this file.
- **Build and type only with this compiler**, never the system Haxe 4.x. The fork has no setup script yet: take the archive `haxe-linux64-<build key>.tar.gz` from the `builds` release of `GeTechG/haxe`, verify it against the pinned sha256, and run its `haxe` with `HAXE_STD_PATH` pointing at its `std`.
- The library has no dependencies and no test suite.

## Checks
Run before pushing — every module must type on the three targets its consumers build for:

```bash
for t in "--interp" "-hl /dev/null" "-js /dev/null"; do
  haxe -cp . --macro "include('box2D')" --no-output $t || exit 1
done
```

A change to behaviour comes with a test that fails before it; the first such task adds the test harness.

## Specs
`openspec/` holds this fork's own specs (`openspec/specs/`). Behaviour or rule changes go through `openspec/changes/`.

## Workflow
No pull requests: this fork is worked on solo. Work lives on branches and lands on `master` by rebase or merge; the only mandatory gate is green checks (see *Checks*) on the exact tree that lands. Work is scheduled by baton — load the `/baton` skill before filing or picking up an issue, or changing an issue's status, labels, `footprint` or blockers.

An issue runs the same seven steps, in order:

1. **OpenSpec change.** Branch `change/<ISSUE-KEY>-<openspec-name>` from `origin/master` — one task, one branch — and write the change under `openspec/changes/`. Skip the OpenSpec change — here and in step 3 — when the work is mechanical, i.e. nothing the project history needs a record of (docs, renames, config, a bug fix that returns behaviour to what a spec already states). Anything else that touches behaviour is not mechanical — the change is mandatory. A missing spec is never a reason to skip: when `openspec/specs/` does not yet cover the behaviour the task touches, the change adds that spec as a new capability. A skip is never silent: the report on the issue carries the line `OpenSpec skipped: <reason>`. An issue labeled `gate:spec` stops here: push the artifacts, post a short plan on the issue, add `needs-human`; continue once the maintainer swaps it for `spec:approved`.
2. **Implement** the tasks.
3. **Test.** Verify the implementation against the change, then sync its specs and archive it as the **last commit of the branch** (never a separate push to `master`), rebase onto current `master` and run the checks. Unless the task is trivial (mechanical, or a few obvious lines), finish with a cross-review of the whole branch diff before the checks — `/ai-brainstorm:ai-review`, a judge from another model family — and fix or rebut its findings until clean.
4. **Human QA — only if the change has it.** Steps only a human can do are written `- [ ] N.M [human] …` in `tasks.md`; agents never tick them. If there are any, post them on the issue as a checklist a human can follow cold, add `needs-human` and stop; continue once the maintainer removes the label. No `[human]` tasks → skip.
5. **Merge** into `master`: `git merge --ff-only` for a single commit or a short linear series, `git merge --no-ff` for a multi-commit change. Push `master`. If `master` moved since the checks ran, rebase and run them again first.
6. **Clean up**: delete the branch (local and remote) and its worktree.
7. **Set the issue done.**

The maintainer decides architecture and end-user behaviour, nothing else — steps 1 (`gate:spec`) and 4 are the only points where an agent waits for a human. Work without an issue: mechanical edits may go straight to `master`.
