# Configurable Memory Controller IP 💾

This project implements a **parameterized Memory Controller IP** using **SystemVerilog**, following **ASIC and SoC design principles** for modularity, synthesizability, and realistic on-chip memory behaviour.  
It models burst-based read/write transactions, configurable latency, and address protection, while integrating a **UVM-inspired verification flow** and **Perl-based automation** for regression reporting.

---

## Technologies Used

- **SystemVerilog:** RTL design and testbench development  
- **Intel Quartus Prime:** Synthesis, simulation, and waveform analysis  
- **Perl Scripting:** Regression automation, log parsing, and HTML/CSV report generation  
- **ASIC & SoC Design Methodology:** Ready/valid handshake, latency modelling, and modular IP hierarchy  
- **UVM Concepts:** Transaction-based verification using driver/monitor/scoreboard architecture  

---

## Features

**Configurable Architecture:**  
- Parameterized data width, memory depth, and programmable latency cycles  
- Synthesizable RTL suitable for FPGA or ASIC implementation  

**Burst Read/Write Transactions:**  
- Incrementing bursts modelled after AXI-lite protocol behaviour  
- Independent read and write state machines with ready/valid handshakes  

**Address Protection:**  
- Validates address ranges; generates error responses for out-of-range access  

**UVM-Inspired Verification:**  
- Self-checking testbench with scoreboard-style validation  
- Automated simulation logs converted into structured CSV and HTML reports  

**Automation & Reporting:**  
- Perl scripts handle simulation runs, regression summaries, and report generation  

---


## 🧠 Overview  

The memory controller manages data transactions between a CPU/bus master and on-chip memory.  
It handles **read and write requests**, applies **latency delays**, checks **address validity**, and generates **response codes** for both successful and invalid transactions.  

This project demonstrates:
- **ASIC & SoC-level RTL design** practices  
- **UVM-style verification methodology**  
- **Automation and reporting** using Perl scripting  


---


## 📊 Example Output  

**Simulation Log Summary:**
```
SUMMARY,READS=13,WRITES=12,ERRORS=0
```

**HTML Report Preview:**  
A clean dashboard summarizing functional verification results (PASS/FAIL), auto-generated via Perl automation.

---

## 🔧 Design Overview  

- Implements **ASIC/SoC-style memory controller** with parameterized RTL.  
- Uses **ready/valid handshake** for synchronization between address, data, and response channels.  
- Emulates realistic **memory latency** and burst transfer sequences.  
- Verified using **self-checking testbench** and automated **Perl regression scripts**.  

---

## 🧱 Design Principles  

- Follows **ASIC and SoC design methodology**: modular, parameterized, and synthesizable RTL.  
- Supports **AXI-lite–style protocol behavior** for seamless SoC integration.  
- Verification setup mirrors **UVM principles** for testbench modularity and reusability.  
- Automation flow aligns with **industry-standard verification regression pipelines**.  

---

## 🧮 Future Improvements  

- Add constrained-random UVM test sequences for randomized verification  
- Integrate functional and code coverage metrics  
- Extend design for multi-port and pipelined memory access  
- Implement parity/ECC logic for data integrity checks  
- Synthesize to FPGA hardware for real-time testing  

---

## 🧠 Learning Outcomes  

This project demonstrates the intersection of **digital design** and **verification engineering**, including:  
- ASIC/SoC RTL design workflows  
- Functional verification using UVM concepts  
- Perl scripting for automation and regression management  
- Synthesis and simulation in Intel Quartus  
- Scalable project hierarchy for real chip design environments  

---

### 🧰 Topics  
systemverilog · asic-design · soc · uvm · perl · rtl · quartus · digital-verification  

