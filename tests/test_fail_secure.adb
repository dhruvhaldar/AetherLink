with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Test_Fail_Secure is
   Tx_Packet : Packet;
   Rx_Packet : Packet;
   Buffer    : Byte_Array (1 .. 1024);
   Last      : Natural;
   Status    : Packet_Status;

   -- Helper to print result
   procedure Assert (Condition : Boolean; Msg : String) is
   begin
      if not Condition then
         Put_Line ("FAILED: " & Msg);
         raise Program_Error with Msg;
      end if;
   end Assert;

begin
   Put_Line ("=== Testing Fail-Secure Deserialization ===");

   -- 1. Setup a valid packet
   Tx_Packet.ID := 123;
   Tx_Packet.Sequence := 1000;
   Tx_Packet.Length := 4;
   Tx_Packet.Payload(1 .. 4) := (10, 20, 30, 40);
   Tx_Packet.Checksum := 0; -- Dummy

   Serialize (Tx_Packet, Buffer, Last);

   -- 2. Corrupt Checksum
   Put_Line ("--- Test Case 1: Checksum Error ---");
   Buffer(Last) := Buffer(Last) + 1; -- Corrupt last byte of checksum

   Deserialize (Buffer(1 .. Last), Rx_Packet, Status);

   Assert (Status = Checksum_Error, "Expected Checksum_Error");

   -- Verify if Rx_Packet is CLEARED or contains STALE data
   -- Since we started Deserialize, P is initialized to 0.
   -- But then fields are parsed.
   -- If Rx_Packet.ID is 123, it means it leaked partial data.
   if Rx_Packet.ID = 123 then
      Put_Line ("VULNERABILITY FOUND: Packet ID leaked despite Checksum Error.");
      Put_Line ("Rx_Packet.ID = " & Packet_ID_Type'Image(Rx_Packet.ID));
   else
      Put_Line ("SECURE: Packet ID is zeroed.");
   end if;

   -- 3. Payload Length Error
   Put_Line ("--- Test Case 2: Payload Length Error ---");
   -- Reset Buffer
   Serialize (Tx_Packet, Buffer, Last);
   -- Corrupt Length byte (Index for Length depends on logic, assuming fixed offset)
   -- ID(1) + Seq(2) + Len(1)
   -- Index: 1(ID), 2,3(Seq), 4(Len)
   Buffer(4) := 200; -- Set Length to 200
   -- But buffer only has actual data for 4 bytes + overhead.
   -- 200 bytes payload + 6 overhead = 206 bytes needed.
   -- Our passed slice `Buffer(1..Last)` is small (~10 bytes).

   Deserialize (Buffer(1 .. Last), Rx_Packet, Status);

   -- Expect Payload_Length_Error because slice is too small for claimed length
   Assert (Status = Payload_Length_Error, "Expected Payload_Length_Error");

   if Rx_Packet.ID = 123 then
      Put_Line ("VULNERABILITY FOUND: Packet ID leaked despite Payload Length Error.");
   else
      Put_Line ("SECURE: Packet ID is zeroed.");
   end if;

end Test_Fail_Secure;
