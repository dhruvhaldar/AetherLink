with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Repro_Stale_Data is
   P : Packet;
   Buffer : Byte_Array (1 .. 1024);
   Last : Natural;
   Success : Boolean;

   -- Helper to fill payload
   procedure Fill_Payload (P : in out Packet; Content : String) is
   begin
      P.Length := Unsigned_8(Content'Length);
      for I in 1 .. Content'Length loop
         P.Payload(Unsigned_8(I)) := Unsigned_8(Character'Pos(Content(I)));
      end loop;
   end Fill_Payload;

begin
   Put_Line ("Testing for Stale Data Leakage in Packet Deserialization...");

   -- 1. Create a 'Secret' packet (simulating previous sensitive data)
   P.ID := 1;
   P.Sequence := 100;
   Fill_Payload(P, "SECRET_DATA");
   -- Length 11.
   -- 1:S, 2:E, 3:C, 4:R, 5:E, 6:T, 7:_, 8:D, 9:A, 10:T, 11:A

   Put_Line ("Step 1: P holds SECRET data.");

   -- 2. Create a 'Public' packet (shorter)
   declare
      Public_P : Packet;
      Public_Msg : String := "Public"; -- Length 6
   begin
      Public_P.ID := 2;
      Public_P.Sequence := 101;
      Fill_Payload(Public_P, Public_Msg);

      Serialize(Public_P, Buffer, Last);
   end;

   -- 3. Deserialize 'Public' packet into P (overwriting Secret)
   Deserialize(Buffer(1..Last), P, Success);

   if not Success then
      Put_Line ("Failed to deserialize public packet.");
      return;
   end if;

   Put_Line ("Step 2: Deserialized 'Public' packet into P.");

   -- 4. Check if SECRET data is still visible in P.Payload beyond P.Length
   -- We check index 7. Should be '_'.

   if P.Payload(7) = Unsigned_8(Character'Pos('_')) then
      Put_Line ("VULNERABILITY CONFIRMED: Stale data detected in payload residue!");
      Put_Line ("   P.Length = " & Payload_Length_Type'Image(P.Length));
      Put_Line ("   P.Payload(7) = " & Character'Val(P.Payload(7)) & " (Expected '_' from SECRET)");
   else
      Put_Line ("SAFE: Stale data not found (or overwritten).");
      Put_Line ("   P.Payload(7) = " & Character'Val(P.Payload(7)));
   end if;

end Repro_Stale_Data;
