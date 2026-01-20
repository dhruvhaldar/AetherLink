with Interfaces; use Interfaces;

package CRC16 with SPARK_Mode is

   type Byte_Array is array (Positive range <>) of Unsigned_8;

   Initial_Value : constant Unsigned_16 := 16#FFFF#;

   --  Computes the CRC-16-CCITT checksum for a string of bytes
   function Compute (Data : in String) return Unsigned_16;

   --  Computes the CRC-16-CCITT checksum for a byte array
   function Compute (Data : in Byte_Array) return Unsigned_16;

   --  Updates the CRC with a single byte
   function Update (CRC : Unsigned_16; Byte : Unsigned_8) return Unsigned_16;

end CRC16;
