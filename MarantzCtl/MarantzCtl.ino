#include <IRremote.h>
#include <IRremoteInt.h>

void setup()
{

   Serial.begin(38400);
}

  byte incomingByte = 0;
void serialEvent() {
   if(Serial.available()) {
                incomingByte = Serial.read();
            
                if(incomingByte == 'P') { 
                  // Play
                }
                if(incomingByte == 'R') {  
                  // Rec
                }
                if(incomingByte == 'S') { 
                   // Stop
                }
                if(incomingByte == 'H') { 
                  // Hold 
                }
                if(incomingByte == 'F') { 
                  // Fwd
                }
                if(incomingByte == 'B') {
                  // Back
                }
                if(incomingByte == 'O') { 
                  // OnOff
                }
                if(incomingByte == '1') {
                  // Sel Deck A
                  
                }
                if(incomingByte == '2') {
                  // Sel Deck B
                  
                }
                if(incomingByte == 'M') {
                   Serial.print("MARANTZ2D"); 
                    incomingByte = 0;
                }
              if(incomingByte != 0) {   Serial.print(incomingByte); 
                Serial.print("?");
                incomingByte = 0;
              }
           }
}


void loop(){}
