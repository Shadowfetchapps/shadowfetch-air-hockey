# Architecture

The table is 0.96 m half-length and 0.48 m half-width. Goals are 0.28 m wide. The puck is a Jolt rigid body with CCD, no gravity, and a 12 m/s cap. Mallets are `AnimatableBody3D` so the mouse maps 1:1 onto ice.

`HockeyEngine.score_goal` accepts a side once per possession (`_goal_lock`). `clear_goal_lock` runs on face-off. Practice records the event and does not increment match scores.

`HockeySim` is a 2D kinematic twin of those dimensions used by automated tests. The live game uses Jolt. A puck that leaves the AABB or goes NaN is re-centered.

AI aims with reaction delay and a speed cap. It does not write puck velocity.
