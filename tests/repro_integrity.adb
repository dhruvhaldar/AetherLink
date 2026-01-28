with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Repro_Integrity is
   Rx_Packet : Packet;
   --  Buffer for a minimal valid packet:
   --  ID(1) + Seq(2) + Len(1) + Payload(1) + Checksum(2) = 7 bytes
   Buffer    : Byte_Array (1 .. 7);
   Status    : Packet_Status;

begin
   Put_Line ("=== Reproduction Test: Integrity Check Bypass ===");

   --  Construct a packet manually
   Buffer(1) := 1;          -- ID
   Buffer(2) := 0;          -- Seq Hi
   Buffer(3) := 1;          -- Seq Lo
   Buffer(4) := 1;          -- Length (1 byte payload)
   Buffer(5) := 16#AA#;     -- Payload (0xAA)

   --  Checksum: Set to ARBITRARY value (e.g., 0x0000)
   --  Ideally, a secure system should REJECT this because checksum doesn't match payload.
   Buffer(6) := 0;
   Buffer(7) := 0;

   Put_Line ("Deserializing packet with INVALID checksum...");
   Deserialize (Buffer, Rx_Packet, Status);

   if Status = Success then
      Put_Line ("VULNERABILITY CONFIRMED: Packet accepted despite invalid checksum.");
   else
      Put_Line ("SECURE: Packet rejected due to invalid checksum.");
   end if;

end Repro_Integrity;
