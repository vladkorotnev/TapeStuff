# PioneerCtl
### A small hacklet to control a Pioneer Tape deck over USB with an Arduino

Tested with Pioneer CT-S320.

----

## Usage
1. Flash "PioneerCtl.ino" to your Arduino
2. Build and run the app
3. Select the Arduino port
4. Enjoy your music!

----

## Video
<https://www.youtube.com/watch?v=lSXnBMb3XBc>

----
## Notes

Feel free to integrate this in your app. You need the [ORSSerialPort](https://github.com/armadsen/ORSSerialPort) classes for communication and the AKPioneerTapeRecorder class for easy control.
The transport control in the AIEdit.app is basically this whole window, copied into the other thing.
Don't forget to credit me for the component, that is much appreciated :3

----
## Thanks
* [Andrew Madsen](http://blog.andrewmadsen.com/post/26512371699/orsserialport-a-new-objective-c-serial-port-library) for ORSSerialPort
* [Kai Fett](http://www.schnism.net/system/pioct-e.html) for a slightly hard to understand description of the protocol :3 (btw man your pascal code is way too wicked!)
* Mels Yang and Arien Hikarin for support and inspiration <3

##### © vladkorotnev a.k.a. Akasaka Ryuunosuke, 2014