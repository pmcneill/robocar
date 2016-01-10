# ESP8266 Robot Car

This repository has everything you need to build or alter one of my
robot cars.  The car itself is based around an ESP8266 wifi
microcontroller.  I've used the [Arduino libraries](https://github.com/esp8266/Arduino)
for the actual code.  On start up, the car will join a wireless network
and then register its local IP address.  Anyone on that same wireless
network can visit the [car remote control page](http://patrickmcneill/car/)
to give it commands.

## Set up

Before you connect the car to your computer, you need to install a few programs.
First, install the driver for it, from
[https://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx](https://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx).  Next, install the
[Arduino software](https://www.arduino.cc/en/Main/Software).  Open up
the Arduino environment.  Go to the Preferences window and add
"http://arduino.esp8266.com/stable/package_esp8266com_index.json" under "Additional
Boards Manager URLs".  Open the board manager from Tools => Board and choose ESP8266.  Finally,
go back to the Boards menu again and choose "Generic ESP8266 Module".

Now, to reprogram the car, or to diagnose a problem, pull the wifi chip (about 1"x2")
off the board and connect it to your computer with a micro USB cable.  Under the tools 
menu, set the flash size to "4MB (3MB Spiffs)" and upload speed to 115200.  On a Mac,
choose /dev/cu.SLAB_USBtoUART for the port.  Finally, start up the "Serial Monitor" and
make sure it too is set to 115200.  Hit the RST (reset) button on the wifi chip and you
should start to see debugging output on the screen.

## Control Software

The Arduino software is in the "arduino" directory of this repository.
It's designed to work with a
[NodeMCU development board](http://www.aliexpress.com/item/New-Wireless-module-NodeMcu-Lua-WIFI-Internet-of-Things-development-board-based-ESP8266-with-pcb-Antenna/32303690854.html)
and its
[companion motor shield](http://www.aliexpress.com/item/Free-shipping-NodeMCU-Motor-Shield-Board-L293D-for-ESP-12E-from-ESP8266-esp-12E-kit-diy/32386754632.html).
Any ESP8266 chip should work, given an appropriate motor driver (most easily, a
LM293D chip).

On boot, the software uses the code in the WifiSetup file to find and join
the wireless network it knows about.  If it cannot, it'll start up a network
called "IoT Device" so you can provide it with an SSID and password.  Once
connected, it will send its local IP address to the IP server.  That address
will be used later by the remote control, so it can automatically find the
car.

Once control is passed back to the main file, each loop does three main things:

### Listen for Commands

First, it checks for any new commands.  It listens for commands by actually
running a web server, to which the remote control page will send commands.
Commands are defined in the "set_routes" function at the top.  Each route
is a path the web server will listen for, such as "http://192.168.0.100/forward".
The movement commands will call out to "set_motors", while "lights" and "mode"
will call handle_lights and handle_mode, respectively.

The set_motors function takes two integer parameters, reflecting the two motors.
-1 tells it to run "backwards", 1 to run "forward", and 0 to stop.  The direction
the motor actually runs depends on how the wires are connected for that motor.
To reverse the direction, just swap the black and red (or white) wires.

### Update Light Patterns

Pin 5 on the board controls a set of four WS2812b LED lights.  The pattern that's
displayed is defined by the /lights command and may have up to 100 different 
frames.  Each frame of the pattern is four RGB triads, one for each of the LEDs,
followed by the number of milliseconds to display that frame.  There are a number
of predefined patterns on the remote control page, but it's trivial to add more.
As an example, here's the "police" pattern:

```
f00f0000f00f:250,00f00ff00f00:250
```

The RGB values are each defined with a single hexadecimal character (ie, each color has
sixteen intensity levels).  For the first chunk, there are two "f00" pixels and two
"00f" pixels, the former is pure red, the latter pure blue.  The ":250" tells it to
display for 250 milliseconds.  In the second frame, the colors are reversed, also 
displaying for 250ms.  Once it reaches the end of the pattern, it'll go back to the
first frame.

In the code, this is taken care of by two functions.  The first is "handle_lights",
which is responsible for reading the pattern command.  The other is "refresh_lights",
which runs on each loop of the code.  The refresh function keeps track of when it
begins displaying a frame.  On each call, it checks to see if the current frame has
displayed for the correct amount of time.  If so, it changes to the next and restarts
its counter.

### Wandering

Finally, the robot can be set to "wander" with the "mode" command.  When wandering,
it will roll forward until one of its bumpers hits something.  When it does, it will
back up, spin, and then go forward again.  This is controlled by the "refresh_wander"
function, which is just a very basic state machine.  It keeps track of whether it's
backing up, needs to spin, or should just move forward.  It's called on each loop
iteration, and like the lights, it uses the millisecond clock to keep track of
what it's supposed to be doing.  The bumpers, by default, should be connected to
pins 6 and 7.

## Control Panel and IP Server

The next piece is the remote control, which has two parts.  First, there's the IP
server that keeps track of the address of the car(s).  That's a very simple 
Node.js app.  It does use some modern language features, so it'll need at least
Node.js 4.2 or so, but there are no external dependencies.

The remote control page is in index.html and car.js, in the top-level directory
of the repository.  The HTML file is just static content, with a visible "finding car"
message, and hidden control pad and error messages.  The car.js is what makes it
go.  It starts by downloading a list of the potential car IP addresses and trying to
communicate with each one.  Once it finds a car, it'll display the control panel (and,
if it can't, it displays a message about how to set up the car).  Move of the buttons
just send their movement commands to the car, but the "mode" and "lights" buttons have
a bit more logic.

## 3d Models

Finally, the "scad" directory has all of the 3d models (and a few extras) that I used
to print the car.  They're source files for [OpenSCAD](http://www.openscad.org/).
The "car plate upper" and "car plate lower" files are for the main chassis.  I also
used the "bumper", "light", and "caster" models.
