# Sentinel Journal

## 2024-05-22 - Initial Setup
**Learning:** This journal tracks critical security learnings.
**Prevention:** Use this file to record unique security insights.

## 2024-05-22 - Integer Overflow in Buffer Checks
**Vulnerability:** A bounds check `Index + Len + 2 > Buffer'Last + 1` caused `Constraint_Error` when `Buffer` was located at the end of memory (`Positive'Last`), as `Buffer'Last + 1` overflowed.
**Learning:** In Ada, always be wary of `+ 1` on array indices that might be at the upper bound of the index type. `Buffer'Last` can be `Positive'Last`.
**Prevention:** Use subtraction for bounds checks: check `Needed <= Available` (e.g., `Len + 2 <= Buffer'Last - Index + 1`) instead of calculating `End_Pointer > Buffer'End`. Ensure the subtraction doesn't underflow.

## 2024-05-23 - Stale Data Leak in Out Parameters
**Vulnerability:** `Packet_Handler.Deserialize` left the unused portion of the `Packet.Payload` array uninitialized. Since `Packet` is an `out` parameter, calling it with a reused variable resulted in stale data persisting in the upper bytes of the payload.
**Learning:** In Ada, `out` parameters for composite types (like records with arrays) do not guarantee zero-initialization of fields or array elements that are not explicitly assigned. Partial assignment leaves the rest undefined (or stale).
**Prevention:** Explicitly zero-initialize unused buffer areas in `out` parameters, especially when handling fixed-size buffers with variable length data, to prevent information leakage.

## 2024-05-24 - Uninitialized Out Parameters on Early Return
**Vulnerability:** `Packet_Handler.Deserialize` returned early upon validation failure (e.g., buffer too short) without writing to the `out` parameter `P`. This left the entire `Packet` record uninitialized (or containing stale stack data) in the caller's context.
**Learning:** `out` parameters in Ada are not automatically initialized. If a procedure raises an exception or returns early without assigning to them, their value is undefined (potentially sensitive garbage).
**Prevention:** Always initialize `out` parameters to a safe default state (e.g., zeroed) at the very beginning of the procedure, before any validation checks that might cause an early return.
## 2024-05-21 - [Integer Overflow in Unrolled Loops]
**Vulnerability:** CRC16.Update calculation crashed with Constraint_Error when processing buffers at the very end of memory address space (Positive'Last).
**Learning:** Manual loop unrolling combined with fixed increments can overshoot bounds if checked against 'Last - X' but updated by '+ Y', creating an unchecked gap where overflow occurs.
**Prevention:** Guard loop increments near type boundaries, or use 'exit when' conditions to terminate loops before incrementing past the limit.

## 2024-05-25 - [Terminal Injection in CLI Output]
**Vulnerability:** The simulation CLI printed raw packet payloads to the terminal. Malicious payloads containing ANSI escape codes could manipulate the terminal display (Terminal Injection).
**Learning:** Even in "simulation" or CLI tools, outputting untrusted binary data as strings requires sanitization to prevent log spoofing or terminal corruption.
**Prevention:** Implement a `Sanitize` function that replaces non-printable control characters (outside 32-126 range) with a safe placeholder (e.g., `.`) before printing any untrusted string.

## 2024-05-26 - [Integer Overflow in Serialize Index]
**Vulnerability:** `Packet_Handler.Serialize` unconditionally incremented its `Index` variable after writing the final byte. If the output buffer was located at the very end of the memory address space (`Positive'Last`), this increment caused a `Constraint_Error` (Integer Overflow).
**Learning:** Sequential processing loops that maintain a "next available index" pointer must be careful not to increment that pointer past the type's upper bound after the final write, even if the pointer is never used again.
**Prevention:** Avoid the final pointer increment in sequential write operations, or ensure the pointer type has a range larger than the buffer index type (if possible), or assign the `Last` index directly from the current position instead of `Next - 1`.
