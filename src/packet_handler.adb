with Interfaces; use Interfaces;

package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
      CRC   : Unsigned_16 := CRC16.Init_Val;
      Val_16 : Unsigned_16;
      Val_8  : Unsigned_8;
   begin
      --  Header: ID (1 byte)
      Buffer(Index) := P.ID;
      CRC := CRC16.Update (CRC, P.ID);
      Index := Index + 1;
      
      --  Header: Sequence (2 bytes, Big Endian)
      Val_16 := P.Sequence;

      Val_8 := Unsigned_8 (Shift_Right (Val_16, 8));
      Buffer(Index) := Val_8;
      CRC := CRC16.Update (CRC, Val_8);

      Val_8 := Unsigned_8 (Val_16 and 16#FF#);
      Buffer(Index + 1) := Val_8;
      CRC := CRC16.Update (CRC, Val_8);
      Index := Index + 2;
      
      --  Header: Length (1 byte)
      Buffer(Index) := P.Length;
      CRC := CRC16.Update (CRC, P.Length);
      Index := Index + 1;
      
      --  Payload
      if P.Length > 0 then
         declare
            Len : constant Natural := Natural (P.Length);
         begin
            Buffer (Index .. Index + Len - 1) := Byte_Array (P.Payload (1 .. Len));
            --  Use Payload directly to avoid reading back from the just-written Buffer
            CRC := CRC16.Update (CRC, Byte_Array (P.Payload (1 .. Len)));
            Index := Index + Len;
         end;
      end if;

      --  Checksum (2 bytes, Big Endian)
      Buffer(Index) := Unsigned_8 (Shift_Right (CRC, 8));
      Index := Index + 1;
      
      Buffer(Index) := Unsigned_8 (CRC and 16#FF#);
      
      Last := Index; -- Last points to the last written index
   end Serialize;

   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Status : out Packet_Status) is
      Index : Natural := Buffer'First;
      Computed_Len : Unsigned_8;
      Calculated_CRC : Unsigned_16 := CRC16.Init_Val;
      Received_CRC   : Unsigned_16;

      --  Helper to allow efficient slice assignment between compatible array types
      procedure Copy_Bytes (Source : in Byte_Array; Target : out Byte_Array) with Inline is
      begin
         Target := Source;
      end Copy_Bytes;

      --  Helper to securely reset the packet (including payload)
      procedure Reset_Packet with Inline is
      begin
         P := (ID => 0, Sequence => 0, Length => 0, Checksum => 0, Payload => (others => 0));
      end Reset_Packet;
   begin
      --  Initialize only scalar fields to avoid redundant zeroing of payload
      P.ID := 0;
      P.Sequence := 0;
      P.Length := 0;
      P.Checksum := 0;

      Status := Buffer_Underflow;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         Status := Buffer_Underflow;
         Reset_Packet;
         return;
      end if;
      
      declare
         Val : constant Unsigned_8 := Buffer(Index);
      begin
         P.ID := Val;
         Calculated_CRC := CRC16.Update (Calculated_CRC, Val);
      end;
      Index := Index + 1;
      
      --  Sequence (Big Endian)
      declare
         B1 : constant Unsigned_8 := Buffer(Index);
         B2 : constant Unsigned_8 := Buffer(Index + 1);
      begin
         P.Sequence := Shift_Left(Unsigned_16(B1), 8) + Unsigned_16(B2);
         Calculated_CRC := CRC16.Update (Calculated_CRC, B1);
         Calculated_CRC := CRC16.Update (Calculated_CRC, B2);
      end;
      Index := Index + 2;
      
      declare
         Val : constant Unsigned_8 := Buffer(Index);
      begin
         Computed_Len := Val;
         P.Length := Computed_Len;
         Calculated_CRC := CRC16.Update (Calculated_CRC, Val);
      end;
      Index := Index + 1;
      
      --  Check if buffer has enough data for payload + checksum
      --  Current Index points to start of Payload.
      --  We need P.Length bytes for payload + 2 bytes for checksum.
      --  We use subtraction to avoid overflow when Buffer is at the end of memory.
      if Natural(P.Length) + 2 > (Buffer'Last - Index) + 1 then
         Status := Payload_Length_Error;
         Reset_Packet;
         return;
      end if;
      
      declare
         Len : constant Natural := Natural (P.Length);
      begin
         if Len > 0 then
            --  Use slice assignment via helper for performance (approx 2x faster than loop)
            Copy_Bytes (Buffer (Index .. Index + Len - 1), Byte_Array (P.Payload (1 .. Len)));

            --  Use Payload directly (hot in L1) to avoid re-reading Buffer
            Calculated_CRC := CRC16.Update (Calculated_CRC, Byte_Array (P.Payload (1 .. Len)));
            Index := Index + Len;
         end if;

         --  Zero the remaining unused payload bytes
         --  This ensures no stale data leaks and is faster than pre-zeroing the entire array
         if Len < Packet_Types.Payload_Index'Last then
            P.Payload (Len + 1 .. Packet_Types.Payload_Index'Last) := (others => 0);
         end if;
      end;

      --  Checksum Extraction
      Received_CRC := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      P.Checksum   := Received_CRC;

      if Calculated_CRC = Received_CRC then
         Status := Success;
      else
         Status := Checksum_Error;
         Reset_Packet;
      end if;
   end Deserialize;

end Packet_Handler;
