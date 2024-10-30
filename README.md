Hi everyone! This project is a modified Space Invaders game, enhanced with joystick and button controls for my Creative Embedded Systems course. This adaptation lets you control the player ship with a joystick instead of keyboard keys, making the gameplay more interactive.

The original game code is based on this repository(https://github.com/fernandozamoraj/processing_sandbox/tree/master/SpaceInvaders.), and I’ve modified it to work with physical inputs.



_Design Goals_:

I replaced traditional keyboard controls with a joystick and a button for immersive gameplay. The joystick controls the player’s movement, while the button starts the game and shoots at enemies. Each player only has three lives, so they need to shoot the aliens in time. 

_Requirements_:

A joystick and a button for input
Processing IDE for running the code
A serial connection to interface the joystick and button with Processing (using processing.serial library)
Lily-TTGO board 
USB-C cable that connects to your laptop

_Setup_:

Connect the Hardware: Attach the joystick and button to the microcontroller and ensure it can communicate with Processing through the serial port. Use the Fritzing diagram as a reference to where you should connect the joystick and button onto the breadboard.
Install Processing Libraries: Make sure processing.serial is included in your Processing IDE for serial communication.
Clone and Run the Code: Clone this repository, open the .pde file in Processing, and run the sketch.

_How to Play_:

Start: Press the button to start the game from the main screen.
Move: Use the joystick to move the player left or right.
Shoot: Press the button to fire at the aliens above.


