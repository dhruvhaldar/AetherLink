with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Test_Reset is
   P : Packet;
begin
   Put_Line ("Sentinel: Testing Packet_Handler.Reset...");

   --  Populate Packet with junk data
   P.ID := 123;
   P.Sequence := 45678;
   P.Length := 255;
   P.Checksum := 54321;
   P.Payload := (others => 16#FF#); -- Fill payload with 0xFF

   --  Verify it is dirty
   if P.ID = 0 then
      Put_Line ("ERROR: Setup failed, ID is 0.");
      return;
   end if;

   --  Call Reset
   Packet_Handler.Reset(P);

   --  Verify all fields are zero
   if P.ID /= 0 then
      Put_Line ("ERROR: Reset failed. ID is not 0.");
      return;
   end if;

   if P.Sequence /= 0 then
      Put_Line ("ERROR: Reset failed. Sequence is not 0.");
      return;
   end if;

   if P.Length /= 0 then
      Put_Line ("ERROR: Reset failed. Length is not 0.");
      return;
   end if;

   if P.Checksum /= 0 then
      Put_Line ("ERROR: Reset failed. Checksum is not 0.");
      return;
   end if;

   --  Verify Payload
   for I in P.Payload'Range loop
      if P.Payload(I) /= 0 then
         Put_Line ("ERROR: Reset failed. Payload(" & Integer'Image(Integer(I)) & ") is not 0.");
         return;
      end if;
   end loop;

   Put_Line ("SAFE: Packet reset verified. All fields including payload are zeroed.");
end Test_Reset;
