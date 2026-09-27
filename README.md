# Memory Verification using UVM
This project implements a complete verification testbench for a parameterized synchronous memory DUT, built entirely using the **Universal Verification Methodology (UVM)**. Unlike a plain class-based SystemVerilog environment, this version follows the standard UVM component hierarchy — driver, monitor, sequencer, agent, scoreboard, and coverage collector — connected through the UVM factory and TLM analysis ports, with SystemVerilog Assertions (SVA) embedded in the interface for protocol checking.

*This is the UVM-based version of a companion "Memory Verification using SystemVerilog" project, which uses a hand-built, mailbox-connected class-based environment instead of UVM's TLM/factory infrastructure. Both target the same DUT — this repo focuses on standardizing the verification methodology using industry-standard UVM.*

## Overview
This project implements a full UVM verification environment around a parameterized synchronous memory module.

***The DUT supports configurable:***
  • Memory depth (`DEPTH`)

  • Data width (`WIDTH`)

  • Address width, auto-calculated via `$clog2(DEPTH)`

***The testbench demonstrates fundamental UVM verification concepts like:***
  • Standard UVM component hierarchy (`uvm_driver`, `uvm_monitor`, `uvm_sequencer`, `uvm_agent`, `uvm_scoreboard`, `uvm_subscriber`, `uvm_env`, `uvm_test`)

  • TLM communication — `uvm_analysis_port`/`uvm_analysis_imp` (monitor → scoreboard/coverage) and the sequencer-driver `seq_item_port`/`seq_item_export` handshake (`get_next_item`/`item_done`)

  • Constrained-random sequences built on `uvm_sequence`, driven via `` `uvm_do_with ``

  • Multiple test scenarios (single write, N writes, single write-read, N writes-N reads) selected via the UVM factory and `uvm_config_db`

  • Clocking-block based driving and sampling through a virtual interface

  • SystemVerilog Assertions (SVA) for handshake and X-propagation checking

  • Functional coverage with cross-coverage, sampled via a `uvm_subscriber`

  • Reference-model based, self-checking scoreboard with a final PASS/FAIL-style report

## Design Details
### DUT: mem_dut.v
The DUT is a synchronous memory implemented as a register array:
  • **Depth:** Number of memory locations (`` `DEPTH ``)

  • **Width:** Size of each memory word (`` `WIDTH ``)

  • **Address Width:** Automatically calculated using `$clog2(DEPTH)`

### Key DUT Signals
  • **clk_i / rst_i:** Clock and synchronous active-high reset

  • **valid_i / ready_o:** Valid-ready handshake pair

  • **wr_rd_i:** 1 = write, 0 = read

  • **addr_i, wdata_i:** Address and write data inputs

  • **rdata_o:** Read data output

## Working Principle
### ✔ Reset Phase
  • ***When rst_i = 1:***

--------> Memory is cleared
--------> ready_o and rdata_o are reset

### ✔ Write Operation
  • ***Triggered when:***

--------> valid_i = 1
--------> wr_rd_i = 1
  • ***wdata_i is written to mem[addr_i]***

### ✔ Read Operation
  • ***Triggered when:***

--------> valid_i = 1
--------> wr_rd_i = 0
  • ***Data from mem[addr_i] is assigned to rdata_o***

### ✔ Handshake Logic
  • ready_o is asserted one cycle after a valid request is accepted (registered, non-blocking assignment)

  • Ensures controlled, single-cycle-latency data transfer

## Testbench Architecture (UVM)
The testbench follows the standard UVM layered architecture — every component below extends a base UVM class and is registered with the factory via `` `uvm_component_utils ``/`` `uvm_object_utils ``.

### ✔ Transaction — mem_tx.sv
  • Extends `uvm_sequence_item`

  • Randomizable fields: `addr_i`, `wr_rd_i`, `wdata_i` (`rand`); `rdata_o` is populated by the driver/monitor (non-random, observed)

  • Registered with `` `uvm_field_int `` macros for automatic print/copy/compare via `` `uvm_object_utils_begin/end ``

### ✔ Sequences — mem_seq_lib.sv
  • Base `mem_seq` extends `uvm_sequence #(mem_tx)` and raises/drops the phase objection in `pre_body()`/`post_body()`

  • **wr_seq:** single write transaction

  • **wr5_seq:** 5 writes to distinct (non-repeating) addresses

  • **nwr_seq:** `common::N` writes

  • **wr_rd_seq:** one write followed by a read to the same address (read-back check)

  • **wr5_rd5_seq:** 5 writes followed by 5 reads to those same addresses

  • **nwr_nrd_seq:** `common::N` writes followed by `common::N` reads to those same addresses — the main regression sequence

### ✔ Sequencer — mem_seqr.sv
  • `typedef uvm_sequencer #(mem_tx) mem_seqr;` — arbitrates sequence items and hands them to the driver via TLM

### ✔ Driver — mem_drv.sv
  • Extends `uvm_driver #(mem_tx)`

  • Gets the virtual interface handle from `uvm_config_db`

  • Pulls items from the sequencer using `get_next_item()` / `item_done()`

  • Drives transactions onto the DUT via the `drv_cb` clocking block, applies the valid-ready handshake in real simulation time, then resets the bus signals between transactions

### ✔ Agent — mem_agent.sv
  • Extends `uvm_agent`

  • Instantiates and connects sequencer, driver, monitor, and coverage collector

  • Wires `drv.seq_item_port` ↔ `sqr.seq_item_export` and `mon.ap_port` ↔ `cov.analysis_export`

### ✔ Monitor — mem_mon.sv
  • Extends `uvm_monitor`

  • Passively samples the interface via the `mon_cb` clocking block (never drives signals)

  • Reconstructs a `mem_tx` transaction whenever `valid_i && ready_o` is seen

  • Broadcasts observed transactions via `uvm_analysis_port #(mem_tx) ap_port`, fanning out to both the scoreboard and coverage collector

### ✔ Scoreboard — mem_scb.sv
  • Extends `uvm_scoreboard`; receives transactions via `uvm_analysis_imp #(mem_tx, mem_scb)`

  • Maintains an associative-array reference model (`mem[*]`) — updated on every observed write

  • On every observed read, compares `rdata_o` against the reference model and updates `common::matching` / `common::mismatching`

  • `report_phase` prints the final matching/mismatching tally via `` `uvm_info ``

### ✔ Coverage — mem_cov.sv
  • Extends `uvm_subscriber #(mem_tx)`, connected directly to the monitor's analysis port

  • Samples a covergroup on every transaction seen by the monitor

### ✔ Environment — mem_env.sv
  • Extends `uvm_env`; instantiates the agent and scoreboard

  • Connects `agent.mon.ap_port` → `scb.ap_imp`

### ✔ Test Layer — mem_test.sv
  • Base `mem_test` extends `uvm_test`, builds the environment, and prints the UVM topology at `end_of_elaboration_phase`

  • **wr_test / nwr_test:** explicitly construct and `start()` their sequence on `env.agent.sqr` during `run_phase`

  • **wr5_test / wr_rd_test / wr5_rd5_test:** register their sequence as the sequencer's `default_sequence` via `uvm_config_db`

  • **nwr_nrd_test:** N-writes-then-N-reads regression test, run by default from `mem_top.sv`

### ✔ Top Module — mem_top.sv
  • Instantiates the interface and DUT, generates clock/reset

  • Publishes the virtual interface to the environment via `uvm_config_db#(virtual mem_intf)::set(...)`

  • Kicks off simulation with `run_test("nwr_nrd_test")`

## Interface & Protocol Checking — mem_intf.sv
The interface doesn't just wire up signals — it actively checks the protocol using embedded SVA.

### ✔ Clocking Blocks
  • **mon_cb:** sampling-only view for the Monitor (non-intrusive, all inputs, skewed sampling on `valid_i`/`ready_o`)

  • **drv_cb:** driving view for the Driver (drives outputs to the DUT, skewed sampling on `ready_o`)

### ✔ Sequences & Properties
  • **ready_valid:** `valid_i ##1 ready_o` — captures the DUT's 1-cycle registered handshake latency

  • **wr_addr_unknown / wr_data_unknown:** during an active write (`valid_i && wr_rd_i`), `addr_i`/`wdata_i` must be a known value (not X)

  • **rd_addr_unknown:** during an active read (`valid_i && !wr_rd_i`), `addr_i` must be a known value

  • **rd_data_unknown:** one cycle after an active read request, `ready_o` must be high and `rdata_o` must be a known value — the `##1` accounts for the DUT's registered read latency

  • All properties are qualified with `valid_i` so idle bus cycles (no active transaction) are correctly excluded from the check, and `disable iff(rst)` suppresses checking during reset

  • Any violation fires an assertion error — protocol checking runs live during simulation

## Functional Coverage
### ✔ Coverpoints (mem_cov.sv)
  • **WR_RD:** 2 explicit bins — HIGH (write), LOW (read)

  • **ADDR:** auto-binned (`auto_bin_max = 4`) across the full address range

  • **WR_RD_X_ADDR:** cross of WR_RD × ADDR, ensuring every operation type is exercised across every address region

## Shared Configuration
### ✔ mem_common.sv
  • `` `DEPTH ``, `` `WIDTH ``, `` `ADDR_WIDTH `` macros configure the DUT/testbench sizing

  • `common` class holds `N` (transaction count for N-based sequences) and the scoreboard's `matching` / `mismatching` / `drv_count` counters

### ✔ mem_config.sv
  • `` `NEW_COMP `` / `` `NEW_OBJ `` macros generate the boilerplate `new()` constructors for UVM components and objects respectively, keeping every class body free of repeated constructor code

## File Structure
  • **mem_dut.v** — Parameterized synchronous memory (DUT, Verilog)

  • **mem_intf.sv** — Interface, clocking blocks, sequences, SVA properties/assertions

  • **mem_tx.sv** — UVM sequence item (transaction)

  • **mem_seq_lib.sv** — UVM sequences (write/read/regression scenarios)

  • **mem_seqr.sv** — UVM sequencer (typedef of `uvm_sequencer #(mem_tx)`)

  • **mem_drv.sv** — UVM driver

  • **mem_mon.sv** — UVM monitor

  • **mem_agent.sv** — UVM agent (bundles sequencer + driver + monitor + coverage)

  • **mem_cov.sv** — Functional coverage subscriber

  • **mem_scb.sv** — UVM scoreboard (reference-model checker)

  • **mem_env.sv** — Top-level UVM environment

  • **mem_test.sv** — UVM test classes (per-scenario test selection)

  • **mem_top.sv** — Testbench top: clock/reset gen, interface-DUT binding, `run_test()`

  • **mem_common.sv** — Sizing macros + shared config/counters class

  • **mem_config.sv** — Constructor boilerplate macros

  • **list.svh** — File list / compile order for vlog

  • **run.do** — QuestaSim/ModelSim simulation script

  • **wave.do** — Waveform signal-list script

  • **LICENSE** — MIT License

## How to Run (QuestaSim / ModelSim)
### ✔ run.do script
```
vlib work
vlog list.svh
vopt top +cover=fcbest -o N_WRITE_N_READ
vsim -assertdebug -coverage N_WRITE_N_READ -l mem.log -sv_seed 85132
vsim -novopt -suppress 12110 top -l mem.log
coverage save -onexit N_WRITE_READ.ucdb
do wave.do
run -all
```
### ✔ Steps
  • ***From the QuestaSim/ModelSim console, in the repo directory, run:***

--------> do run.do

  • ***This will:***

--------> Create the work library and compile all sources listed in list.svh
--------> Optimize the design with coverage instrumentation (+cover=fcbest)
--------> Launch simulation with assertion debug and a fixed random seed for reproducibility
--------> Load the waveform signal list from wave.do
--------> Run `nwr_nrd_test` to completion, driven from `mem_top.sv`'s `run_test()` call
--------> Save the coverage database

  • ***To select a different test, override the test name when invoking simulation:***

--------> vsim ... top +UVM_TESTNAME=wr5_rd5_test

  • ***To view coverage afterward:***

--------> vsim -viewcov N_WRITE_READ.ucdb
