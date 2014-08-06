void pushPin(int pin) {
  digitalWrite(pin, LOW);
  delay(500);
  digitalWrite(pin, HIGH);
}

void setup()
{
  pinMode(  2, OUTPUT );
   digitalWrite(2, HIGH);
   pinMode(  3, OUTPUT );
   digitalWrite(3, HIGH);
   pinMode(  4, OUTPUT );
   digitalWrite(4, HIGH);
   pinMode(  5, OUTPUT );
   digitalWrite(5, HIGH);
   pinMode(  6, OUTPUT );
   digitalWrite(6, HIGH);
   pinMode(  7, OUTPUT );
   digitalWrite(7, HIGH);
   Serial.begin(38400);
}

  byte incomingByte = 0;
void serialEvent() {
   if(Serial.available()) {
                incomingByte = Serial.read();
            
                if(incomingByte == 'P') { 
                  // Play
                  pushPin(3); incomingByte = 0;
                }
                if(incomingByte == 'R') {  
                  // Rec
                  pushPin(6); incomingByte = 0;
                }
                if(incomingByte == 'S') { 
                  // Stop
                  pushPin(7); incomingByte = 0;
                }
                if(incomingByte == 'H') { 
                  // Pause
                  pushPin(2); incomingByte = 0;
                }
                if(incomingByte == 'F') { 
                  // Fwd
                  pushPin(4); incomingByte = 0;
                }
                if(incomingByte == 'B') {
                   // Rew
                   pushPin(5); incomingByte = 0;
                }
                if(incomingByte == 'O') { 
                  // Power OnOff // no such Nak remote pin
                    incomingByte = 0;
                }
                if(incomingByte == 'M') {
                   Serial.print("NAKAMICHI"); 
                    incomingByte = 0;
                }
              if(incomingByte != 0) {   Serial.print(incomingByte); 
                Serial.print("?");
                incomingByte = 0;
              }
           }
}


void loop(){}
