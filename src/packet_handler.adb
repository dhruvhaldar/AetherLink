package body Packet_Handler with SPARK_Mode is

   procedure Serialize (P : in Packet; Buffer : out Byte_Array; Last : out Natural) is
      Index : Natural := Buffer'First;
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
         Buffer (Index .. Index + Natural (P.Length) - 1) :=
           Byte_Array (P.Payload (1 .. P.Length));
         Index := Index + Natural (P.Length);
      end if;

      --  Checksum (2 bytes, Big Endian)
      Buffer(Index) := Unsigned_8 (Shift_Right (P.Checksum, 8));
      Index := Index + 1;
      
      Buffer(Index) := Unsigned_8 (P.Checksum and 16#FF#);
      Index := Index + 1;
      
      Last := Index - 1; -- Last points to the last written index
   end Serialize;

   procedure Deserialize (Buffer : in Byte_Array; P : out Packet; Status : out Deserialize_Status) is
      Index : Natural := Buffer'First;
      Computed_Len : Unsigned_8;
   begin
      --  Initialize output to avoid uninitialized usage if we return early (SPARK/Ada safety)
      --  Default to an error state until proven successful.
      Status := Buffer_Too_Short;
      
      --  Basic bounds check: ID(1) + Seq(2) + Len(1) + Checksum(2) = 6 bytes minimum (empty payload)
      if Buffer'Length < 6 then
         Status := Buffer_Too_Short;
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
         Status := Malformed_Payload_Length;
         return;
      end if;
      
      for I in 1 .. P.Length loop
         P.Payload(I) := Buffer(Index);
         Index := Index + 1;
      end loop;

      --  Checksum
      P.Checksum := Shift_Left(Unsigned_16(Buffer(Index)), 8) + Unsigned_16(Buffer(Index+1));
      
      Status := Success;
   end Deserialize;

end Packet_Handler;
