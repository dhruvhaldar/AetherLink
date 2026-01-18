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

   --  Initialize a packet
   Tx_Packet.ID := 1;
   Tx_Packet.Sequence := 300; -- > 255 to test 16-bit serialization
   Tx_Packet.Length := 5;
   Tx_Packet.Payload(1 .. 5) := (
      Unsigned_8(Character'Pos('H')), 
      Unsigned_8(Character'Pos('e')), 
      Unsigned_8(Character'Pos('l')), 
      Unsigned_8(Character'Pos('l')), 
      Unsigned_8(Character'Pos('o'))
   );
   Tx_Packet.Checksum := 12345; -- > 255 to test 16-bit serialization

   Put_Line ("Generating Telemetry Packet ID:" & Packet_ID_Type'Image(Tx_Packet.ID));
   Put_Line ("Sequence Number:" & Sequence_Number_Type'Image(Tx_Packet.Sequence));
   
   --  Serialize
   Put_Line ("Serializing...");
   Serialize (Tx_Packet, Buffer, Last);
   
   Put_Line ("Transmitting " & Natural'Image(Last) & " bytes.");
   
   --  Simulate Transmission (Loopback)
   --  Deserialize
   Put_Line ("Receiving...");
   Deserialize (Buffer(1 .. Last), Rx_Packet, Success);
   
   if Success then
      Put_Line ("Packet Received Successfully!");
      Put_Line ("ID: " & Packet_ID_Type'Image(Rx_Packet.ID));
      Put_Line ("Sequence: " & Sequence_Number_Type'Image(Rx_Packet.Sequence));
      
      --  Convert Payload back to string for display
      declare
         Msg : String (1 .. Natural(Rx_Packet.Length));
      begin
         for I in 1 .. Rx_Packet.Length loop
            Msg(Natural(I)) := Character'Val(Rx_Packet.Payload(I));
         end loop;
         Put_Line ("Payload: " & Msg);
      end;
      
      if Rx_Packet.ID = Tx_Packet.ID and then 
         Rx_Packet.Sequence = Tx_Packet.Sequence and then
         Rx_Packet.Checksum = Tx_Packet.Checksum then
         Put_Line ("VERIFICATION PASSED: Data integrity confirmed.");
      else
         Put_Line ("VERIFICATION FAILED: Data mismatch.");
         Put_Line ("Expected Sequence:" & Sequence_Number_Type'Image(Tx_Packet.Sequence));
         Put_Line ("Got Sequence:     " & Sequence_Number_Type'Image(Rx_Packet.Sequence));
      end if;
   else
      Put_Line ("Packet Reception Failed.");
   end if;
   
   Put_Line ("--- End Simulation ---");
end Main;
