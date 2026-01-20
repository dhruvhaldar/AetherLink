with CRC16;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      CRC   : Unsigned_16 := CRC16.Initial_Value;
   begin
      --  Header: ID (1 byte)
      Buffer(Index) := P.ID;
      CRC := CRC16.Update(CRC, Buffer(Index));
      Index := Index + 1;
      
      --  Header: Sequence (2 bytes, Big Endian)
      Buffer(Index)     := Unsigned_8 (Shift_Right (P.Sequence, 8));
      CRC := CRC16.Update(CRC, Buffer(Index));
      Buffer(Index + 1) := Unsigned_8 (P.Sequence and 16#FF#);
      CRC := CRC16.Update(CRC, Buffer(Index + 1));
      Index := Index + 2;
      
      --  Header: Length (1 byte)
      Buffer(Index) := P.Length;
      CRC := CRC16.Update(CRC, Buffer(Index));
      Index := Index + 1;
      
      --  Payload
      if P.Length > 0 then
         -- Optimized: Copy payload and update CRC in a single loop
         -- Eliminates the need for a second pass over the buffer to compute CRC
         for I in 1 .. P.Length loop
            Buffer(Index) := P.Payload(I);
            CRC := CRC16.Update(CRC, Buffer(Index));
            Index := Index + 1;
         end loop;
      end if;

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
      Calculated_CRC : Unsigned_16;
      Received_CRC   : Unsigned_16;
      Payload_Start  : Natural;
   begin
      Success := False;
      Calculated_CRC := CRC16.Initial_Value;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         return;
      end if;
      
      P.ID := Buffer(Index);
      Calculated_CRC := CRC16.Update(Calculated_CRC, Buffer(Index));
      Index := Index + 1;
      
      --  Sequence (Big Endian)
      P.Sequence := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      Calculated_CRC := CRC16.Update(Calculated_CRC, Buffer(Index));
      Calculated_CRC := CRC16.Update(Calculated_CRC, Buffer(Index+1));
      Index := Index + 2;
      
      Computed_Len := Buffer(Index);
      P.Length := Computed_Len;
      Calculated_CRC := CRC16.Update(Calculated_CRC, Buffer(Index));
      Index := Index + 1;
      
      Payload_Start := Index;

      --  Check if buffer has enough data for payload + checksum
      --  Current Index points to start of Payload.
      --  We need P.Length bytes for payload + 2 bytes for checksum.
      if Index + Natural(P.Length) + 2 > Buffer'Last + 1 then
         return;
      end if;
      
      for I in 1 .. P.Length loop
         P.Payload(I) := Buffer(Index);
         Calculated_CRC := CRC16.Update(Calculated_CRC, Buffer(Index));
         Index := Index + 1;
      end loop;

      --  Checksum Extraction
      Received_CRC := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      P.Checksum   := Received_CRC;

      if Calculated_CRC = Received_CRC then
         Success := True;
      else
         Success := False;
      end if;
   end Deserialize;

end Packet_Handler;
