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

   --  ANSI Color Codes
   C_Reset   : constant String := ASCII.ESC & "[0m";
   C_Green   : constant String := ASCII.ESC & "[32m";
   C_Red     : constant String := ASCII.ESC & "[31m";
   C_Cyan    : constant String := ASCII.ESC & "[36m";
   C_Bold    : constant String := ASCII.ESC & "[1m";

   function To_Hex (B : Unsigned_8) return String is
      Hex_Digits : constant array (0 .. 15) of Character := "0123456789ABCDEF";
   begin
      return Hex_Digits(Natural(B / 16)) & Hex_Digits(Natural(B mod 16));
   end To_Hex;

   function To_Hex (N : Natural) return String is
      Hex_Digits : constant array (0 .. 15) of Character := "0123456789ABCDEF";
      Result     : String (1 .. 4);
      Val        : Natural := N;
   begin
      for I in reverse 1 .. 4 loop
         Result(I) := Hex_Digits(Val mod 16);
         Val := Val / 16;
      end loop;
      return Result;
   end To_Hex;

   procedure Print_Hex_Dump (Data : Byte_Array; Length : Natural) is
      Bytes_Per_Line : constant Natural := 16;
      Offset         : Natural := 0;
      B              : Unsigned_8;
      C              : Character;
   begin
      Put_Line (C_Cyan & "ADDR | 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F | ASCII" & C_Reset);
      while Offset < Length loop
         Put (C_Cyan & To_Hex(Offset) & " | " & C_Reset);

         --  Print Hex
         for I in 1 .. Bytes_Per_Line loop
            if Offset + I <= Length then
               Put (To_Hex (Data (Data'First + Offset + I - 1)) & " ");
            else
               Put ("   "); -- Padding for incomplete lines
            end if;
         end loop;

         Put (" | ");

         --  Print ASCII
         for I in 1 .. Bytes_Per_Line loop
            if Offset + I <= Length then
               B := Data (Data'First + Offset + I - 1);
               if B >= 32 and B <= 126 then
                  C := Character'Val (B);
                  Put (C);
               else
                  Put ('.');
               end if;
            end if;
         end loop;

         New_Line;
         Offset := Offset + Bytes_Per_Line;
      end loop;
   end Print_Hex_Dump;

begin
   New_Line;
   Put_Line (C_Bold & C_Cyan & "=== AetherLink Flight Software Simulation ===" & C_Reset);
   New_Line;

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

   Put_Line ("📦 Generating Telemetry Packet...");
   Put_Line ("   ID:       " & Packet_ID_Type'Image(Tx_Packet.ID));
   Put_Line ("   Sequence: " & Sequence_Number_Type'Image(Tx_Packet.Sequence));
   
   --  Serialize
   Put_Line ("⚙️  Serializing...");
   Serialize (Tx_Packet, Buffer, Last);
   
   Put_Line ("📡 Transmitting " & Natural'Image(Last) & " bytes.");
   Print_Hex_Dump (Buffer, Last);
   New_Line;
   
   --  Simulate Transmission (Loopback)
   --  Deserialize
   Put_Line ("📥 Receiving...");
   Deserialize (Buffer(1 .. Last), Rx_Packet, Success);
   
   if Success then
      Put_Line (C_Green & "✅ Packet Received Successfully!" & C_Reset);
      Put_Line ("   ID:       " & Packet_ID_Type'Image(Rx_Packet.ID));
      Put_Line ("   Sequence: " & Sequence_Number_Type'Image(Rx_Packet.Sequence));
      
      --  Convert Payload back to string for display
      declare
         Msg : String (1 .. Natural(Rx_Packet.Length));
      begin
         for I in 1 .. Rx_Packet.Length loop
            Msg(Natural(I)) := Character'Val(Rx_Packet.Payload(Natural(I)));
         end loop;
         Put_Line ("   Payload:  " & Msg);
      end;
      
      if Rx_Packet.ID = Tx_Packet.ID and then 
         Rx_Packet.Sequence = Tx_Packet.Sequence then
         -- Note: We do not compare Checksums here because Tx_Packet.Checksum is manual/dummy,
         -- whereas Rx_Packet.Checksum is computed by Serialize.
         -- The Deserialize function already verified the checksum validity.
         Put_Line (C_Green & "🔒 VERIFICATION PASSED: Data integrity confirmed." & C_Reset);
      else
         Put_Line (C_Red & "⚠️  VERIFICATION FAILED: Data mismatch." & C_Reset);
         Put_Line ("   Expected Sequence:" & Sequence_Number_Type'Image(Tx_Packet.Sequence));
         Put_Line ("   Got Sequence:     " & Sequence_Number_Type'Image(Rx_Packet.Sequence));
      end if;
   else
      Put_Line (C_Red & "❌ Packet Reception Failed." & C_Reset);
   end if;
   
   New_Line;
   Put_Line (C_Bold & C_Cyan & "=== End Simulation ===" & C_Reset);
end Main;
