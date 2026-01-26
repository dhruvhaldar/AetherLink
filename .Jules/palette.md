## 2024-10-24 - CLI Output Polish
**Learning:** Even in system-level languages like Ada, developers appreciate visual hierarchy and color. Adding a Hex Dump to packet simulations bridges the gap between high-level logic and low-level debugging, significantly improving DX.
**Action:** Look for opportunities to visualize invisible data (like bytes) in CLI tools.

## 2024-10-25 - Data Visualization Clarity
**Learning:** Raw hex dumps are mentally taxing to parse. Adding a synchronized ASCII view provides immediate context for text-based payloads without sacrificing the precision of the hex view.
**Action:** Always pair hex dumps with ASCII representations in CLI tools.

## 2024-10-26 - Visual Hierarchy in CLI
**Learning:** In dense data displays (like hex dumps), using distinct colors for metadata (offsets) vs. content reduces cognitive load and improves scannability.
**Action:** Use dimmed or distinct colors for line numbers, offsets, and separators in CLI output.

## 2024-10-27 - Emojis in Low-Level CLI
**Learning:** Adding emojis to system-level CLI tools (like satellite sims) makes them feel modern and reduces intimidation, but requires careful handling of string encodings in strict languages like Ada.
**Action:** Use emojis as status indicators (📦, ✅, ❌) but ensure the build system or string handling supports UTF-8 bytes transparently.

## 2024-10-28 - Bridging High and Low Level Views
**Learning:** Displaying hex values alongside high-level decimal fields (like IDs and Sequences) helps users mentally map the structured data to the raw hex dump, reducing cognitive load during debugging.
**Action:** Annotate key integer fields in CLI output with their hex representation, especially when a hex dump is also provided.
