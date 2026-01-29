with Ada.Text_IO; use Ada.Text_IO;

procedure Test_Sanitization_Impl is
   function Sanitize (Input : String) return String is
      Result : String := Input;
   begin
      for I in Result'Range loop
         if Character'Pos (Result(I)) < 32 or Character'Pos (Result(I)) > 126 then
            Result(I) := '.';
         end if;
      end loop;
      return Result;
   end Sanitize;

   Bad_Str : String := "A" & ASCII.ESC & "B" & Character'Val(127) & "C";
begin
   Put("Testing Sanitize logic... ");
   if Sanitize(Bad_Str) = "A.B.C" then
      Put_Line("PASS");
   else
      Put_Line("FAIL: Got '" & Sanitize(Bad_Str) & "', expected 'A.B.C'");
   end if;
end Test_Sanitization_Impl;
