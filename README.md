# Leka Alpha Communication Specifications

[![spm](https://img.shields.io/badge/spm-v3.0.0-blue.svg)](https://github.com/apple/swift-package-manager)
[![swift-version](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](swift.org)
[![Build Status](https://travis-ci.org/leka/LKAlphaComSpecs.svg)](https://travis-ci.org/leka/LKAlphaComSpecs)
[![SonarCloud](https://sonarcloud.io/api/project_badges/measure?project=leka-LKAlphaComSpecs&metric=alert_status)](https://sonarcloud.io/dashboard?id=leka-LKAlphaComSpecs)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=leka-LKAlphaComSpecs&metric=coverage)](https://sonarcloud.io/dashboard?id=leka-LKAlphaComSpecs)
[![SwiftBinarySearch](https://img.shields.io/badge/license-Apache--2.0-lightgrey.svg)](https://github.com/ladislas/SwiftBinarySearch/blob/master/LICENSE)

## About

This repository contains the specifications to easily implement master-slave communication between a *master*-device (computer, phone, tablet) and a *slave*-Leka robot, provided that the master has BLE compatible hardware.

## Table of Contents

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
- [Use](#use)
- [Definitions](#definitions)
- [Command frame Specifications](#command-frame-specifications)
  - [Structure](#structure)
  - [Encoding / Size](#encoding--size)
  - [Start Sequence](#start-sequence)
  - [Checksum](#checksum)
  - [Generation](#generation)
  - [Length](#length)
- [Command Specifications](#command-specifications)
  - [Structure](#structure-1)
  - [Available commands](#available-commands)
- [How it works inside Leka](#how-it-works-inside-leka)

## Installation

### Swift Package Manager

With SPM, add the following to the dependencies of your `Package.swift`

```swift
.package(url: "https://github.com/leka/LKAlphaComSpecs", from: "3.0.0")
```

### Cocoapods

> // TODO: - 

### Carthage

> // TODO: - 

### Manual

Copy the file [`Sources/LKAlphaComSpecs.swift`](./Sources/LKAlphaComSpecs.swift) in your project.

## Use

```swift
import LKAlphaComSpecs

let cmd = LKCommand.info
```

## Definitions

For easier understanding:

- `frame` / `command frame` - the whole structure of data sent by the master to the robot, including start sequence, length, commands and checksum

- `commands` / `command group`: a group of one or more commands to be performed by the robot

- `command`: a specific command performed by the robot

## Command frame Specifications

### Structure

A *command frame* is composed of the following:

- start sequence
- length of the *command group*
- *command group* with one or more *commands*
- checksum

### Encoding / Size

The data are always encoded on:

- `8 bits` / `1 byte`
- using `uint8_t` in C++ and `UInt8` in Swift
- and represented as `hex` values

### Start Sequence

Each *command frame* starts with a `start sequence`:

- length: `4 bytes`
- values: `[0x2A, 0x2B, 0x2C, 0x2D]`

### Checksum

Each *command frame* ends with a checksum:

- type: [BSD Checksum](https://en.wikipedia.org/wiki/BSD_checksum)
- input: `command group ` & `command group length`

### Generation

To generate a valid *command frame*, the following steps are needed:

1. *commands* are concatenated in an *command group*
2. the length of the *command group* is calculated and stored
3. a checksum of the *command group* is generated
4. a *command frame* is generated by concatenation of:
	
	1. start sequence
	2. *command group*'s length
	3. *command group*
	4. *command group*'s checksum

Here is an example with a simple command:

```
Goal: turn on belt LED[0] in red / RGB(255, 00, 00)

- Command id:    led/belt/single  --> 15
- LED id:        0                --> 00
- RGB values:    255, 0, 0        --> FF 00 00

1. Create command group:
                 --> 15 00 FF 00 00
2. Get command group length:
                 --> 05
3. Calculated checksum:
                 --> 41
4. Concatenate command frame:
                 --> 2A 2B 2C 2D   05   15 00 FF 00 00   41                  
```

### Length

#### Minimum

The minimum length of a *command frame* is `7 bytes`, corresponding to the `info` (`0x70`) action:

```
2A 2B 2C 2D   01   70   70
```

#### Maximum

In theory, the maximum length of a *command frame* is `128 bytes`, corresponding to the size of the serial buffer used in Leka.

But one has to always assume that data is still present in the buffer and might prevent the whole command from being received and processed.

In real life, one will almost never reach the `128 bytes` limit.

As an example, the following *command frame* turns on color each one of the 20 LEDs of the robot's belt in a specific RGB color:

```
2A 2B 2C 2D   64   15 00 33 00 00 15 01 66 00 00 15 02 99 00 00 15 03 CC 00 00 15 04 FF 00 00 15 05 00 00 00 15 06 00 33 00 15 07 00 66 00 15 08 00 99 00 15 09 00 CC 00 15 0A 00 FF 00 15 0B 00 00 00 15 0C 00 00 33 15 0D 00 00 66 15 0E 00 00 99 15 0F 00 00 CC 15 10 FF 00 00 15 11 00 FF 00 15 12 00 00 FF 15 13 FF FF FF   A8
```

The length of the whole *command frame* is `106 bytes`, far from the `128 bytes` limit.

## Command Specifications

The detailed list of commands available is available here:

> [LKAlphaComSpecs.yml](./Specs/LKAlphaComSpecs.yml)

### Structure

A command can have one of two forms:

- simple command - one `id` corresponding to one *command*, e.g. the `info` command
- complex command - one `id` and additional `data` needed to perform the command, e.g. turning the ears of the robot red

### Available commands

You can find all the commands available in [`Specs/LKAlphaComSpecs.yml`](./Specs/LKAlphaComSpecs.yml)

| Command           | Type    | ID     | Length        |   | Data                               |
|-------------------|:-------:|:------:|---------------|---|------------------------------------|
| `info`            | simple  | `0x70` | 0             | 0 | n/a                                |
| `stop.led`        | simple  | `0xFD` | 0             | 0 | n/a                                |
| `stop.motor`      | simple  | `0xFE` | 0             | 0 | n/a                                |
| `stop.robot`      | simple  | `0xFF` | 0             | 0 | n/a                                |
| `led.ear.all`     | complex | `0x11` | 3             | 3 | R / G / B                          |
| `led.ear.single`  | complex | `0x12` | 1 + 3         | 4 | id (`0x00..0x01`) + R / G / B      |
| `led.belt.all`    | complex | `0x13` | 3             | 3 | R / G / B                          |
| `led.belt.range`  | complex | `0x14` | 1 + 1 + 3     | 5 | first + last + R / G / B           |
| `led.belt.single` | complex | `0x15` | 1 + 3         | 4 | id (`0x00..0x19`) + R / G / B      |
| `motor.all`       | complex | `0x21` | 1 + 1         | 2 | direction + speed                  |
| `motor.duo`       | complex | `0x22` | 1 + 1 + 1 + 1 | 4 | L-spin + L-speed + R-spin + L-spin |
| `motor.left`      | complex | `0x23` | 1 + 1         | 2 | spin + speed                       |
| `motor.right`     | complex | `0x24` | 1 + 1         | 2 | spin + speed                       |
| `motivator`       | complex | `0x50` | 1             | 1 | id (`0x51..0x55`)                  |
| `guidance`        | complex | `0x40` | 1             | 1 | id (`0x41..0x4F`)                  |

## How it works inside Leka

The way Leka Alpha handles command on the inside can be decided in 3 main steps.

Leka Alpha runs an infinite loop while waiting for incoming data.

### Step 1 - Serial data is available

1. While serial data is available, we read the `hardware serial buffer`[^1](#footnotes) and store the data in our own software circular `serialBuffer`

1. When the the `hardware serial buffer` is empty, we exit the `while` loop and move to the next step

### Step 2 - Parse the *command frames* received

First, check that the size of `serialBuffer` is greater than the minimum length of a *command frame* (`7 bytes`):

- **if** `size` **is smaller** than the minimum length --> we return and wait for more serial data
- **if** `size` **is greater** than the minimum length --> we continue the process

While `serialBuffer` is not empty:

1. The `serialBuffer` is parsed for `start sequence`:

	- **if not found**, the `serialBuffer` is purged and we go back to the main loop waiting for new serial data
	- **if found**, the next value, corresponding to the `command frame length` is read

1. The *command frame* is then read and stored in the `commandBuffer`

1. When `serialBuffer` is empty, we exit the `while` loop and move to the next step

### Step 3 - Run the commands

While `commandBuffer` is not empty, it is read and each command is ran one after the other.

When `commandBuffer` is empty, we exit the `while` loop and start the process all over again by waiting for serial data to be available.

--- 

## Footnotes

[1]: in reality it is not a hardware buffer, it is the Arduino provided serial buffer. But as its API is very limited, it's easier to use our own circular buffer `serialBuffer`
