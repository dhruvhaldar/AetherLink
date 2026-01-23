with CRC16;
with Interfaces; use Interfaces;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      Start_Index : constant Natural := Buffer'First;
      CRC : Unsigned_16;
   begin
      --  Header: ID (1 byte)
      Buffer(Index) := P.ID;
      Index := Index + 1;
      
      --  Header: Sequence (2 bytes, Big Endian)
      Buffer(Index)     := Unsigned_8 (Shift_Right (P.Sequence, 8));
      Buffer(Index + 1) := Unsigned_8 (P.Sequence and 16#FF#);
      Index := Index + 2;
      
      --  Header: Length (1 byte)
      Buffer(Index) := P.Length;
      Index := Index + 1;
      
      --  Payload
      if P.Length > 0 then
         Buffer (Index .. Index + Natural (P.Length) - 1) := P.Payload (1 .. Natural (P.Length));
         Index := Index + Natural (P.Length);
      end if;

      --  Batch CRC Calculation
      CRC := CRC16.Compute (Buffer (Start_Index .. Index - 1));

      --  Checksum (2 bytes, Big Endian)
      Buffer(Index) := Unsigned_8 (Shift_Right (CRC, 8));
      Index := Index + 1;
      
      Buffer(Index) := Unsigned_8 (CRC and 16#FF#);
      Index := Index + 1;
      
      Last := Index - 1; -- Last points to the last written index
   end Serialize;

   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Success : out Boolean) is
      Index : Natural := Buffer'First;
      Start_Index : constant Natural := Buffer'First;
      Computed_Len : Unsigned_8;
      Calculated_CRC : Unsigned_16;
      Received_CRC   : Unsigned_16;
      End_Payload_Index : Natural;
   begin
      Success := False;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         return;
      end if;
      
      P.ID := Buffer(Index);
      Index := Index + 1;
      
      --  Sequence (Big Endian)
      P.Sequence := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      Index := Index + 2;
      
      Computed_Len := Buffer(Index);
      P.Length := Computed_Len;
      Index := Index + 1;
      
      --  Check if buffer has enough data for payload + checksum
      --  Current Index points to start of Payload.
      --  We need P.Length bytes for payload + 2 bytes for checksum.
      --  We use subtraction to avoid overflow when Buffer is at the end of memory.
      if Natural(P.Length) + 2 > (Buffer'Last - Index) + 1 then
         return;
      end if;
      
      P.Payload (1 .. Natural (P.Length)) := Buffer (Index .. Index + Natural (P.Length) - 1);
      Index := Index + Natural (P.Length);

      End_Payload_Index := Index - 1;

      --  Checksum Extraction
      Received_CRC := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      P.Checksum   := Received_CRC;

      --  Batch CRC Calculation
      Calculated_CRC := CRC16.Compute (Buffer (Start_Index .. End_Payload_Index));

      if Calculated_CRC = Received_CRC then
         Success := True;
      else
         Success := False;
      end if;
   end Deserialize;

end Packet_Handler;
