#include <Keyboard.h>

const int inPin = A1;
bool keyState = true;
int readingMax;
int readingMin;
unsigned long delayStart = 0;

void setup() {
  Serial.begin(9600);
  Keyboard.begin();
  keyState = true;
  delayStart = millis(); 
}

void loop() {
  if (digitalRead(2) == LOW) {
    return;
  }
  
  int reading = collectSample();

  if (reading > readingMax) {
    readingMax = reading;
  }
  if (reading < readingMin) {
    readingMin = reading;
  }

  Serial.print(readingMin);
  Serial.print(",");
  Serial.print(readingMax);
  Serial.print(",");
  Serial.println(reading);

  if (reading > readingMax * 0.8 && !keyState) {
    Keyboard.press('w');
    keyState = true;
    Serial.println("trigger on");
  }
  
  if (keyState) {
    if ((millis() - delayStart) >= 1000) {
      Keyboard.release('w');
      Serial.println("trigger off");
      keyState = false;
    }
  }

  delay(500);                      
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
