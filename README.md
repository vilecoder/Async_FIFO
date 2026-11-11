# Asynchronous FIFO (Verilog)

A parameterized asynchronous FIFO that safely moves data between two unrelated clock domains: a **100 MHz write clock** and a **40 MHz read clock**. Written in Verilog and built in Xilinx Vivado.

## Architecture

![Asynchronous FIFO block diagram](docs/Async_FIFO_architecture.jpg)

Data is stored in a dual-port memory. Each side keeps its own pointer, and the two pointers are exchanged through double-flop synchronizers to produce the FULL and EMPTY flags.

| Module | Role |
|---|---|
| `fifo_mem_cntrl` | Dual-port memory. Clocked write, combinational read. |
| `fifo_wr` | Write pointer, write address, and FULL flag (write clock domain). |
| `fifo_rd` | Read pointer, read address, and EMPTY flag (read clock domain). |
| `DF_sync` | Double-flop synchronizer. Two instances: write pointer to read domain, and read pointer to write domain. |
| `async_fifo` | Top module that connects everything. |

## Ports

| Signal | Direction | Width | Description |
|---|---|---|---|
| `w_clk` | input | 1 | Write (source) domain clock |
| `w_rstn` | input | 1 | Write domain async reset, active low |
| `w_inc` | input | 1 | Write request |
| `w_data` | input | `data_width` | Write data bus |
| `r_clk` | input | 1 | Read (destination) domain clock |
| `r_rstn` | input | 1 | Read domain async reset, active low |
| `r_inc` | input | 1 | Read request |
| `r_data` | output | `data_width` | Read data bus |
| `full` | output | 1 | FIFO full flag |
| `empty` | output | 1 | FIFO empty flag |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `data_width` | 8 | Width of the data bus |
| `A_size` | 3 | Address width. Depth is `2^A_size` (8 locations). Pointers are `A_size + 1` bits wide. |

## Design details

### Gray-coded pointers
The write and read pointers must cross into the other clock domain. A binary counter can change several bits at once (for example `0111` to `1000`), so a synchronizer sampling it at the wrong moment could capture a value that never existed. In Gray code only one bit changes per increment, so the synchronizer can only capture the old pointer or the new one. At worst, FULL or EMPTY reacts a cycle or two late, which is safe.

### Extra wrap bit
Each pointer has one more bit than the address needs. The lower `A_size` bits form the memory address. The top bit records which lap around the memory the pointer is on. This distinguishes a full FIFO from an empty one, since in both cases the address bits of the two pointers are equal.

### Flag generation
- **EMPTY:** the next read pointer (Gray) equals the synchronized write pointer.
- **FULL:** the next write pointer (Gray) has its top two bits inverted and all remaining bits equal to the synchronized read pointer.

Both flags are registered and computed from the *next* pointer value, so they change in the same cycle the FIFO becomes full or empty. Writes are ignored while FULL, and reads are ignored while EMPTY. After reset, `empty = 1` and `full = 0`.

### Double-flop synchronizer
Two flip-flops in series, both on the destination clock, with no logic between them. The first flop may go metastable, and the second samples it one clock later, after it has settled. Each domain's reset is applied to the synchronizer that runs on that domain's clock.

## FIFO depth calculation

Specification: write 9 bytes in a burst at 100 MHz, read at 40 MHz.

| Quantity | Value |
|---|---|
| Write period | 10 ns |
| Burst duration (9 bytes) | 9 x 10 ns = 90 ns |
| Read period | 25 ns |
| Bytes the reader can drain during the burst | 90 / 25 = 3.6, so 3 (rounded down) |
| Bytes left in the FIFO at the end of the burst | 9 - 3 = **6** |

The minimum depth is 6, but the depth must be a power of two. The pointers wrap by counting up and the address is the low bits of the pointer, so a depth of 6 would leave addresses 6 and 7 pointing at memory that does not exist. Gray-code single-bit stepping and the FULL comparison also rely on the wrap happening at a power of two.

The next power of two is **8**, so `A_size = 3` and the pointers are 4 bits. The two spare locations also give margin for the synchronizer latency, which delays the moment the reader sees data (about two read clocks).

## Testbench

The testbench drives a 100 MHz write clock (10 ns period) and a 40 MHz read clock (25 ns period), writes 9 bytes, and reads them back, checking the data and the FULL and EMPTY flags.

<!-- Add your waveform screenshot to docs/ and update the filename below -->
![Simulation waveform](docs/waveform.png)

<!-- Add your actual result here, for example: "All 9 bytes read back in order, no overflow, FULL/EMPTY behave as expected." -->

## Running the simulation

1. Open the project in Vivado (`Async_FIFO.xpr`).
2. Set the testbench as the simulation top module.
3. Run **Simulation > Run Behavioral Simulation**.

## Tools

- Verilog HDL
- Xilinx Vivado
