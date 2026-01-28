with Interfaces; use Interfaces;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      CRC   : Unsigned_16 := CRC16.Init_Val;
   begin
      --  Header: ID (1 byte)
      Buffer(Index) := P.ID;
      CRC := CRC16.Update (CRC, Buffer (Index));
      Index := Index + 1;
      
      --  Header: Sequence (2 bytes, Big Endian)
      Buffer(Index)     := Unsigned_8 (Shift_Right (P.Sequence, 8));
      CRC := CRC16.Update (CRC, Buffer (Index));

      Buffer(Index + 1) := Unsigned_8 (P.Sequence and 16#FF#);
      CRC := CRC16.Update (CRC, Buffer (Index + 1));
      Index := Index + 2;
      
      --  Header: Length (1 byte)
      Buffer(Index) := P.Length;
      CRC := CRC16.Update (CRC, Buffer (Index));
      Index := Index + 1;
      
      --  Payload
      if P.Length > 0 then
         declare
            Len : constant Natural := Natural (P.Length);
         begin
            Buffer (Index .. Index + Len - 1) := Byte_Array (P.Payload (1 .. Len));
            CRC := CRC16.Update (CRC, Buffer (Index .. Index + Len - 1));
            Index := Index + Len;
         end;
      end if;

      --  Checksum (2 bytes, Big Endian)
      Buffer(Index) := Unsigned_8 (Shift_Right (CRC, 8));
      Index := Index + 1;
      
      Buffer(Index) := Unsigned_8 (CRC and 16#FF#);
      Index := Index + 1;
      
      Last := Index - 1; -- Last points to the last written index
   end Serialize;

   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Status : out Packet_Status) is
      Index : Natural := Buffer'First;
      Computed_Len : Unsigned_8;
      Calculated_CRC : Unsigned_16 := CRC16.Init_Val;
      Received_CRC   : Unsigned_16;
   begin
      --  Secure default initialization
      P := (ID => 0, Sequence => 0, Length => 0, Checksum => 0, Payload => (others => 0));
      Status := Buffer_Underflow;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         Status := Buffer_Underflow;
         return;
      end if;
      
      P.ID := Buffer(Index);
      Calculated_CRC := CRC16.Update (Calculated_CRC, Buffer(Index));
      Index := Index + 1;
      
      --  Sequence (Big Endian)
      P.Sequence := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      Calculated_CRC := CRC16.Update (Calculated_CRC, Buffer(Index));
      Calculated_CRC := CRC16.Update (Calculated_CRC, Buffer(Index + 1));
      Index := Index + 2;
      
      Computed_Len := Buffer(Index);
      P.Length := Computed_Len;
      Calculated_CRC := CRC16.Update (Calculated_CRC, Buffer(Index));
      Index := Index + 1;
      
      --  Check if buffer has enough data for payload + checksum
      --  Current Index points to start of Payload.
      --  We need P.Length bytes for payload + 2 bytes for checksum.
      --  We use subtraction to avoid overflow when Buffer is at the end of memory.
      if Natural(P.Length) + 2 > (Buffer'Last - Index) + 1 then
         Status := Payload_Length_Error;
         return;
      end if;
      
      declare
         Len : constant Natural := Natural (P.Length);
      begin
         if Len > 0 then
            for I in 1 .. Len loop
               P.Payload (I) := Buffer (Index + I - 1);
            end loop;
            Calculated_CRC := CRC16.Update (Calculated_CRC, Buffer (Index .. Index + Len - 1));
            Index := Index + Len;
         end if;
      end;

      --  Zero-initialize unused payload to prevent stale data leaks
      if P.Length < Payload_Length_Type'Last then
         for I in Natural(P.Length) + 1 .. Natural(Payload_Length_Type'Last) loop
            P.Payload (Payload_Index(I)) := 0;
         end loop;
      end if;

      --  Checksum Extraction
      Received_CRC := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      P.Checksum   := Received_CRC;

      if Calculated_CRC = Received_CRC then
         Status := Success;
      else
         Status := Checksum_Error;
      end if;
   end Deserialize;

end Packet_Handler;
