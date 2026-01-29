with Ada.Text_IO; use Ada.Text_IO;
with Packet_Types; use Packet_Types;

procedure Repro_Terminal_Injection is
   P : Packet;
begin
   P.Length := 5;
   -- Payload: ESC [ 3 1 m
   P.Payload(1) := 27; -- ESC
   P.Payload(2) := Character'Pos('[');
   P.Payload(3) := Character'Pos('3');
   P.Payload(4) := Character'Pos('1');
   P.Payload(5) := Character'Pos('m');

   Put_Line("Normal Text");

   -- Vulnerable code pattern from Main.adb
   declare
      Msg : String (1 .. Natural(P.Length));
   begin
      for I in 1 .. P.Length loop
         Msg(Natural(I)) := Character'Val(P.Payload(Natural(I)));
      end loop;
      Put_Line ("   Payload:  " & Msg);
   end;

   Put_Line("This text should be RED if vulnerable.");
   Put_Line(ASCII.ESC & "[0mBack to normal.");
end Repro_Terminal_Injection;
