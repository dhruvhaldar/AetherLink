with CRC16;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      CRC   : Unsigned_16;
      Start : constant Natural := Buffer'First;
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
      for I in 1 .. P.Length loop
         Buffer(Index) := P.Payload(I);
         Index := Index + 1;
      end loop;
      
      --  Compute Checksum over the data written so far
      --  (ID, Sequence, Length, Payload)
      CRC := CRC16.Compute (CRC16.Byte_Array (Buffer (Start .. Index - 1)));

      --  Checksum (2 bytes, Big Endian)
      Buffer(Index) := Unsigned_8 (Shift_Right (CRC, 8));
      Index := Index + 1;
      
      Buffer(Index) := Unsigned_8 (CRC and 16#FF#);
      Index := Index + 1;
      
      Last := Index - 1; -- Last points to the last written index
   end Serialize;

   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Success : out Boolean) is
      Index : Natural := Buffer'First;
      Computed_Len : Unsigned_8;
      Received_Checksum : Unsigned_16;
      Calculated_Checksum : Unsigned_16;
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
      if Index + Natural(P.Length) + 2 > Buffer'Last + 1 then
         return;
      end if;
      
      for I in 1 .. P.Length loop
         P.Payload(I) := Buffer(Index);
         Index := Index + 1;
      end loop;
      
      --  Calculate Checksum over the data part (start to end of payload)
      --  The data is from Buffer'First to Index - 1
      Calculated_Checksum := CRC16.Compute (CRC16.Byte_Array (Buffer (Buffer'First .. Index - 1)));
      
      --  Read Checksum from Buffer
      Received_Checksum := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      P.Checksum := Received_Checksum;

      if Calculated_Checksum = Received_Checksum then
         Success := True;
      else
         Success := False;
      end if;
   end Deserialize;

end Packet_Handler;
