with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Main is
   Tx_Packet : Packet;
   Rx_Packet : Packet;
   Buffer    : Byte_Array (1 .. 1024);
   Last      : Natural;
   Status    : Deserialize_Status;

   --  ANSI Color Codes
   C_Reset   : constant String := ASCII.ESC & "[0m";
   C_Green   : constant String := ASCII.ESC & "[32m";
   C_Red     : constant String := ASCII.ESC & "[31m";
   C_Cyan    : constant String := ASCII.ESC & "[36m";
   C_Bold    : constant String := ASCII.ESC & "[1m";

   -- Using a custom log procedure to enforce consistent UX
   procedure Log_Info (Msg : String) is
   begin
      Put_Line (C_Cyan & "[INFO]  " & C_Reset & Msg);
   end Log_Info;

   procedure Log_Success (Msg : String) is
   begin
      Put_Line (C_Green & "[OK]    " & C_Reset & Msg);
   end Log_Success;

   procedure Log_Error (Msg : String) is
   begin
      Put_Line (C_Red & "[ERROR] " & C_Reset & Msg);
   end Log_Error;

   function To_Hex (B : Unsigned_8) return String is
      Hex_Digits : constant array (0 .. 15) of Character := "0123456789ABCDEF";
   begin
      return Hex_Digits(Natural(B / 16)) & Hex_Digits(Natural(B mod 16));
   end To_Hex;

   procedure Print_Hex_Dump (Data : Byte_Array; Length : Natural) is
   begin
      Put ("        "); -- Indent to align with logs
      for I in 1 .. Length loop
         Put (To_Hex(Data(Data'First + I - 1)) & " ");
      end loop;
      New_Line;
   end Print_Hex_Dump;

begin
   New_Line;
   Put_Line (C_Bold & C_Cyan & "============================================" & C_Reset);
   Put_Line (C_Bold & C_Cyan & "   AetherLink Flight Software Simulation    " & C_Reset);
   Put_Line (C_Bold & C_Cyan & "============================================" & C_Reset);
   New_Line;

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
   Tx_Packet.Checksum := 12345;

   Log_Info ("Generating Telemetry Packet...");
   Put_Line ("        ID:       " & Packet_ID_Type'Image(Tx_Packet.ID));
   Put_Line ("        Sequence: " & Sequence_Number_Type'Image(Tx_Packet.Sequence));
   
   --  Serialize
   Serialize (Tx_Packet, Buffer, Last);
   
   Log_Info ("Transmitting " & Natural'Image(Last) & " bytes.");
   Print_Hex_Dump (Buffer, Last);
   New_Line;
   
   --  Simulate Transmission (Loopback)
   --  Deserialize
   Log_Info ("Receiving packet from buffer...");
   Deserialize (Buffer(1 .. Last), Rx_Packet, Status);
   
   case Status is
      when Success =>
         Log_Success ("Packet deserialized successfully.");
         Put_Line ("        ID:       " & Packet_ID_Type'Image(Rx_Packet.ID));
         Put_Line ("        Sequence: " & Sequence_Number_Type'Image(Rx_Packet.Sequence));

         --  Convert Payload back to string for display
         declare
            Msg : String (1 .. Natural(Rx_Packet.Length));
         begin
            for I in 1 .. Rx_Packet.Length loop
               Msg(Natural(I)) := Character'Val(Rx_Packet.Payload(I));
            end loop;
            Put_Line ("        Payload:  " & Msg);
         end;

         if Rx_Packet.ID = Tx_Packet.ID and then
            Rx_Packet.Sequence = Tx_Packet.Sequence and then
            Rx_Packet.Checksum = Tx_Packet.Checksum then
            Log_Success ("Data integrity verified (Checksum match).");
         else
            Log_Error ("Data integrity check failed!");
            Put_Line ("        Expected Sequence:" & Sequence_Number_Type'Image(Tx_Packet.Sequence));
            Put_Line ("        Got Sequence:     " & Sequence_Number_Type'Image(Rx_Packet.Sequence));
         end if;

      when Buffer_Too_Short =>
         Log_Error ("Packet Reception Failed: Buffer too short to contain header.");
         Put_Line ("        Hint: Check that the transport layer is reading the full packet.");

      when Malformed_Payload_Length =>
         Log_Error ("Packet Reception Failed: Malformed payload length.");
         Put_Line ("        Details: Packet header indicates a length larger than received data.");
   end case;
   
   New_Line;
   Put_Line (C_Bold & C_Cyan & "============================================" & C_Reset);
   New_Line;
end Main;
