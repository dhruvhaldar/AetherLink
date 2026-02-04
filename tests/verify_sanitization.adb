with Ada.Text_IO; use Ada.Text_IO;
with Interfaces; use Interfaces;
with Sanitization; use Sanitization;

procedure Verify_Sanitization is
   Bad_Str : String := "A" & ASCII.ESC & "B" & Character'Val(127) & "C";
   Expected : String := "A.B.C";
   Result   : String := Sanitize(Bad_Str);
begin
   Put("Testing Sanitization.Sanitize... ");
   if Result = Expected then
      Put_Line("PASS");
   else
      Put_Line("FAIL: Got '" & Result & "', expected '" & Expected & "'");
      raise Program_Error with "Sanitization Check Failed";
   end if;

   Put("Testing Sanitization.Is_Safe... ");
   if Is_Safe(Unsigned_8(Character'Pos('A')))
      and not Is_Safe(Unsigned_8(Character'Pos(ASCII.ESC)))
      and not Is_Safe(127)
   then
      Put_Line("PASS");
   else
      Put_Line("FAIL");
      raise Program_Error with "Is_Safe Check Failed";
   end if;

end Verify_Sanitization;
