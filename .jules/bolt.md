## 2024-05-22 - Ada Constrained Array Slice Assignment
**Learning:** Assigning a slice of an unconstrained array (e.g., `Buffer` from `Byte_Array`) to a slice of a constrained array (e.g., `P.Payload` from `Payload_Data_Type`) is difficult in Ada 2012 without a loop. The target type's fixed length constraints prevent direct type conversion of a shorter slice, and view conversions on the LHS require identical index types, which `Positive` (Buffer) and `Unsigned_8` (Payload) do not match.
**Action:** When optimizing Ada code, favor unconstrained array types for data buffers if slicing is needed, or use explicit loops (or `System.Address` overlays) for copying between incompatible array types if performance is critical and slice assignment is blocked by the type system.

## 2024-05-23 - Optimizing CRC Updates with Block Processing
**Learning:** CRC updates in a loop (byte-by-byte) incur significant function call overhead. Implementing a block-update function (`Update(CRC, Byte_Array)`) allows the compiler to optimize the loop (unrolling, pipelining) and reduces call overhead.
**Action:** When processing data streams with checksums, verify if the checksum library supports block updates. If not, add one. Use it to batch updates for contiguous data blocks (headers, payloads).
