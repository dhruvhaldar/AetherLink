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
