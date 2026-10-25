## ADDED Requirements

### Requirement: A contact scales the inverse mass of each side
`B2Contact` SHALL provide `setInvMassScales(scaleA:Float, scaleB:Float)`, `getInvMassScaleA():Float` and `getInvMassScaleB():Float`. When the contact is solved, the inverse mass and the inverse rotational inertia of body A SHALL be multiplied by scale A, and those of body B by scale B, in every phase of the contact solve (effective masses, warm starting, velocity and position iterations), in the regular step and in the TOI solve. Scales are non-negative; the body's own mass and its other contacts are not affected.

#### Scenario: One side does not react
- **WHEN** two dynamic bodies without gravity move toward each other and the listener's `preSolve` sets scale A = 0 and scale B = 1
- **THEN** after the contact body A's velocity is unchanged and body B bounces off as from a static wall moving with A's velocity

#### Scenario: No scales set
- **WHEN** a listener does not call `setInvMassScales`
- **THEN** the bodies move exactly as they did before this capability existed

#### Scenario: Both sides scaled to zero
- **WHEN** `preSolve` sets both scales to 0
- **THEN** the contact applies no impulse and no velocity becomes NaN

### Requirement: Scales are reset before every preSolve
Both scales SHALL be 1 when a contact is created and SHALL be set back to 1 by `B2Contact.update` before it calls `B2ContactListener.preSolve`, so a listener that wants a scale other than 1 sets it on every step.

#### Scenario: Listener stops setting the scale
- **WHEN** `preSolve` sets scale A = 0 on one step and does not set it on the next
- **THEN** on the next step both scales are 1
