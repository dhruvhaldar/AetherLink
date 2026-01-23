with Interfaces; use Interfaces;

package Packet_Types with SPARK_Mode is

   --  Constants
   Max_Payload_Size : constant := 255;

   --  Strongly typed Packet ID
   subtype Packet_ID_Type is Unsigned_8;

   --  Sequence number (0 to 65535) - 16 bit
   subtype Sequence_Number_Type is Unsigned_16;

   --  Payload length type (0 to 256)
   --  Note: 256 requires 9 bits, but usually payload length fits in a byte if max is 255.
   --  If max is 256, we need a larger type. Let's strictly limit to 255 for byte-alignment simplicity.
   subtype Payload_Length_Type is Unsigned_8; 

   --  Shared Byte Array type for zero-copy processing
   type Byte_Array is array (Positive range <>) of Unsigned_8;

   --  Payload array (Subtype of Byte_Array for zero-copy slicing)
   subtype Payload_Data_Type is Byte_Array (1 .. Max_Payload_Size);

   --  Packet Record
   type Packet is record
      ID       : Packet_ID_Type;
      Sequence : Sequence_Number_Type;
      Length   : Payload_Length_Type;
      Payload  : Payload_Data_Type;
      Checksum : Unsigned_16; -- Checksum as 16-bit
   end record;

end Packet_Types;
