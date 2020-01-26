# Raspberry Pint FPGA talk twiddle demo

## Board hardware

This demo board consists of a [TinyFPGA BX](https://tinyfpga.com/) wired up with:

 * a red LED on pin 1

 * a [rotary encoder with red/green LEDs](https://www.sparkfun.com/products/15140)
   with: red LED on pin 2, green LED on pin 3, press-button on pin 14, and
   the A and B outputs of the rotary encoder on pins 15 and 16 (it doesn't
   matter which way round they go - swapping them changes the direction of
   rotation).

The three LEDs each have a 60 ohm resistor in series with them.

The rotary encoder common, the gnd connection from the rotary encoder LEDs
and switch, and the negative side of the separate LED all connect to the
G (ground) pin of the TinyFPGA.

Power comes in via the TinyFPGA from the USB connection.

## Install

To build:

```
$ apio build
$ tinyprog -p hardware.bin
```

## Use

Turn the rotary encoder one way to cycle through
red/yellow/green/off and the other way to cycle in the other direction.

Press the rotary encoder button to make all LEDs (including the on-board one)
pulse.

Each click of the rotary encoder will toggle the onboard LED on/off.
