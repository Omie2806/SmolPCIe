# PCIe RTL Implementation (Transaction Layer)

A SystemVerilog implementation of the PCIe Transaction Layer, built to understand and demonstrate how PCIe actually works at the RTL level. We start from TLP encoding/decoding through enumeration, address decode, and completion handling.

This project is built to demonstrate how PCIe works at hardware level. 

> **Status:** Transaction Layer (TL) complete, bidirectional, and verified.
- Data Link Layer (DLL): Ack/Nak, replay buffer, flow control **not yet implemented**.

---

## What This Project Does

A miniature PCIe topology, that is, one Root Complex (RC) and one Endpoint implemented at the RTL level(TL/DLL scope; PHY is abstracted out).

The RC can:
- Enumerate(initialize is simple words) the endpoint (probe Vendor/Device ID, size and assign all BARs)
- Issue Configuration, Memory,I/O Read/Write requests and messages
- Decode returned Completions (status, tag, data)

The Endpoint can:
- Respond to Configuration Read/Write requests against a modeled config space
- Support BAR sizing via the real all-1s-write / read-back mechanism (assign an Address range to the internal memories which can be globally accessed)
- Decode and service Memory (32-bit and 64-bit addressed) and I/O requests
- Support multi-DWord burst reads/writes (1–1024 DW, per the TLP Length field encoding)
- Generate spec-correct Completion TLPs (CplD / Cpl) for all non-posted request types (completion failure support will be added with DLL)

---

## Architecture

# PCIe RTL Implementation (Transaction Layer)

A SystemVerilog implementation of the PCIe Transaction Layer, built to understand and demonstrate how PCIe actually works at the RTL level. We start from TLP encoding/decoding through enumeration, address decode, and completion handling.

This project is built to demonstrate how PCIe works at hardware level. 

> **Status:** Transaction Layer (TL) complete, bidirectional, and verified.
- Data Link Layer (DLL): Ack/Nak, replay buffer, flow control **not yet implemented**.

---

## What This Project Does

A miniature PCIe topology, that is, one Root Complex (RC) and one Endpoint implemented at the RTL level(TL/DLL scope; PHY is abstracted out).

The RC can:
- Enumerate(initialize is simple words) the endpoint (probe Vendor/Device ID, size and assign all BARs)
- Issue Configuration, Memory,I/O Read/Write requests and messages
- Decode returned Completions (status, tag, data)

The Endpoint can:
- Respond to Configuration Read/Write requests against a modeled config space
- Support BAR sizing via the real all-1s-write / read-back mechanism (assign an Address range to the internal memories which can be globally accessed)
- Decode and service Memory (32-bit and 64-bit addressed) and I/O requests
- Support multi-DWord burst reads/writes (1–1024 DW, per the TLP Length field encoding)
- Generate spec-correct Completion TLPs (CplD / Cpl) for all non-posted request types (completion failure support will be added with DLL)

---

## Architecture

<img width="940" height="473" alt="image" src="https://github.com/user-attachments/assets/8c94cad8-e924-4aef-a497-7d15a31ce815" />


### Module Overview

| Module | Role |
|---|---|
| `TLP_Header_encoder` | RC-side: packs intent (request type, target, address, data) into a spec-correct TLP header |
| `TLP_Decoder` | Endpoint-side: parses an incoming TLP header, dispatches by Fmt/Type |
| `device_1` | Endpoint core: configuration space (with BAR masking), Mem/IO storage, BAR-relative address decode, burst state machine |
| `completion_gen` | Endpoint-side: packs a Completion (Cpl/CplD) header |
| `Completer_Decoder` | RC-side: parses an incoming Completion header (status, tag, byte count, data) |
| `top_decoder_device` | Endpoint-side integration (decoder + device + completion generator) |
| `top_Decoder_Encoder` | RC-side integration (encoder + completion decoder) |

---

## What's Implemented

**Transaction Layer — Receive path (Endpoint)**
- [x] TLP Fmt/Type decode for Config (Type 0/1), Memory (32/64-bit), I/O, Completion
- [x] Configuration space model: Vendor/Device ID, BAR0–BAR3, correct per-BAR hardwired-zero write masking
- [x] BAR sizing via all-1s-write/read-back, verified for 32-bit Mem, 64-bit Mem, and I/O BARs
- [x] BAR-relative address decode (converts absolute wire address → local storage offset)
- [x] Multi-DWord burst read/write (Length field, including the "0 encodes 1024" case)
- [x] Completion generation (CplD for reads, Cpl for writes), gated so posted writes (Memory Write) never generate a completion

**Transaction Layer — Transmit path (RC)**
- [x] TLP header generation for Config Read/Write (Type 0), Memory Read/Write (32/64-bit), I/O Read/Write
- [x] Completion decode (status, tag, byte count, requester ID, data)

**Verification**
- [x] Directed simulation testbenches for enumeration, BAR sizing (all 4 BAR types), multi-DW Mem/IO read/write, out-of-range address rejection

**Not yet implemented**
- [ ] Data Link Layer — LCRC, sequence numbers, Ack/Nak DLLPs, replay buffer, replay timer
- [ ] Credit-based flow control
- [ ] Switch / multi-endpoint topology, multi-hop routing
- [ ] Byte-enable-aware partial-DWord writes (currently full-DWord-only, see below)
- [ ] Physical Layer (intentionally out of scope — see below)
- [ ] Message TLPs (decode dispatch exists, field handling deferred)

---

## Scope & Simplifications

Deliberate, documented simplifications made to keep the project tractable without giving up correctness on what *is* implemented:

- **PCIe generation:** TL/DLL scoped to Gen1/Gen2 semantics (8b/10b era). These layers barely change across generations; Gen6's FLIT-mode restructuring and mandatory FEC are out of scope.
- **Physical Layer:** entirely abstracted out. No SerDes/PHY modeling — PHY-layer faults (when DLL fault injection is added) will be modeled behaviorally (e.g. injected bit errors manifesting as LCRC failures), not at the signaling level.
- **Byte enables:** every transaction is currently assumed full-DWord-width (First/Last DW Byte Enables = `1111`). Byte-level partial writes are decoded but not yet acted on in the data path.
- **Single outstanding request:** the RC's Tag is currently hardwired to 0 that means, only one request is in flight at a time. Real tag tracking (needed for concurrent outstanding requests) is not yet implemented.
- **No Max Payload Size negotiation / completion splitting:** a single completion currently carries the full requested length; MPS-based completion splitting is not modeled.
- **Topology:** one RC, one Endpoint. No switch so Type 1 Configuration Requests (used for switch-crossing config traffic) are decoded but never actually generated or exercised.

---


---

## Running the Simulation

```bash
simply compile and view the waveforms on Vivado
```

Testbenches are directed (not randomized/scoreboard-based yet) and step through: reset → enumeration (Vendor ID probe, BAR sizing + base assignment for all 4 BARs) → Memory read/write (including multi-DW and out-of-range rejection) → I/O read/write.


## Roadmap

1. **Data Link Layer** — LCRC, sequence numbering, Ack/Nak DLLP exchange, replay buffer + replay timer, credit-based flow control. This is where the project moves from stateless request/response correctness to reasoning about concurrent, timing-sensitive, fault-recovering hardware state — error injection (corrupted LCRC, dropped DLLPs, forced timeouts, credit exhaustion) will be used to verify recovery behavior.
2. **Switch support** — address/ID-based TLP routing across multiple downstream ports, Type 1 Configuration Request handling, transaction ordering across ports.
3. **Board-deployable top-level** — on-chip sequencer or UART-based injection, real board I/O only.

---


## Reference

*PCI Express Technology 3.0* (MindShare Inc.) — chapters on architecture overview, address space & transaction routing, TLP elements, DLLP elements, and the Ack/Nak protocol (till chapter 5).

### Module Overview

| Module | Role |
|---|---|
| `TLP_Header_encoder` | RC-side: packs intent (request type, target, address, data) into a spec-correct TLP header |
| `TLP_Decoder` | Endpoint-side: parses an incoming TLP header, dispatches by Fmt/Type |
| `device_1` | Endpoint core: configuration space (with BAR masking), Mem/IO storage, BAR-relative address decode, burst state machine |
| `completion_gen` | Endpoint-side: packs a Completion (Cpl/CplD) header |
| `Completer_Decoder` | RC-side: parses an incoming Completion header (status, tag, byte count, data) |
| `top_decoder_device` | Endpoint-side integration (decoder + device + completion generator) |
| `top_Decoder_Encoder` | RC-side integration (encoder + completion decoder) |

---

## What's Implemented

**Transaction Layer — Receive path (Endpoint)**
- [x] TLP Fmt/Type decode for Config (Type 0/1), Memory (32/64-bit), I/O, Completion
- [x] Configuration space model: Vendor/Device ID, BAR0–BAR3, correct per-BAR hardwired-zero write masking
- [x] BAR sizing via all-1s-write/read-back, verified for 32-bit Mem, 64-bit Mem, and I/O BARs
- [x] BAR-relative address decode (converts absolute wire address → local storage offset)
- [x] Multi-DWord burst read/write (Length field, including the "0 encodes 1024" case)
- [x] Completion generation (CplD for reads, Cpl for writes), gated so posted writes (Memory Write) never generate a completion

**Transaction Layer — Transmit path (RC)**
- [x] TLP header generation for Config Read/Write (Type 0), Memory Read/Write (32/64-bit), I/O Read/Write
- [x] Completion decode (status, tag, byte count, requester ID, data)

**Verification**
- [x] Directed simulation testbenches for enumeration, BAR sizing (all 4 BAR types), multi-DW Mem/IO read/write, out-of-range address rejection

**Not yet implemented**
- [ ] Data Link Layer — LCRC, sequence numbers, Ack/Nak DLLPs, replay buffer, replay timer
- [ ] Credit-based flow control
- [ ] Switch / multi-endpoint topology, multi-hop routing
- [ ] Byte-enable-aware partial-DWord writes (currently full-DWord-only, see below)
- [ ] Physical Layer (intentionally out of scope — see below)
- [ ] Message TLPs (decode dispatch exists, field handling deferred)

---

## Scope & Simplifications

Deliberate, documented simplifications made to keep the project tractable without giving up correctness on what *is* implemented:

- **PCIe generation:** TL/DLL scoped to Gen1/Gen2 semantics (8b/10b era). These layers barely change across generations; Gen6's FLIT-mode restructuring and mandatory FEC are out of scope.
- **Physical Layer:** entirely abstracted out. No SerDes/PHY modeling — PHY-layer faults (when DLL fault injection is added) will be modeled behaviorally (e.g. injected bit errors manifesting as LCRC failures), not at the signaling level.
- **Byte enables:** every transaction is currently assumed full-DWord-width (First/Last DW Byte Enables = `1111`). Byte-level partial writes are decoded but not yet acted on in the data path.
- **Single outstanding request:** the RC's Tag is currently hardwired to 0 that means, only one request is in flight at a time. Real tag tracking (needed for concurrent outstanding requests) is not yet implemented.
- **No Max Payload Size negotiation / completion splitting:** a single completion currently carries the full requested length; MPS-based completion splitting is not modeled.
- **Topology:** one RC, one Endpoint. No switch so Type 1 Configuration Requests (used for switch-crossing config traffic) are decoded but never actually generated or exercised.

---


---

## Running the Simulation

```bash
simply compile and view the waveforms on Vivado
```

Testbenches are directed (not randomized/scoreboard-based yet) and step through: reset → enumeration (Vendor ID probe, BAR sizing + base assignment for all 4 BARs) → Memory read/write (including multi-DW and out-of-range rejection) → I/O read/write.


## Roadmap

1. **Data Link Layer** — LCRC, sequence numbering, Ack/Nak DLLP exchange, replay buffer + replay timer, credit-based flow control. This is where the project moves from stateless request/response correctness to reasoning about concurrent, timing-sensitive, fault-recovering hardware state — error injection (corrupted LCRC, dropped DLLPs, forced timeouts, credit exhaustion) will be used to verify recovery behavior.
2. **Switch support** — address/ID-based TLP routing across multiple downstream ports, Type 1 Configuration Request handling, transaction ordering across ports.
3. **Board-deployable top-level** — on-chip sequencer or UART-based injection, real board I/O only.

---


## Reference

*PCI Express Technology 3.0* (MindShare Inc.) — chapters on architecture overview, address space & transaction routing, TLP elements, DLLP elements, and the Ack/Nak protocol (till chapter 5).
