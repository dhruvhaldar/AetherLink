## 2024-05-22 - Ada Constrained Array Slice Assignment
**Learning:** Assigning a slice of an unconstrained array (e.g., `Buffer` from `Byte_Array`) to a slice of a constrained array (e.g., `P.Payload` from `Payload_Data_Type`) is difficult in Ada 2012 without a loop. The target type's fixed length constraints prevent direct type conversion of a shorter slice, and view conversions on the LHS require identical index types, which `Positive` (Buffer) and `Unsigned_8` (Payload) do not match.
**Action:** When optimizing Ada code, favor unconstrained array types for data buffers if slicing is needed, or use explicit loops (or `System.Address` overlays) for copying between incompatible array types if performance is critical and slice assignment is blocked by the type system.

## 2024-05-23 - Ada Slice Assignment Strategy
**Learning:** Assigning a slice of an unconstrained array (Buffer) to a constrained array (Payload) requires an explicit loop because direct conversion fails on bound mismatch. However, the reverse (assigning a constrained slice to an unconstrained buffer) works efficiently with a view conversion (e.g., `Byte_Array(Payload_Slice)`).
**Action:** Use slice assignment with view conversion for Serialize (Payload -> Buffer) optimizations, but fallback to explicit loops for Deserialize (Buffer -> Payload) to avoid constraint errors.

## 2024-05-24 - Ada Inline Optimization
**Learning:** `pragma Inline` on a package specification requires `-gnatn` (cross-unit inlining) to be effective. However, a local nested procedure with `pragma Inline` works efficiently without additional compiler flags, offering significant performance gains in tight loops (e.g., CRC update) while maintaining readability compared to manual inlining.
**Action:** Use local `pragma Inline` procedures for loop bodies instead of modifying global build flags or manually unrolling logic.

## 2024-05-24 - Ada Array Zero-Initialization
**Learning:** Replacing an explicit loop `for I in Range loop Arr(I) := 0; end loop;` with aggregate slice assignment `Arr(Range) := (others => 0);` yields massive performance gains (approx 90x for 250 bytes) as the compiler optimizes it to `memset`.
**Action:** Always use aggregate assignment for clearing arrays or slices in Ada.

## 2024-05-24 - Ada Small Block Batching Overhead
**Learning:** Manually batching CRC updates for small blocks (4 bytes) using slice passing was slower than simple repeated function calls. The overhead of slice creation and block function setup (loop, locals) outweighed the savings from reduced function calls. However, enabling global compiler optimizations (`-O3`, `-gnatn`) combined with `pragma Inline` provided a massive speedup (~3.4x) by optimizing the simple calls effectively.
**Action:** Prefer compiler flags (`-O3`, `-gnatn`) and `pragma Inline` over manual batching for small data chunks.

## 2024-05-25 - Redundant Zero-Initialization
**Learning:** Initializing an Ada record with an aggregate assignment (e.g., `P := (..., Payload => (others => 0));`) fully clears all fields. Following this with a second manual zeroing of unused array slices is redundant and costly (approx 25% overhead in deserialization), as the initial assignment already guarantees the state.
**Action:** Trust the initial aggregate assignment for zero-initialization and avoid subsequent redundant clearing loops.

## 2024-05-25 - Avoid Redundant Payload Zeroing
**Learning:** Initializing a large record with an aggregate (e.g., `(..., Payload => (others => 0))`) followed by overwriting the payload with data results in double-writing memory. For high-throughput paths, it is more efficient to initialize scalar fields individually, copy the data, and then zero *only* the remaining unused payload bytes.
**Action:** For large buffers, replace full zero-initialization with partial zeroing of unused space, ensuring strict "Fail Secure" reset on error paths.

## 2024-05-25 - Avoid Reading Back Out Parameters
**Learning:** Reading back from an `out` array parameter (e.g., `Buffer` in `Serialize`) to compute derived values like CRC significantly degrades performance (~13% overhead) compared to using the input source directly. The compiler may not optimize the store-load roundtrip as effectively as register operations on input locals.
**Action:** Compute derived values from input data or local intermediates, ensuring `out` parameters are write-only whenever possible.

## 2024-05-25 - Loop Unrolling Limits
**Learning:** Increasing loop unrolling from 4x to 8x for CRC calculation degraded performance for small packets (due to overhead of the fallback loop logic) and provided no benefit for large packets (likely due to instruction cache or register pressure limits).
**Action:** Stick to moderate unrolling (4x) and focus on removing control flow instructions (like overflow checks) from the hot loop using "Fast Path" guards.
