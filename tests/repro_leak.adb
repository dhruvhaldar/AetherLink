with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces; use Interfaces;
with CRC16;

procedure Repro_Leak is
   P : Packet;
   Buffer : Packet_Handler.Byte_Array(1..5); -- Too short
   Success : Boolean;
begin
   -- Initialize P with "sensitive" data
   P.ID := 123;
   P.Sequence := 456;
   P.Length := 10;
   P.Payload := (others => 16#AA#);
   P.Checksum := 789;

   Buffer := (others => 0);

   Deserialize(Buffer, P, Success);

   if not Success then
      Put_Line("Deserialize failed as expected.");

      -- Check if P still has the "sensitive" data
      if P.ID = 123 then
         Put_Line("VULNERABILITY CONFIRMED: P.ID was not cleared!");
      else
         Put_Line("P.ID was cleared (or undefined overwritten).");
      end if;

      if P.Payload(1) = 16#AA# then
          Put_Line("VULNERABILITY CONFIRMED: P.Payload was not cleared!");
      end if;
   else
      Put_Line("Unexpected success.");
   end if;
end Repro_Leak;
