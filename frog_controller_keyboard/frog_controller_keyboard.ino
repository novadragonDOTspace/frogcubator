#include <Keyboard.h>

const int inPin = A1;
bool keyState = false;

void setup() {
  Serial.begin(9600);
  Keyboard.begin();
}

void loop() {

  int reading = collectSample();
  //Serial.println(remap);

  if (reading > 0) {
    Keyboard.press('w');
    keyState = true;
    delay(200);
  } else if (keyState) {
    Keyboard.release('w');
    keyState = false;
  }

  delay(100);                      
}
  
int collectSample() {
  int sum = 0;
  int volValue;
  int readings = 12;
  int averageValue;
  for (int i = 0; i < readings; i++) {
    volValue = analogRead(inPin);
    sum += volValue;
    //Serial.println(sum);
    delay(1);
  }

  averageValue = sum / readings;
  return averageValue;
}
