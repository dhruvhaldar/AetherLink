package body CRC16 with SPARK_Mode is

   --  CRC-16-CCITT (Poly 0x1021)
   
   function Compute_Byte (Current_CRC : Unsigned_16; Byte_Val : Unsigned_8) return Unsigned_16 is
      CRC : Unsigned_16 := Current_CRC;
      B   : Unsigned_16 := Unsigned_16 (Byte_Val);
   begin
      CRC := CRC xor (Shift_Left (B, 8));
      for I in 1 .. 8 loop
         if (CRC and 16#8000#) /= 0 then
            CRC := (Shift_Left (CRC, 1)) xor 16#1021#;
         else
            CRC := Shift_Left (CRC, 1);
         end if;
      end loop;
      return CRC;
   end Compute_Byte;

   function Compute (Data : in String) return Unsigned_16 is
      CRC : Unsigned_16 := 16#FFFF#; -- CCITT Initial Value
   begin
      for I in Data'Range loop
         CRC := Compute_Byte (CRC, Unsigned_8 (Character'Pos (Data (I))));
      end loop;
      return CRC;
   end Compute;

   function Compute (Data : in Byte_Array) return Unsigned_16 is
      CRC : Unsigned_16 := 16#FFFF#; -- CCITT Initial Value
   begin
      for I in Data'Range loop
         CRC := Compute_Byte (CRC, Data (I));
      end loop;
      return CRC;
   end Compute;

end CRC16;
