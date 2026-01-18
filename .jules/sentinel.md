## 2024-05-22 - Unverified Checksum Field
**Vulnerability:** The `Packet` structure contained a `Checksum` field, and `Serialize`/`Deserialize` operations read/wrote it, but no validation logic existed. Trusting the field without verification allows data tampering.
**Learning:** Presence of security fields (like Checksum/Signature) does not imply they are being used or verified.
**Prevention:** Always verify that security-critical fields are actively computed and checked, not just passed through.
