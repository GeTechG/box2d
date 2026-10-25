# Design

## Where the scales live

On `B2Contact` (`m_invMassScaleA`, `m_invMassScaleB`, both 1). `B2ContactSolver.initialize` copies the scaled inverse masses and inertias into the `B2ContactConstraint` (`invMassA`, `invIA`, `invMassB`, `invIB`), and every later phase — warm start, velocity iterations, position iterations — reads them from the constraint instead of from the bodies. The scales are read once per solve, so a listener that changes them outside `preSolve` takes effect at the next solve.

The position solver works with "equalized" inverse masses (`m_mass * m_invMass`, i.e. 1 for a dynamic body, 0 otherwise); the scale multiplies those too, so a side with scale 0 is not moved by position correction either.

## Reset

`B2Contact.update` sets both scales back to 1 right where it re-enables the contact, before `preSolve`; `reset` (contact creation / reuse) sets them to 1 as well. A TOI event calls `update` on the TOI contact, so its listener sets the scales again; other contacts of a TOI island keep the scales of their last `preSolve`.

## TOI

`B2Island.solveTOI` uses `B2ContactSolver.initialize` / `solveVelocityConstraints` / `solvePositionConstraints`; it has no inverse-mass code of its own, so it needs no change.

## Zero effective mass

`1 / k` is taken only for `k > 0`, otherwise the effective mass is 0 (no impulse). Before this change `k` could not be 0 for a solid contact (one body is always dynamic), so results with no scales set are unchanged.

## Names

`setInvMassScales` / `getInvMassScaleA` / `getInvMassScaleB`, after PhysX's `setInvMassScale0/1`; one scale covers both mass and inertia, as the issue asks.

## Tests

`test/` holds a plain Haxe program (`TestMain`) with no dependencies, run on `--interp` by `test/run.sh` with the pinned compiler; a failed check exits non-zero.
