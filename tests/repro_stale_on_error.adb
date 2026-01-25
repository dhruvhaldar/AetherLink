with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Repro_Stale_On_Error is
   P : Packet;
   Buffer : Byte_Array (1 .. 10); -- Short buffer
   Success : Boolean;
begin
   Put_Line ("Sentinel: Testing for stale data persistence on Deserialize error...");

   -- 1. Initialize P with 'secret' data
   P.ID := 0;
   P.Sequence := 0;
   P.Length := 10; -- Initially small valid length
   P.Payload := (others => 16#FF#); -- Secret data

   -- 2. Construct a malformed/truncated buffer
   -- Header: ID=1, Seq=0, Length=200 (0xC8)
   -- But buffer is only 10 bytes long.
   Buffer(1) := 1;
   Buffer(2) := 0;
   Buffer(3) := 0;
   Buffer(4) := 200; -- Length claims 200 bytes
   -- We stop here.

   -- 3. Call Deserialize
   Deserialize (Buffer, P, Success);

   if Success then
      Put_Line ("FAILURE: Deserialize succeeded unexpectedly on truncated buffer.");
      return;
   end if;

   Put_Line ("Deserialize correctly returned False.");

   -- 4. Check P state
   Put_Line ("P.Length is: " & Payload_Length_Type'Image(P.Length));

   if P.Length = 200 then
      Put_Line ("VULNERABILITY: P.Length was updated to 200 despite failure.");
      if P.Payload(1) = 16#FF# then
          Put_Line ("VULNERABILITY: P.Payload contains stale data (0xFF).");
      end if;
   else
      Put_Line ("SAFE: P.Length was not updated to malicious length.");
   end if;

end Repro_Stale_On_Error;
