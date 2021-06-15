## dancing boids

A macOS screensaver.

### test
To test the screensaver, you can simply run the Target `ScreenSaverTest`.

### install
Build the target `DancingBoids`, then open the artifact `DancingBoids.saver`.

### development
The screensaver consists of multiple animations that are playing,
being randomly every now and then. 
If you want to add a new animation, 
you can create an implementation of `ScreenSaverViewDelegate`
and add the type of that delegate
to `screenSaverDelegates` in `DancingBoidsView`.

You may use the flockingbird library (`import Flockingbird`) to create boid animations.

For an example of the above, see `FlockingScreenSaverViewDelegate`.
