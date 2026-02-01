with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Test_Fail_Secure is
   Buffer : Byte_Array (1 .. 10);
   P      : Packet;
   Status : Packet_Status;
begin
   -- Construct a valid-looking packet but with wrong checksum
   Buffer(1) := 1;  -- ID
   Buffer(2) := 0;  -- Seq High
   Buffer(3) := 1;  -- Seq Low
   Buffer(4) := 0;  -- Length (0)
   Buffer(5) := 0;  -- Checksum High
   Buffer(6) := 0;  -- Checksum Low (Wrong, should not be 0000 for this data)

   -- Note: ID=1, Seq=1, Len=0.
   -- CRC of (01, 00, 01, 00) => Not 0000.

   Deserialize (Buffer(1 .. 6), P, Status);

   if Status = Checksum_Error then
      Put_Line ("Status: Checksum_Error (Expected)");
   else
      Put_Line ("Status: " & Packet_Status'Image(Status));
   end if;

   -- Check if P contains the parsed data despite error
   if P.ID = 1 then
      Put_Line ("FAIL: Packet ID retained despite Checksum Error!");
   else
      Put_Line ("PASS: Packet ID cleared.");
   end if;

   if P.Sequence = 1 then
      Put_Line ("FAIL: Packet Sequence retained despite Checksum Error!");
   else
      Put_Line ("PASS: Packet Sequence cleared.");
   end if;

end Test_Fail_Secure;
