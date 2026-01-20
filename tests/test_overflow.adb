with Ada.Text_IO; use Ada.Text_IO;
with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;

procedure Test_Overflow is
   -- Define a buffer that sits at the end of the Positive range
   -- Note: We use a small range near Positive'Last to simulate the condition.
   subtype High_Index is Positive range Positive'Last - 20 .. Positive'Last;

   -- We declare a buffer with these specific bounds.
   Buffer : Packet_Handler.Byte_Array (Positive'Last - 10 .. Positive'Last);

   Rx_Packet : Packet;
   Success   : Boolean;
begin
   Put_Line ("Test: Bounds Check Overflow Prevention");

   -- Initialize buffer
   for I in Buffer'Range loop
      Buffer(I) := 0;
   end loop;

   -- Set up a fake packet header
   -- ID
   Buffer(Buffer'First) := 1;
   -- Seq (2 bytes)
   Buffer(Buffer'First + 1) := 0;
   Buffer(Buffer'First + 2) := 0;
   -- Length = 5. Index is First + 3.
   Buffer(Buffer'First + 3) := 5;
   -- Checksum (dummy)
   Buffer(Buffer'Last - 1) := 0;
   Buffer(Buffer'Last) := 0;

   Put_Line ("   Attempting Deserialize with buffer near Positive'Last...");

   begin
      Deserialize (Buffer, Rx_Packet, Success);

      if Success then
         Put_Line ("   [FAIL] Deserialize returned Success=True (expected False/Validation failure due to checksum or bounds).");
      else
         Put_Line ("   [PASS] Deserialize returned Success=False gracefully (no crash).");
      end if;

   exception
      when Constraint_Error =>
         Put_Line ("   [FAIL] Caught Constraint_Error! The overflow vulnerability exists.");
      when others =>
         Put_Line ("   [FAIL] Caught unexpected exception.");
   end;

end Test_Overflow;
