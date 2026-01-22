with CRC16;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      CRC   : Unsigned_16 := CRC16.Init_Val;
      Payload_Start : Natural;
   begin
      --  Header: ID (1 byte)
      Buffer(Index) := P.ID;
      
      --  Header: Sequence (2 bytes, Big Endian)
      Buffer(Index + 1) := Unsigned_8 (Shift_Right (P.Sequence, 8));
      Buffer(Index + 2) := Unsigned_8 (P.Sequence and 16#FF#);

      --  Header: Length (1 byte)
      Buffer(Index + 3) := P.Length;

      --  Batch Update CRC for Header (4 bytes)
      CRC := CRC16.Update (CRC, CRC16.Byte_Array (Buffer(Index .. Index + 3)));
      Index := Index + 4;
      
      --  Payload
      if P.Length > 0 then
         Payload_Start := Index;
         for I in 1 .. P.Length loop
            Buffer (Index) := P.Payload (I);
            Index := Index + 1;
         end loop;
         --  Batch Update CRC for Payload
         CRC := CRC16.Update (CRC, CRC16.Byte_Array (Buffer(Payload_Start .. Index - 1)));
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
      Calculated_CRC : Unsigned_16 := CRC16.Init_Val;
      Received_CRC   : Unsigned_16;
   begin
      Success := False;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         return;
      end if;
      
      P.ID := Buffer(Index);
      
      --  Sequence (Big Endian)
      P.Sequence := Shift_Left(Unsigned_16(Buffer(Index+1)), 8) + Unsigned_16(Buffer(Index+2));
      
      Computed_Len := Buffer(Index+3);
      P.Length := Computed_Len;

      --  Batch Update CRC for Header (4 bytes)
      Calculated_CRC := CRC16.Update (Calculated_CRC, CRC16.Byte_Array (Buffer(Index .. Index + 3)));
      Index := Index + 4;
      
      --  Check if buffer has enough data for payload + checksum
      --  Current Index points to start of Payload.
      --  We need P.Length bytes for payload + 2 bytes for checksum.
      --  We use subtraction to avoid overflow when Buffer is at the end of memory.
      if Natural(P.Length) + 2 > (Buffer'Last - Index) + 1 then
         return;
      end if;
      
      for I in 1 .. P.Length loop
         P.Payload(I) := Buffer(Index + Natural(I) - 1);
      end loop;

      if P.Length > 0 then
         Calculated_CRC := CRC16.Update (Calculated_CRC, CRC16.Byte_Array (Buffer(Index .. Index + Natural(P.Length) - 1)));
         Index := Index + Natural(P.Length);
      end if;

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
