with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;

procedure Benchmark_Zero_Init is

   P : Packet;
   Start_Time, End_Time : Time;
   Duration_Loop, Duration_Slice : Time_Span;
   Iterations : constant Integer := 10_000_000;

begin
   -- Initialize P with a small length so we have plenty of zeros to write
   P.ID := 1;
   P.Sequence := 100;
   P.Length := 5;
   -- Remaining 250 bytes (255 - 5) will be zeroed.

   Put_Line ("Running benchmark with" & Integer'Image(Iterations) & " iterations...");

   -- Benchmark Loop
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      -- Explicit loop (current implementation)
      if P.Length < Payload_Length_Type'Last then
         for I in Natural(P.Length) + 1 .. Natural(Payload_Length_Type'Last) loop
            P.Payload (Payload_Index(I)) := 0;
         end loop;
      end if;
   end loop;
   End_Time := Clock;
   Duration_Loop := End_Time - Start_Time;

   Put_Line ("Loop Implementation:  " & Duration (To_Duration (Duration_Loop))'Image & " s");

   -- Benchmark Slice
   Start_Time := Clock;
   for K in 1 .. Iterations loop
      -- Slice assignment (optimized)
      if P.Length < Payload_Length_Type'Last then
         P.Payload (Payload_Index (Natural (P.Length) + 1) .. Payload_Index'Last) := (others => 0);
      end if;
   end loop;
   End_Time := Clock;
   Duration_Slice := End_Time - Start_Time;

   Put_Line ("Slice Implementation: " & Duration (To_Duration (Duration_Slice))'Image & " s");

   if Duration_Slice < Duration_Loop then
      Put_Line ("Optimization Speedup: " & Float'Image (Float (To_Duration (Duration_Loop)) / Float (To_Duration (Duration_Slice))) & "x");
   end if;

end Benchmark_Zero_Init;
