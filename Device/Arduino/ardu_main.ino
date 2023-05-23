#include <Servo.h>
#include <string.h>
#include <SoftwareSerial.h>

Servo door1;
Servo door2;
Servo trash;
SoftwareSerial mySerial(4, 3);

const int trigPin = 6;   // 초음파 센서의 Trig 핀 (변경됨)
const int echoPin = 7;   // 초음파 센서의 Echo 핀 (변경됨)

void door1_open() {
  door1.write(0);
  delay(1000);
}

void door1_close() {
  door1.write(90);
  delay(1000);
}

void door2_open() {
  door2.write(90);
  delay(1000);
}

void door2_close() {
  door2.write(175);
  delay(1000);
}

void trash_init() {
  trash.write(0);
  delay(1000);
}

void trash_powder() {
  trash.write(90);
  delay(1000);
}

void trash_capsule() {
  trash.write(180);
  delay(1000);
}

void led_on() {
  digitalWrite(10, HIGH);
}

void led_off() {
  digitalWrite(10, LOW);
}

float measureDistance() {
  // 초음파 센서를 사용하여 거리 측정
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  float duration = pulseIn(echoPin, HIGH);
  float distance = duration * 0.034 / 2;  // 소리의 속도를 이용한 거리 계산
  
  return distance;
}

void setup() {
  door1.attach(13);
  door2.attach(12);
  trash.attach(11);
  pinMode(10, OUTPUT);  // LED
  pinMode(trigPin, OUTPUT);   // Trig 핀을 출력으로 설정 (변경됨)
  pinMode(echoPin, INPUT);    // Echo 핀을 입력으로 설정 (변경됨)
  Serial.begin(9600);
  mySerial.begin(9600);
}

void loop() {
  if (mySerial.available() > 0) {
    String message = mySerial.readString();
    Serial.println(message);
    
    if (message.startsWith("door1_open")) {
      door1_open();
    } else if (message.startsWith("door1_close")) {
      door1_close();
    } else if (message.startsWith("door2_open")) {
      door2_open();
    } else if (message.startsWith("door2_close")) {
      door2_close();
    } else if (message.startsWith("trash_init")) {
      trash_init();
    } else if (message.startsWith("trash_powder")) {
      trash_powder();
    } else if (message.startsWith("trash_capsule")) {
      trash_capsule();
    } else if (message.startsWith("led_on")) {
      led_on();
    } else if (message.startsWith("led_off")) {
      led_off();
    } else if (message.startsWith("distance")) {
      float distance = measureDistance();
      mySerial.write(distance);
      Serial.println(distance);
    }
  }
}
