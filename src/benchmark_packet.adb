with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
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

begin
   -- Initialize Packet
   Tx_Packet.ID := 1;
   Tx_Packet.Sequence := 100;
   Tx_Packet.Length := 5;
   Tx_Packet.Payload(1 .. 5) := (others => 1);
   Tx_Packet.Checksum := 0; -- Will be computed

   Put_Line ("Running Packet Processing Benchmark with " & Integer'Image(Iterations) & " iterations...");

   -- Benchmark Serialize
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      Serialize (Tx_Packet, Buffer, Last);
   end loop;
   End_Time := Clock;
   Duration_Serialize := End_Time - Start_Time;

   Put_Line ("Serialize Time:   " & Duration (To_Duration (Duration_Serialize))'Image & " s");

   -- Prepare Buffer for Deserialize benchmark (Serialize once)
   Serialize (Tx_Packet, Buffer, Last);

   -- Benchmark Deserialize
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      Deserialize (Buffer(1 .. Last), Rx_Packet, Status);
   end loop;
   End_Time := Clock;
   Duration_Deserialize := End_Time - Start_Time;

   Put_Line ("Deserialize Time: " & Duration (To_Duration (Duration_Deserialize))'Image & " s");

end Benchmark_Packet;
