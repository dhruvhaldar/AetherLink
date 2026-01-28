with Packet_Types; use Packet_Types;
with CRC16;

package Packet_Handler with SPARK_Mode is

   subtype Byte_Array is CRC16.Byte_Array;

   --  Status of packet deserialization
   type Packet_Status is (Success, Buffer_Underflow, Payload_Length_Error, Checksum_Error);

   --  Serialize: Converts a Packet to a Byte_Array
   --  Pre: The byte array must be large enough to hold the packet.
   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural)
     with Pre => Buffer'Length >= Natural(P.Length) + 6; -- 1(ID) + 2(Seq) + 1(Len) + 2(Chk) + Payload

   --  Deserialize: Converts a Byte_Array to a Packet
   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Status : out Packet_Status);

end Packet_Handler;
