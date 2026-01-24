with Interfaces; use Interfaces;

package CRC16 with SPARK_Mode is

   Init_Val : constant Unsigned_16 := 16#FFFF#;

   function Compute (Data : in String) return Unsigned_16;
   
   --  Overload for byte arrays
   type Byte_Array is array (Positive range <>) of Unsigned_8;
   function Compute (Data : in Byte_Array) return Unsigned_16;

   --  Incremental update
   function Update (Crc : Unsigned_16; Val : Unsigned_8) return Unsigned_16;

   --  Block update
   function Update (Crc : Unsigned_16; Data : Byte_Array) return Unsigned_16;

end CRC16;
