with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Main is
   Tx_Packet : Packet;
   Rx_Packet : Packet;
   Buffer    : Byte_Array (1 .. 1024);
   Last      : Natural;
   Success   : Boolean;
begin
   Put_Line ("--- AetherLink Flight Software Simulation ---");
   Put_Line ("--- Sentinel Security Verification ---");

   --  1. Normal Case
   Put_Line ("Test 1: Valid Packet Transmission");

   --  Initialize a packet
   Tx_Packet.ID := 1;
   Tx_Packet.Sequence := 300;
   Tx_Packet.Length := 5;
   Tx_Packet.Payload(1 .. 5) := (
      Unsigned_8(Character'Pos('H')), 
      Unsigned_8(Character'Pos('e')), 
      Unsigned_8(Character'Pos('l')), 
      Unsigned_8(Character'Pos('l')), 
      Unsigned_8(Character'Pos('o'))
   );
   -- Checksum is now calculated by Serialize, so initial value doesn't matter for serialization.
   Tx_Packet.Checksum := 0;

   Put_Line ("Generating Telemetry Packet ID:" & Packet_ID_Type'Image(Tx_Packet.ID));
   
   --  Serialize
   Serialize (Tx_Packet, Buffer, Last);
   Put_Line ("Serialized " & Natural'Image(Last) & " bytes.");
   
   --  Deserialize
   Deserialize (Buffer(1 .. Last), Rx_Packet, Success);
   
   if Success then
      Put_Line ("Packet Received Successfully.");
      if Rx_Packet.ID = Tx_Packet.ID and then 
         Rx_Packet.Sequence = Tx_Packet.Sequence and then
         Rx_Packet.Length = Tx_Packet.Length then
            -- Verify payload
            declare
               Payload_Match : Boolean := True;
            begin
               for I in 1 .. Tx_Packet.Length loop
                  if Rx_Packet.Payload(I) /= Tx_Packet.Payload(I) then
                     Payload_Match := False;
                  end if;
               end loop;
               if Payload_Match then
                  Put_Line ("PASS: Data matches transmitted data.");
               else
                  Put_Line ("FAIL: Payload mismatch.");
               end if;
            end;
      else
         Put_Line ("FAIL: Header mismatch.");
      end if;
      Put_Line ("Computed Checksum: " & Unsigned_16'Image(Rx_Packet.Checksum));
   else
      Put_Line ("FAIL: Packet Reception Failed on valid data.");
   end if;
   
   New_Line;

   -- 2. Corrupted Data Case
   Put_Line ("Test 2: Corrupted Packet (Data Tampering)");

   -- Serialize again to be sure
   Serialize (Tx_Packet, Buffer, Last);

   -- Tamper with the payload (flip a bit in the first byte of payload)
   -- Header: ID(1) + Seq(2) + Len(1) = 4 bytes. Payload starts at index 5 (if buffer index 1 based).
   -- Buffer(Buffer'First + 4) is the first payload byte.
   Put_Line ("Injecting fault: Modifying payload byte...");
   Buffer(Buffer'First + 4) := Buffer(Buffer'First + 4) xor 16#FF#;

   Deserialize (Buffer(1 .. Last), Rx_Packet, Success);

   if not Success then
      Put_Line ("PASS: Packet rejected as expected (Checksum mismatch).");
   else
      Put_Line ("FAIL: Packet accepted despite corruption! Security vulnerability.");
   end if;

   New_Line;

   -- 3. Corrupted Checksum Case
   Put_Line ("Test 3: Corrupted Checksum");

   Serialize (Tx_Packet, Buffer, Last);

   -- Tamper with the checksum (last byte)
   Put_Line ("Injecting fault: Modifying checksum byte...");
   Buffer(Last) := Buffer(Last) xor 16#FF#;

   Deserialize (Buffer(1 .. Last), Rx_Packet, Success);

   if not Success then
      Put_Line ("PASS: Packet rejected as expected (Checksum mismatch).");
   else
      Put_Line ("FAIL: Packet accepted despite corrupted checksum! Security vulnerability.");
   end if;

   Put_Line ("--- End Simulation ---");
end Main;
