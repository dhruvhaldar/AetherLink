with Ada.Text_IO; use Ada.Text_IO;
with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;

procedure Repro_Fail_Secure is
   Buffer : Byte_Array (1 .. 1024);
   P      : Packet;
   Status : Packet_Status;

   procedure Reset_Buffer is
   begin
      Buffer := (others => 0);
   end Reset_Buffer;

begin
   Put_Line ("Starting Fail-Secure Reproduction Test...");

   -- Case 1: Payload Length Error
   -- Header: ID=1, Seq=0, Len=10.
   -- Buffer only has header (6 bytes). So it lacks payload.
   Reset_Buffer;
   Buffer(1) := 1; -- ID
   Buffer(2) := 0; Buffer(3) := 0; -- Sequence
   Buffer(4) := 10; -- Length says 10 bytes
   -- CRC would be here, but we fail before CRC check implies full read?
   -- Wait, Deserialize reads header, then checks length vs buffer.
   -- ID=1, Seq=0, Len=10.
   -- Index is 5 (after Len).
   -- Needed: 10 + 2 (checksum) = 12 bytes.
   -- Buffer provided: let's pass slice 1..6.
   -- (6 - 5) + 1 = 2 bytes available.
   -- 12 > 2. Fails.

   Put ("Testing Payload_Length_Error... ");
   Deserialize (Buffer(1 .. 6), P, Status);

   if Status = Payload_Length_Error then
      if P.ID /= 0 then
         Put_Line ("FAILED: P.ID is " & Packet_ID_Type'Image(P.ID) & " (expected 0)");
      else
         Put_Line ("PASSED: P.ID is 0");
      end if;
   else
      Put_Line ("ERROR: Expected Payload_Length_Error, got " & Packet_Status'Image(Status));
   end if;

   -- Case 2: Checksum Error
   -- Valid packet structure, but bad checksum.
   Reset_Buffer;
   Buffer(1) := 2; -- ID
   Buffer(4) := 1; -- Length 1
   Buffer(5) := 16#FF#; -- Payload
   -- Checksum at 6,7. Let's leave them 0.
   -- Real checksum won't be 0.

   Put ("Testing Checksum_Error... ");
   Deserialize (Buffer(1 .. 7), P, Status);

   if Status = Checksum_Error then
      if P.ID /= 0 then
         Put_Line ("FAILED: P.ID is " & Packet_ID_Type'Image(P.ID) & " (expected 0)");
      else
         Put_Line ("PASSED: P.ID is 0");
      end if;
   else
      Put_Line ("ERROR: Expected Checksum_Error, got " & Packet_Status'Image(Status));
   end if;

end Repro_Fail_Secure;
