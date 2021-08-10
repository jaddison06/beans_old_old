# beans design

## workflow
The Beans workflow is centered around allowing different objects and media types full control over their own parameters, utilising concepts like effect chains to produce complex results. However, this could introduce repetitiveness if the same operation needs to be applied to different objects, so Beans provides the ability to apply and update a method over multiple objects. Application of these modifiers defaults to being by reference, so an object will be modified by a modifier which resides in a central repository. Should the user wish to duplicate this modifier, they will be able to do so through the central store (although shortcuts will of course exist).
## graphics
The Beans system is laid out in a series of windows, which pass up minimum constraints and can thus be resized accordingly. Most operations are done around edges - resizing will happen to two adjacent windows at the same time, by dragging the edge. Windows will also have a tactile drag shortcut which puts the window into drag mode. The user's mouse will snap the window to edges as it approaches them, with the window view updating live.
## stack
Beans will use C for low-level communication, data manipulation & IO. High-level logic will be written in Dart, which also allows scripting to be done in Dart with the hot reload engine.