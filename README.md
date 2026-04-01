# AXI4-Lite Slave Design & Verification 

# Overview
This project implements an AXI4-Lite Slave using Verilog and verifies its functionality using a SystemVerilog-based testbench. The design supports read and write transactions through a finite state machine (FSM) and follows the AXI handshake protocol. A layered verification environment is used to generate, drive, monitor, and validate transactions.

# Key Features
1. FSM-based AXI4-Lite slave design
2. Supports all 5 AXI-Lite channels (AW, W, B, AR, R)
3. 128 × 32-bit internal memory
4. Valid/Ready handshake implementation
5. Error handling for invalid addresses
6. Constrained-random stimulus generation
7. Self-checking testbench with scoreboard
   
# Design Architecture
-> AXI4-Lite Channels
1. Write Address Channel (AW)
2. Write Data Channel (W)
3. Write Response Channel (B)
4. Read Address Channel (AR)
5. Read Data Channel (R)

# FSM States
1. IDLE – Wait for transaction
2. SEND_WADDR_ACK – Accept write address
3. SEND_WDATA_ACK – Accept write data
4. UPDATE_MEM – Store data in memory
5. SEND_WR_RESP – Send write response
6. SEND_WR_ERR – Handle write error
7. SEND_RADDR_ACK – Accept read address
8. GEN_DATA – Prepare read data
9. SEND_RDATA – Send read data
10. SEND_RD_ERR – Handle read error

# Verification Environment

The testbench follows a layered architecture:
# Components
1. Transaction → Defines AXI operations with constraints
2. Generator → Produces randomized transactions
3. Driver → Drives signals to DUT
4. Monitor → Captures DUT activity
5. Scoreboard → Verifies correctness using reference model
6. Interface (axi_if) → Connects DUT and TB
-> Communication
1.Mailboxes used for data transfer
2.Events used for synchronization

```
axi-lite/
 ├── design/
 │    └── axi_lite_slave
 ├── tb/
 │    ├── axi_if.sv
 │    ├── transaction.sv
 │    ├── generator.sv
 │    ├── driver.sv
 │    ├── monitor.sv
 │    ├── scoreboard.sv
 │    └── tb_top.sv
 └── README.md
```

# Expected Output
1. Successful write and read transactions
2. Correct handshake behavior
3. Data match between DUT and scoreboard
4. Error detection for invalid addresses
# Learning Outcomes
1. Understanding of AXI4-Lite protocol
2. FSM-based RTL design
3. Constrained-random verification
4. Testbench architecture (generator-driver-monitor-scoreboard)
5. Debugging using waveforms



