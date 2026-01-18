# AetherLink: High-Assurance Satellite Communication

![Language](https://img.shields.io/badge/language-Ada%202012-blue)
![Assurance](https://img.shields.io/badge/assurance-SPARK%20Ready-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Build](https://img.shields.io/badge/build-passing-brightgreen)

**AetherLink** is a mission-critical communication module designed for satellites. Built with **Ada 2012** and **SPARK** principles, it prioritizes safety, reliability, and correctness.

## Features

*   **SPARK-Compliant Packet Handling**: Strong typing and formal contracts to prevent buffer overflows and runtime errors.
*   **Zero Dynamic Allocation**: All memory is statically allocated to ensure deterministic behavior.
*   **Flight Simulation Harness**: Built-in test harness to verify telemetry serialization and deserialization.

## Getting Started

### Prerequisites

*   GNAT Community Edition or FSF GNAT (Ada Compiler)
*   GPRBuild

### Build

```bash
gprbuild -P AetherLink/aetherlink.gpr
```

### Run Simulation

```bash
./AetherLink/obj/main
```

### Run Tests

```bash
./AetherLink/tests/run_test.sh
```

## Structure

*   `src/packet_types.ads`: strongly typed packet definitions.
*   `src/packet_handler.adb`: SPARK-ready serialization/deserialization logic.
*   `src/main.adb`: Flight software simulation entry point.
