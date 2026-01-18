with Interfaces; use Interfaces;

package CRC16 with SPARK_Mode is

   function Compute (Data : in String) return Unsigned_16;
   
   --  Overload for byte arrays
   type Byte_Array is array (Positive range <>) of Unsigned_8;
   function Compute (Data : in Byte_Array) return Unsigned_16;

end CRC16;
