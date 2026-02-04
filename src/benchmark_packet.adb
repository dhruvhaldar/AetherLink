with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Strings; use Ada.Strings;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Packet_Types; use Packet_Types;
with Packet_Handler; use Packet_Handler;
with Interfaces; use Interfaces;

procedure Benchmark_Packet is

   Tx_Packet : Packet;
   Rx_Packet : Packet;
   Buffer    : Byte_Array (1 .. 1024);
   Last      : Natural;
   Status    : Packet_Status;
   Start_Time, End_Time : Time;
   Duration_Serialize, Duration_Deserialize : Time_Span;
   Iterations : constant Integer := 10_000_000;

   Ops_Serialize   : Float;
   Ops_Deserialize : Float;

   --  ANSI Color Codes
   C_Reset   : constant String := ASCII.ESC & "[0m";
   C_Cyan    : constant String := ASCII.ESC & "[36m";
   C_Green   : constant String := ASCII.ESC & "[32m";
   C_Yellow  : constant String := ASCII.ESC & "[33m";
   C_Bold    : constant String := ASCII.ESC & "[1m";

begin
   -- Initialize Packet
   Tx_Packet.ID := 1;
   Tx_Packet.Sequence := 100;
   Tx_Packet.Length := 5;
   Tx_Packet.Payload(1 .. 5) := (others => 1);
   Tx_Packet.Checksum := 0; -- Will be computed

   New_Line;
   Put_Line (C_Bold & C_Cyan & "🚀 Running Packet Processing Benchmark..." & C_Reset);
   Put_Line ("   Iterations: " & C_Yellow & Trim(Integer'Image(Iterations), Left) & C_Reset);
   New_Line;

   -- Benchmark Serialize
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      Serialize (Tx_Packet, Buffer, Last);
   end loop;
   End_Time := Clock;
   Duration_Serialize := End_Time - Start_Time;

   Ops_Serialize := Float(Iterations) / Float(To_Duration(Duration_Serialize));

   Put ("⏱️  Serialize:   ");
   Put (C_Green);
   Put (Float(To_Duration(Duration_Serialize)), Fore => 0, Aft => 4, Exp => 0);
   Put (" s" & C_Reset & " (");
   Put (C_Yellow);
   Put (Ops_Serialize, Fore => 0, Aft => 2, Exp => 0);
   Put (" ops/sec" & C_Reset & ")");
   New_Line;

   -- Prepare Buffer for Deserialize benchmark (Serialize once)
   Serialize (Tx_Packet, Buffer, Last);

   -- Benchmark Deserialize
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      Deserialize (Buffer(1 .. Last), Rx_Packet, Status);
   end loop;
   End_Time := Clock;
   Duration_Deserialize := End_Time - Start_Time;

   Ops_Deserialize := Float(Iterations) / Float(To_Duration(Duration_Deserialize));

   Put ("⏱️  Deserialize: ");
   Put (C_Green);
   Put (Float(To_Duration(Duration_Deserialize)), Fore => 0, Aft => 4, Exp => 0);
   Put (" s" & C_Reset & " (");
   Put (C_Yellow);
   Put (Ops_Deserialize, Fore => 0, Aft => 2, Exp => 0);
   Put (" ops/sec" & C_Reset & ")");
   New_Line;

   New_Line;
   Put_Line (C_Bold & C_Cyan & "✅ Benchmark Complete" & C_Reset);
   New_Line;

end Benchmark_Packet;
