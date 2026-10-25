# Design

## Where the scales live

On `B2Contact` (`m_invMassScaleA`, `m_invMassScaleB`, both 1). `B2ContactSolver.initialize` copies them into the `B2ContactConstraint` (`invMassScaleA`, `invMassScaleB`), and every phase — effective masses, warm start, velocity iterations, position iterations — multiplies the bodies' inverse masses and inertias by the constraint's scales. The scales are read once per solve, so a listener that changes them outside `preSolve` takes effect at the next solve. A scale of exactly 1 multiplies without rounding, so with no scales set the solver computes bit-identical numbers.

The position solver works with "equalized" inverse masses (`m_mass * m_invMass`, i.e. 1 for a dynamic body, 0 otherwise); the scale multiplies those too, so a side with scale 0 is not moved by position correction either.

## Reset

`B2Contact.update` sets both scales back to 1 right where it re-enables the contact, before `preSolve`; `reset` (contact creation / reuse) sets them to 1 as well. A TOI event calls `update` on the TOI contact, so its listener sets the scales again; other contacts of a TOI island keep the scales of their last `preSolve`.

## TOI

`B2Island.solveTOI` uses `B2ContactSolver.initialize` / `solveVelocityConstraints` / `solvePositionConstraints`; it has no inverse-mass code of its own, so it needs no change.

## Zero effective mass

`1 / k` is taken only for `k > 0`, otherwise the effective mass is 0 and the impulse cached from earlier steps is cleared, so the contact neither warm starts nor reports to `postSolve` an impulse it no longer applies. Before this change `k` could not be 0 for a solid contact (one body is always dynamic), so results with no scales set are unchanged.

## Names

`setInvMassScales` / `getInvMassScaleA` / `getInvMassScaleB`, after PhysX's `setInvMassScale0/1`; one scale covers both mass and inertia, as the issue asks.

## Tests

`test/` holds a plain Haxe program (`TestMain`) with no dependencies, run on `--interp` by `test/run.sh` with the pinned compiler; a failed check exits non-zero.
