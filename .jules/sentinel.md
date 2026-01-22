# Sentinel Journal

## 2024-05-22 - Initial Setup
**Learning:** This journal tracks critical security learnings.
**Prevention:** Use this file to record unique security insights.

## 2024-05-22 - Integer Overflow in Buffer Checks
**Vulnerability:** A bounds check `Index + Len + 2 > Buffer'Last + 1` caused `Constraint_Error` when `Buffer` was located at the end of memory (`Positive'Last`), as `Buffer'Last + 1` overflowed.
**Learning:** In Ada, always be wary of `+ 1` on array indices that might be at the upper bound of the index type. `Buffer'Last` can be `Positive'Last`.
**Prevention:** Use subtraction for bounds checks: check `Needed <= Available` (e.g., `Len + 2 <= Buffer'Last - Index + 1`) instead of calculating `End_Pointer > Buffer'End`. Ensure the subtraction doesn't underflow.

## 2024-05-23 - Stale Data Leakage in Packet Deserialization
**Vulnerability:** Reusing a `Packet` record for `Deserialize` left previous payload data intact beyond the new packet's `Length`. This could leak sensitive data if the consumer ignores `Length` or if the memory is dumped.
**Learning:** Ada records/arrays are not automatically cleared. Partial updates leave stale data.
**Prevention:** Explicitly zero-initialize the unused portion of the payload buffer during deserialization to ensure "clean" state (Defense in Depth).
