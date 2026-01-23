with Packet_Handler;
with Packet_Types; use Packet_Types;
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces; use Interfaces;

procedure Repro_Leak is
   P : Packet;
   Buffer : Packet_Handler.Byte_Array(1..100);
   Success : Boolean;
   Last : Natural;
begin
   -- 1. Dirty the packet payload with "secrets" (0xFF)
   for I in P.Payload'Range loop
      P.Payload(I) := 16#FF#;
   end loop;
   P.Length := 255;

   Put_Line("Initial Payload(10): " & Unsigned_8'Image(P.Payload(10)));

   -- 2. Create a buffer representing a valid packet with Length = 1
   declare
      Small_P : Packet;
   begin
      Small_P.ID := 1;
      Small_P.Sequence := 0;
      Small_P.Length := 1;
      Small_P.Payload := (others => 0);
      Small_P.Payload(1) := 16#AA#;

      Packet_Handler.Serialize(Small_P, Buffer, Last);
   end;

   -- 3. Deserialize into the dirty 'P'
   Packet_Handler.Deserialize(Buffer(1..Last), P, Success);

   if not Success then
      Put_Line("Deserialization failed unexpectedly.");
      return;
   end if;

   -- 4. Check if the "secret" at index 10 is still there.
   Put_Line("New Length: " & Unsigned_8'Image(P.Length));
   Put_Line("Payload(1): " & Unsigned_8'Image(P.Payload(1)));
   Put_Line("Payload(10): " & Unsigned_8'Image(P.Payload(10)));

   if P.Payload(10) = 16#FF# then
      Put_Line("VULNERABILITY CONFIRMED: Stale data detected in payload.");
   else
      Put_Line("Secure: Payload data cleared.");
   end if;

end Repro_Leak;
