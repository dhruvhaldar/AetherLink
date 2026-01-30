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

## 2024-10-28 - Reducing Visual Noise in Hex Dumps
**Learning:** High-contrast placeholders (like bright `.` for non-printable chars) compete with actual data. Dimming them shifts focus to the meaningful ASCII content.
**Action:** Use dimmed colors (ANSI `\e[90m`) for placeholders and structural separators to let the data shine.

## 2024-10-29 - Actionable Error States
**Learning:** Generic "Success/Fail" booleans in low-level APIs force the UI to be vague ("Operation Failed"). Returning specific status enums allows the CLI to give actionable feedback (e.g., "Checksum Error" vs "Buffer Underflow"), turning a frustrating debugging session into a quick fix.
**Action:** Replace `Boolean` success flags with specific `Status` enums in public APIs to enable rich error reporting.

## 2024-10-30 - Human-Readable Enum Mapping
**Learning:** Printing raw enum values (like `CHECKSUM_ERROR`) in CLI tools is functional but hostile to non-experts.
**Action:** Implement helper functions (e.g., `Get_Status_Message`) to map enums to full sentences with context/recovery hints.
