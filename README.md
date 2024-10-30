# **Space Invaders with Joystick & Button Controls**

Hi everyone! This project is a modified **Space Invaders** game, enhanced with joystick and button controls for my Creative Embedded Systems course. This adaptation lets you control the player ship with a joystick instead of keyboard keys, making the gameplay more interactive.

The original game code is based on this repository: [fernandozamoraj's Space Invaders](https://github.com/fernandozamoraj/processing_sandbox/tree/master/SpaceInvaders), and I’ve modified it to work with physical inputs.

_**Design Goals**_:

Replace traditional keyboard controls with a joystick and a button for immersive gameplay. The joystick controls the player’s movement, while the button starts the game and shoots at enemies. Each player has three lives, so the player needs to defeat the aliens in time to survive.

_**Requirements**_:

- **Hardware**:
  - Joystick and button for input
  - Lily-TTGO board
  - USB-C cable for laptop connection

- **Software**:
  - Processing IDE (for running the code)
  - `processing.serial` library for serial communication between the joystick/button and Processing

_**Setup**_:

1. **Connect the Hardware**  
   Attach the joystick and button to the microcontroller and ensure it can communicate with Processing through the serial port. Refer to the included Fritzing diagram for guidance on connecting the joystick and button to the breadboard.

2. **Install Processing Libraries**  
   Ensure that `processing.serial` is included in your Processing IDE for serial communication.

3. **Clone and Run the Code**  
   Clone this repository, open the `.pde` file in Processing, and run the sketch.

_**How to Play**_:

- **Start**: Press the button to start the game from the main screen.
- **Move**: Use the joystick to move the player left or right.
- **Shoot**: Press the button to fire at the aliens above.

Enjoy playing!

