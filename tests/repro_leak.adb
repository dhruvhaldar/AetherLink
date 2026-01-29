with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Repro_Leak is
   P : Packet;
   Buffer : Byte_Array (1 .. 10);
   Status : Packet_Status;
   Last : Natural;

   -- Helper to print failure
   procedure Fail (Msg : String) is
   begin
      Put_Line ("FAILURE: " & Msg);
   end Fail;

begin
   Put_Line ("Sentinel: Testing for data leakage in Deserialize...");

   -- 1. Initialize P with 'secret' data (0xFF) in the payload area
   P.ID := 0;
   P.Sequence := 0;
   P.Length := 0;
   P.Checksum := 0;
   P.Payload := (others => 16#FF#); -- Fill payload with FF

   -- 2. Create a buffer representing a valid packet with Length = 1
   -- Payload byte will be 0xAA.
   -- We want to see if P.Payload(2..255) remains 0xFF.

   -- Constructing the buffer manually
   -- ID
   Buffer(1) := 16#10#;
   -- Seq (0)
   Buffer(2) := 0;
   Buffer(3) := 0;
   -- Length = 1
   Buffer(4) := 1;
   -- Payload (1 byte)
   Buffer(5) := 16#AA#;

   -- We need to compute valid CRC for this to return Success = True
   -- Or we can just ignore Success for the purpose of checking P modification?
   -- If Deserialize fails CRC check, does it still modify P?
   -- Looking at the code:
   -- It fills P.Payload *before* checking CRC at the end.
   -- So even if CRC is wrong, P is modified.
   -- But let's try to make it valid to be sure we are hitting the success path.
   -- Actually, let's just use Serialize to create a valid buffer first.

   declare
      Source_P : Packet;
      Temp_Buf : Byte_Array(1..20);
      Temp_Last : Natural;
   begin
      Source_P.ID := 16#10#;
      Source_P.Sequence := 0;
      Source_P.Length := 1;
      Source_P.Payload := (others => 0);
      Source_P.Payload(1) := 16#AA#;
      -- We don't care about the rest of Source_P payload, Serialize only uses up to Length.

      Serialize(Source_P, Temp_Buf, Temp_Last);
      -- Copy to our test buffer
      Buffer(1 .. Temp_Last) := Temp_Buf(1 .. Temp_Last);
   end;

   -- 3. Call Deserialize
   -- Note: P has 0xFF in Payload(2..255)
   Deserialize (Buffer, P, Status);

   if Status /= Success then
      Put_Line ("Setup Error: Deserialize returned False. Check test setup.");
      return;
   end if;

   -- 4. Check for Leak
   -- P.Length should be 1.
   -- P.Payload(1) should be 0xAA.
   -- P.Payload(2) should be CLEARED (0x00) if fixed, or REMAIN 0xFF if vulnerable.

   if P.Length /= 1 then
      Fail ("Expected Length 1, got " & P.Length'Image);
   end if;

   if P.Payload(1) /= 16#AA# then
      Fail ("Expected Payload(1) = 0xAA, got " & P.Payload(1)'Image);
   end if;

   if P.Payload(2) = 16#FF# then
      Put_Line ("VULNERABILITY CONFIRMED: P.Payload(2) is still 0xFF. Stale data leaked.");
   elsif P.Payload(2) = 0 then
      Put_Line ("SAFE: P.Payload(2) is 0x00. Stale data cleared.");
   else
      Put_Line ("UNCERTAIN: P.Payload(2) is " & P.Payload(2)'Image);
   end if;

end Repro_Leak;
