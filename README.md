Sensorino
==================

http://mattiadmr.com/sensorino/

A distance sensor with Arduino microcontroller.
This simple sensor can measure the distance from a surface.
Based on the property of an LED to act as a photodiode, that is, a photodetector able to sense and detect changes in the received light.

All you need is an Arduino board and two IR LED. You can addtionaly use a support for the LEDs to help you to keep them in position and prevent light to disturb the sensor.

SETUP:

1) Wiring
- Receiver:
  Connect the receiver LED positive(+) in the analog 0 pin
  Connect the receiver LED negative(-) in the gnd pin (ground)
- Emitter:
  Connect the emitter LED positive(+) in the analog 1 pin
  Connect the emitter LED negative(-) in the gnd pin (ground)

2) Loading code on the microcontroller / Setup

    Once the wiring is done, load the program on the microcontroller.
    You can set up the numbers of samples for your trainig set. Check the "REGRESSOR VARS" setting

3) Training

    Once the program run, instruction will be provided on how to train your predictor.

4) Done! After the training, you can start use your distance sensor.

