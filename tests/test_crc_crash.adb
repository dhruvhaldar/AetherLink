with CRC16;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Test_CRC_Crash is
   -- Create a buffer at the very end of Positive range
   Buffer : CRC16.Byte_Array (Positive'Last - 4 .. Positive'Last);
   Res : Unsigned_16;
begin
   Put_Line ("Sentinel: Testing CRC16.Update with buffer at Positive'Last...");

   -- Initialize buffer
   for I in Buffer'Range loop
      Buffer(I) := 0;
   end loop;

   begin
      -- This should trigger the loop increment overflow in CRC16.Update
      Res := CRC16.Update(0, Buffer);
      Put_Line ("SAFE: CRC16.Update completed.");
   exception
      when Constraint_Error =>
         Put_Line ("VULNERABILITY CONFIRMED: Constraint_Error in CRC16.Update.");
   end;
end Test_CRC_Crash;
