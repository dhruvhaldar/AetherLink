## 2024-05-22 - Ada Constrained Array Slice Assignment
**Learning:** Assigning a slice of an unconstrained array (e.g., `Buffer` from `Byte_Array`) to a slice of a constrained array (e.g., `P.Payload` from `Payload_Data_Type`) is difficult in Ada 2012 without a loop. The target type's fixed length constraints prevent direct type conversion of a shorter slice, and view conversions on the LHS require identical index types, which `Positive` (Buffer) and `Unsigned_8` (Payload) do not match.
**Action:** When optimizing Ada code, favor unconstrained array types for data buffers if slicing is needed, or use explicit loops (or `System.Address` overlays) for copying between incompatible array types if performance is critical and slice assignment is blocked by the type system.

## 2024-05-23 - Ada Slice Assignment Strategy
**Learning:** Assigning a slice of an unconstrained array (Buffer) to a constrained array (Payload) requires an explicit loop because direct conversion fails on bound mismatch. However, the reverse (assigning a constrained slice to an unconstrained buffer) works efficiently with a view conversion (e.g., `Byte_Array(Payload_Slice)`).
**Action:** Use slice assignment with view conversion for Serialize (Payload -> Buffer) optimizations, but fallback to explicit loops for Deserialize (Buffer -> Payload) to avoid constraint errors.

## 2024-05-24 - Ada Inline Optimization
**Learning:** `pragma Inline` on a package specification requires `-gnatn` (cross-unit inlining) to be effective. However, a local nested procedure with `pragma Inline` works efficiently without additional compiler flags, offering significant performance gains in tight loops (e.g., CRC update) while maintaining readability compared to manual inlining.
**Action:** Use local `pragma Inline` procedures for loop bodies instead of modifying global build flags or manually unrolling logic.
