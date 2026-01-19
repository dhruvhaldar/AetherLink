with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;

package Packet_Handler with SPARK_Mode is

   type Byte_Array is array (Positive range <>) of Unsigned_8;

   type Deserialize_Status is (Success, Buffer_Too_Short, Malformed_Payload_Length);

   --  Serialize: Converts a Packet to a Byte_Array
   --  Pre: The byte array must be large enough to hold the packet.
   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural)
     with Pre => Buffer'Length >= Natural(P.Length) + 6; -- 1(ID) + 2(Seq) + 1(Len) + 2(Chk) + Payload

   --  Deserialize: Converts a Byte_Array to a Packet
   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Status : out Deserialize_Status);

end Packet_Handler;
