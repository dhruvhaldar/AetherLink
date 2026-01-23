with Interfaces; use Interfaces;
with Packet_Types; use Packet_Types;

package CRC16 with SPARK_Mode is

   Init_Val : constant Unsigned_16 := 16#FFFF#;

   function Compute (Data : in String) return Unsigned_16;
   
   --  Overload for byte arrays
   function Compute (Data : in Byte_Array) return Unsigned_16;

   --  Incremental update
   function Update (Crc : Unsigned_16; Val : Unsigned_8) return Unsigned_16;
   function Update (Crc : Unsigned_16; Data : Byte_Array) return Unsigned_16;

end CRC16;
