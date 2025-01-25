#include <Keyboard.h>

const int inPin = A1;
int initThres;
bool keyState = false;

int threshold = 50;

void setup() {
  Serial.begin(9600);
  Keyboard.begin();
}

void loop() {
	unsigned long t = millis();  // Get timestamp for comparison

  int reading = collectSample();
  int remap = map(reading, initThres, 0, 0, threshold);

  //Serial.println(remap);

  if (remap > (float)threshold * 0.8 && !keyState) {
    Keyboard.press('w');
    keyState = true;
    delay(100);
  } else if (keyState) {
    Keyboard.release('w');
    keyState = false;
  }

  if (reading > initThres) {
    initThres = reading;
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
