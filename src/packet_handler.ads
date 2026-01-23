with Packet_Types; use Packet_Types;

package Packet_Handler with SPARK_Mode is

   --  Serialize: Converts a Packet to a Byte_Array
   --  Pre: The byte array must be large enough to hold the packet.
   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural)
     with Pre => Buffer'Length >= Natural(P.Length) + 6; -- 1(ID) + 2(Seq) + 1(Len) + 2(Chk) + Payload

   --  Deserialize: Converts a Byte_Array to a Packet
   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Success : out Boolean);

end Packet_Handler;
