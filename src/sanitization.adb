package body Sanitization with SPARK_Mode is

   function Is_Safe (B : Unsigned_8) return Boolean is
   begin
      return B >= 32 and B <= 126;
   end Is_Safe;

   function Sanitize (Input : String; Placeholder : Character := '.') return String is
      Result : String := Input;
   begin
      for I in Result'Range loop
         if not Is_Safe (Unsigned_8 (Character'Pos (Result (I)))) then
            Result (I) := Placeholder;
         end if;
      end loop;
      return Result;
   end Sanitize;

end Sanitization;
