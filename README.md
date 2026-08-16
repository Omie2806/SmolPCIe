# PCIe RTL Implementation (Transaction Layer and Data Link Layer)

A SystemVerilog implementation of the PCIe Transaction Layer and Data Link Layer, built to understand and demonstrate how PCIe actually works at the RTL level.
We test Enumeration, Memory and IO requests, rejected Memory and IO requests, Completion generation and corresponding DLL working which includes, ACK timer runout, LCRC Error NAKs and Higher Sequence error NAKs. 
This project covers Bidirectional TL and DLL (**DLL has not been added for completions**)


---

## What This Project Does

A miniature PCIe topology, that is, one Root Complex (RC) and one Endpoint implemented at the RTL level(TL/DLL scope).

The RC can:
- Enumerate(initialize is simple words) the endpoint (probe Vendor/Device ID, size and assign all BARs)
- Issue Configuration, Memory, I/O Read/Write requests and messages
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


## Brief PCIe Layer Overview
### Transaction Layer:
This layer is responsible for encoding or decoding the information the Root/Device wants to convey.
- It receiver information like the device to target, the transaction type, payload, etc from the software/core.
- Then it encodes the received information in headers and payloads and together they form a Transaction Layer Packet (TLP).
- This TLP is then passed to the Data Link Layer and to the Physical Layer for addition of error detection fields and other fields required for transmission
- The receiver does the exact opposite of this, the TLP is passed from the PHY and DL layers to the TL. There, the TLP gets decoded and processed.
- The Receiver may issue Completions depending upon the Request Type (like posted and non-posted).

### Data Link Layer:
This layer prepares the TLP for error detection at the receiver side and attaches a sequence number for it's identification.
- The DLL Transmitter attaches an LCRC field to the TLP and a sequence number for error detection
- Then the TLP is stored in a Replay buffer which holds these TLPs incase the receiver would output and error in the TLP(NAK)
- ACKs and NAKs clear the contents of the replay buffer and NAKs cause a replay of the TLPs which had errors
- Replays happen depending upon the Sequence Number of the TLP, the Sequence Number for which NAK was received gets cleared along with the TLPs with older Sequence numbers and the Next TLPs in the Buffer get replayed.
- ACK clears the contents of the Buffer depending upon the sequence number and the older TLPs get cleared too.
- The Receiver Checks for errors like data corruption, wrong sequence numbers, etc
- It issues ACKs and NAKs based on the status of the errors to the Transmitter
- The receiver sends Data Link Layer Packects (DLLPs) to convey ACKs/NAKs (DLLPs are issued for other purposes too but it's out of scope here)
- The transmitter decodes these DLLPs

  <img width="1002" height="623" alt="image" src="https://github.com/user-attachments/assets/01b79762-a425-4a8a-9c85-b30d42c48b96" />

**I highly suggest you to read the RTL of DLL side by side to understand this**

**PHY Layer is not a part of this project**
---

## Simplifications made
- Assumed memory accesses to always be DW aligned
- Did not use different clocks for the Root and Device (hence the REPLAY_TIMER never expires)
- Completion side DLL is still pending
- Flow control is also pending
- Error Testing has been thoroughly done for DLL but is still pending for the complete side (see DLL tests folder)
- I've used directed testbenches to prove basic error detection and robustness but I might need formal verification before expanding this further
- Drift checking of SEQUENNCE NUMBERS in the Replay Buffer has been skipped (same clock so no drift should happen)
- DLLP CRC Check is also remaining


---


---

## Running the Simulation

```bash
simply compile and view the waveforms on Vivado
```


## Reference

*PCI Express Technology 3.0* (MindShare Inc.) — chapters on architecture overview, address space & transaction routing, TLP elements, DLLP elements, and the Ack/Nak protocol (till chapter 10).*

*PCIe 3.0 Spec sheet.*
