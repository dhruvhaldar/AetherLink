with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Repro_Fail_Leak is
   P : Packet;
   Success : Boolean;
begin
   Put_Line ("Sentinel: Testing for data leakage in Deserialize failure...");

   -- 1. Initialize P with 'secret' data (0xFF) in the payload area
   P.ID := 255;
   P.Sequence := 65535;
   P.Length := 255;
   P.Checksum := 65535;
   P.Payload := (others => 16#FF#); -- Fill payload with FF

   -- 2. Create a buffer that is too short (Length < 6) to trigger early return
   -- Buffer (1..4) provided, but length is 4.
   -- This triggers "if Buffer'Length < 6 then return;"

   declare
      Short_Buf : Byte_Array (1 .. 4) := (others => 0);
   begin
       Deserialize (Short_Buf, P, Success);
   end;

   if Success then
      Put_Line ("Setup Error: Deserialize returned True for short buffer.");
      return;
   end if;

   -- 3. Check if P is modified
   -- If P is still full of 0xFF, then it wasn't cleared.

   if P.Payload(1) = 16#FF# then
      Put_Line ("VULNERABILITY CONFIRMED: P.Payload(1) is still 0xFF after failure. Stale data persists.");
   else
      Put_Line ("SAFE: P.Payload(1) is " & Unsigned_8'Image(P.Payload(1)));
   end if;

end Repro_Fail_Leak;
