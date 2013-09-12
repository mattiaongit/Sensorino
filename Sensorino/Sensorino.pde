int inputPIN = A0;                   // Pin LED receiver (Analog 0)
int emitterPIN = A1;                 // Pin LED emitter  (Analog 1)
double minDistanceIntensity = 0.0;   // Max intensity recorded ( index of min distance pereceived)
int readings = 2000;                // number of readings ( keep it in a 500/2500 range, greater values suits better in a scotopic condition)
int filterValue = 0.1;              // const value of filter

double distance = 0.0;
j
double reading = 0.0;
double ambient = 0;
double intensity = 0;

// AVR code - http://playground.arduino.cc/Main/AVR
// cbi and sbi are standard (AVR) methods for setting, or clearing, bits in PORT (and other) variables.
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))


// REGRESSION VARS
const int n = 10;         // n# point of regression - Change this value to change the number of examples to record in the training phase
double intensityData[n];  // Intensity axes (x) values
double distanceData[n];   // Distance  axes (y) values
double a, b;             // Parameters to find and compute with linear regression


void setup() {
  pinMode(inputPIN, INPUT);
  pinMode(emitterPIN, OUTPUT);
  pinMode(A2, OUTPUT);
  Serial.begin(115200);

  // decrease the time for a reading of the analog from 128 micros (standard) to 32ms
  sbi(ADCSRA,ADPS2);
  cbi(ADCSRA,ADPS1);
  sbi(ADCSRA,ADPS0);


  // definition of distance vector (y) that are is to be asked to the user ( during the training phase)
  for (int i= 0; i <n; i++){
	distanceData[i] = (double)i;
  }

  // TRAINING
  // Ask the user to put the sensor in the training positions
  for (int i = 0; i < n; i++) {
    Serial.print("Press any key after positioning the sensor at distance ");
    Serial.println(distanceData[i]);

    // Sense the intensity perceived,with "getDistance()" function, and store it in the intensity vector
    boolean dataRead = false;
    while(!dataRead){
      if(Serial.available() > 0){
	getDistance();
	intensityData[i] = intensity;
	dataRead = true;
	Serial.flush();
      }
    }
    // Print the recorded data on Serial Monitor
    Serial.println( intensityData[i]);
  }


  // REGRESSION
  // Htheta = theta0 + theta1 * x
  // Compute parameter a,b (theta0, theta1)
  // Find theta0 theta1 such as Htheta(x) is close to y for every tarining examples (x,y)

  double sx = 0;     // x's sum
  double sy = 0;     // y's sum
  double sxx = 0;    // x^2's sum
  double syy = 0;    // y^2's sum
  double sxy = 0;    // x*y's sum

  for (int i = 0; i < n; i++) {
    double x = intensityData[i];
    double y = distanceData[i];
    Serial.print("Data ");
    Serial.print(x);
    Serial.print(" ");
    Serial.println(y);
    sx = sx + x;
    sy = sy + y;
    sxx = sxx + (x*x);
    syy = syy + (y*y);
    sxy = sxy + (x*y);
  }

  // mean of x and y
  double xm = sx / (double) n;
  double ym = sy / (double) n;
  Serial.print("mean of X = ");
  Serial.print(xm);
  Serial.print(", mean of Y = ");
  Serial.println(ym);



  Serial.print("mean of X^2 = ");
  Serial.println( (sxx) / (double) n);

  // regression y = a + bx
  //b = (xm*ym - (sxy/n)) / (xm * xm -  (sxx/n));
  b = (sxy - ym * sx - xm * sy + n * xm *ym) / (sxx - 2*xm*sx + xm * xm * n);
  a = (ym - xm * b);

  // output the coefficient found
  Serial.println("a ");
  Serial.println(a);
  Serial.println("b ");
  Serial.println(b, DEC);
}



void getDistance() {

  ambient = 0;
  intensity = 0;
  digitalWrite(emitterPIN, LOW);   // Ambient Reading - Emitter pin is OFF (no IR light emitted)
    for(int i = 0; i < readings; i++) {
    ambient = ambient + analogRead(inputPIN);
    }


  digitalWrite(emitterPIN, HIGH);   // Full Reading - Emitter pin is ON (IR light emitted)
  for (int i = 0; i < readings; i++) {
    intensity = intensity + analogRead(inputPIN);
  }

  digitalWrite(emitterPIN, LOW);    // Readings are done. Turn the Emitter OFF again


  if(ambient < intensity) intensity = intensity/readings - ambient/readings; // Ambient light filter

    // If you want to compute distance with the inverse square law, uncomment this and use this funntion to get the distance
   // return  intensity;
  //  if(ambient < intensity) intensity = intensity - ambient; // Filtro luce ambientale
  //    if(intensity > minDistanceIntensity) minDistanceIntensity = intensity; // Salva l'intensità maggiore percepita
  //    distance = (distance * filterValue) + (sqrt(minDistanceIntensity / intensity) * (1 - filterValue));
}

void loop() {

    //SENSOR APPLICATION
    // after the training, sensor is ready to be use with the computed data
    Serial.print("Press any key after positioning the sensor in the wanted position to test");
    double x;
    boolean dataRead = false;
    while (!dataRead) {
     if(Serial.available() > 0) {
       getDistance();
       x = intensity;
       dataRead = true;
       Serial.flush();
     }
    }
    Serial.println( "Light perceived: ");
    Serial.println(x);
    Serial.println( "b: ");
    Serial.println(b);
    Serial.print("Estimate Distance: ");
    Serial.println(x*b + a);


}
