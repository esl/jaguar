# Jaguar

**The official ride of Americas**

## Intro

`jaguar` is the project name for a Nerves-based WiFi controlled
car. It currently targets `rpi4` but more hardware support is planned.

## Versions

  * `jaguar-1` is the first prototype of the `jaguar` concept.
  * `jaguar-2` is the next-gen version currently in planning stage.

## Hardware

For convenience, we are linking most of the components on Amazon:

  * [Raspberry Pi 4 model B](https://a.co/d/j87JBGi)
  * [L298N motor driver](https://a.co/d/e5yZDWd)
  * [Two dual shaft 3v/9v DC gear motor](https://a.co/d/21Cs3Eg)
  * [Two motor controlled wheels and an extra free wheel](https://a.co/d/4DysWK5)
  * RC car chassis

You can get most of the parts with [this kit](https://a.co/d/4gC2kfT).

## First concept

The initial implementation consist of a Nerves application that
controls a [L298n motor
driver](https://components101.com/modules/l293n-motor-driver-module)
by listening for commands over a TCP connection that is established to
the backend at application startup.

Basic commands are then issued by the backend in order to control the
speed of the motors for easy steering and moving backwards. The
commands are then translated to GPIO commands over the drivers pins.

Speed is adjusted by controlling the driver via
[PWM](https://en.wikipedia.org/wiki/Pulse-width_modulation) signals
over GPIO emulation.

Communication via TCP is currently naive and error prone and we are
currently reworking on how the car components are structured for the
next iteration.

## Assembly

Most of the assembly images are in `img/`.

## Getting Started

To start your `jaguar-1`:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi4`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`

## Learn more

  * Official Nerves docs: https://hexdocs.pm/nerves/getting-started.html
  * `jaguar` source: https://github.com/esl/jaguar
