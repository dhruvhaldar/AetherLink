with Ada.Text_IO; use Ada.Text_IO;
with CRC16;
with Interfaces; use Interfaces;

procedure Test_CRC is
   Input : String := "123456789";
   Result : Unsigned_16;
begin
   Put_Line ("Testing CRC-16...");
   Result := CRC16.Compute(Input);
   Put_Line ("Input: " & Input);
   Put_Line ("CRC Hex: " & Unsigned_16'Image(Result));
   
   --  CCITT-False (0xFFFF init, 0x1021 poly) of "123456789" is 0x29B1
   if Result = 16#29B1# then
      Put_Line ("PASS: CRC matches CCITT-False standard.");
   else
      Put_Line ("FAIL: CRC mismatch.");
   end if;
end Test_CRC;
