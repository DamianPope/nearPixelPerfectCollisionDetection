# nearPixelPerfectCollisionDetection
OpenFl and Haxe function that detects if two images overlap, even if they're irregularly shaped. 

It includes an adjustable parameter that allows the user to perform "near perfect" collision detection, or coarse-grained collision detection.
Instead of checking every single pixel to see if there's overlap (i.e., a collision), it can check every second pixel, or every third, or every fourth etc.

As pixels are small, it still detects collisions well and uses less processing power. This functionality provides more flexibility and can be useful if it's important to minimize processing power requirements.
