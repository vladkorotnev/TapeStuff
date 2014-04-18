void sendByte(char data) {
   
  /* A zero is represented by 0,7ms lo, followed by 0.35ms hi, a one is represented by 0,7ms lo, followed by 1,4ms hi */

  for (byte mask = 00000001; mask>0; mask <<= 1) { //iterate through bit mask  
    up();
    if (data & mask){ // if bitwise AND resolves to true
      delayMicroseconds(1400);
    }
    else{ //if bitwise and resolves to false
       delayMicroseconds(350);
    }
    down();
    delayMicroseconds(700);
  }

   for (byte mask = 00000001; mask>0; mask <<= 1) { //iterate through bit mask
    
    up();
    if (data & mask){ // if bitwise AND resolves to true
      delayMicroseconds(350);
    }
    else{ //if bitwise and resolves to false
       delayMicroseconds(1400);
    }
   down();
    delayMicroseconds(700);
  }
}

/* Commands: Number buttons are like 0x00..0x09, so I cant be botherd to type them here */

char devid_laserdisk = 0xA8;
char devid_tuner     = 0xA4;
char devid_cd        = 0xA2;
char devid_tape      = 0xA1;
char devid_amp       = 0xA5;
char devid_vcr       = 0xAB;

char command_levelup = 0x0A;
char command_leveldn = 0x0B;
char command_muting  = 0x12;
char command_power   = 0x1C;

char command_forward = 0x10;
char command_rewind  = 0x11;
char command_stop    = 0x16;
char command_pause   = 0x18;
char command_play    = 0x17;
char command_record  = 0x14;

char command_eject   = 0x51;
char command_program = 0x0D;


void down() {  digitalWrite(  7, LOW ); }
void up() { digitalWrite(  7, HIGH );  }

void pioneer_init() {
  down();
  delayMicroseconds(9000);
  up();
  delayMicroseconds(5000);
  down();
    delayMicroseconds(700);
}


void setup()
{
  pinMode(  7, OUTPUT );
   Serial.begin(38400);
}

  byte incomingByte = 0;
void serialEvent() {
   if(Serial.available()) {
                incomingByte = Serial.read();
            
                if(incomingByte == 'P') { 
                  pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_play);
                  incomingByte = 0;
                }
                if(incomingByte == 'R') {  
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_record);
                  incomingByte = 0;
                }
                if(incomingByte == 'S') { 
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_stop);
                  incomingByte = 0;
                }
                if(incomingByte == 'H') { 
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_pause);
                  incomingByte = 0;
                }
                if(incomingByte == 'F') { 
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_forward);
                  incomingByte = 0;
                }
                if(incomingByte == 'B') {
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_rewind);
                  incomingByte = 0;
                }
                if(incomingByte == 'O') { 
                   pioneer_init();
                  sendByte(devid_tape);
                  sendByte(command_power);
                  incomingByte = 0;
                }
              if(incomingByte != 0) {   Serial.print(incomingByte); 
                Serial.print("?");
                incomingByte = 0;
              }
           }
}


void loop(){}
