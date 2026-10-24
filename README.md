# Memory Verification using UVM

## Overview

This project implements a UVM-based verification environment for a parameterized synchronous memory using SystemVerilog and the Universal Verification Methodology (UVM). The testbench verifies memory read and write operations by generating constrained-random transactions, monitoring DUT responses, and checking data correctness and protocol behaviour.

The verification environment follows the standard UVM architecture with a sequencer, driver, monitor, agent, scoreboard, coverage collector, environment, and test. It uses TLM communication, a reference memory model, SystemVerilog Assertions (SVA), and automated transaction checking to verify the memory DUT.

---

## Key Features

- UVM-based verification environment for a parameterized synchronous memory
- Configurable memory depth, data width, and address width
- Support for memory read and write operations
- Standard UVM components, including driver, monitor, sequencer, agent, scoreboard, and environment
- Constrained-random sequences for different read and write scenarios
- TLM communication between the monitor, scoreboard, and coverage collector
- Virtual interface and clocking blocks for driving and sampling DUT signals
- Reference-model-based scoreboard for checking read-data correctness
- SystemVerilog Assertions for handshake checking and unknown-value detection
- Functional coverage for read/write operations and memory addresses
- Cross coverage for read/write operations across address regions
- Multiple test scenarios selected through the UVM factory and `uvm_config_db`
- Automated matching/mismatching statistics and final verification reporting

---

## Verification Architecture

The verification environment follows the standard UVM layered architecture, with separate components for stimulus generation, signal driving, monitoring, checking, and coverage collection:

- Memory Interface
- Sequence Item
- Sequence Library
- Sequencer
- Driver
- Monitor
- Agent
- Scoreboard
- Coverage Collector
- Environment
- Test
- Top Module

The sequence generates memory transactions and sends them to the driver through the sequencer. The driver applies the transactions to the DUT through the virtual interface and follows the valid-ready handshake.

The monitor observes completed transactions and sends them to the scoreboard and coverage collector through a UVM analysis port. The scoreboard maintains a reference memory model to check read data, while the coverage collector tracks the operations and addresses exercised during simulation. Assertions check handshake timing and signal validity, and the scoreboard reports matching and mismatching transactions.

---

## Verification Scope

The verification environment checks:

- Memory read and write operations
- Correct address and write-data handling
- Data storage and retrieval from memory locations
- Valid-ready handshake behaviour
- Registered one-cycle response latency
- Single-write and multiple-write scenarios
- Write-followed-by-read operations
- Multiple writes followed by reads from the same addresses
- Read-data correctness using scoreboard-based checking
- Address and read/write operation coverage
- Cross coverage of read/write operations and address regions
- Unknown values on active transaction signals using assertions
- Automated checking of matching and mismatching read transactions

---

## Tools and Technologies

- Language: SystemVerilog
- Methodology: Universal Verification Methodology (UVM)
- Verification Components: Driver, Monitor, Sequencer, Agent, Scoreboard, and Coverage Collector
- Communication: UVM TLM analysis ports and sequencer-driver connections
- Assertions: SystemVerilog Assertions (SVA)
- Functional Verification: Functional coverage and cross coverage
- Configuration: UVM Factory and `uvm_config_db`
- Simulator: QuestaSim / ModelSim
- Build and Run Flow: `run.do` simulation script
- Reporting: Scoreboard-based transaction checking and matching/mismatching statistics

---

## Results

- Implemented a complete UVM-based verification environment for a parameterized synchronous memory.
- Verified single-write, multiple-write, single write-read, and multiple write-read scenarios.
- Implemented a reference memory model to check read-data correctness.
- Used UVM TLM analysis ports to send monitored transactions to the scoreboard and coverage collector.
- Added assertions to check valid-ready handshake timing and unknown values on active transaction signals.
- Implemented functional coverage for read/write operations and memory addresses, including cross coverage.
- Developed reusable UVM sequences and test classes to support different verification scenarios.
- Generated matching/mismatching statistics through the scoreboard for verification result analysis.

