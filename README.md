# Kymera Wand

## Overview

This is a simple Control4 driver to read commands from the Kymera
magic wand.

The Kymera wand is a simple IR transmitter. Control4 does not have an
IR receiver module that can be programmed against, so we must create
our own. For that, we can use a simple Arduino board with WiFi and
attach an IR transmitter to it.

## Building and programming the IR receiver

You need an arduino board with WiFi, such as the ESP32:

http://adafru.it/3591

an IR transmitter:

http://adafru.it/157

and some way of connecting them together:

https://www.amazon.com/dp/B07GD312VG

There is some static configuration in kymera.ino that will need to be
adjusted to connect to the correct WiFi network. You may also wish to
change which pin the IR receiver data is connected to.

## Configuration

The driver automatically detects the Kymera using mDNS, so no
configuration of the IP address is necessary.

## Driver Events

There are 13 different commands that can be interpreted by the wand,
each with their own event.

## Change Log

Version 5:

- Initial release
