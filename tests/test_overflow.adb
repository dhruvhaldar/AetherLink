with Packet_Handler; use Packet_Handler;
with Packet_Types; use Packet_Types;
with Interfaces; use Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

procedure Test_Overflow is
   --  We create a buffer that sits at the very end of the Positive index range.
   --  Positive'Last is usually 2**31 - 1.
   Buffer : Byte_Array (Positive'Last - 10 .. Positive'Last) := (others => 0);
   P      : Packet;
   Status : Packet_Status;
begin
   Put_Line ("Testing for integer overflow at Positive'Last...");

   --  Populate buffer with valid-looking header to pass earlier checks
   --  We need 6 bytes minimum.
   --  Buffer indices: Last-10, Last-9, ..., Last
   --  Length is 11.

   --  Index will start at Buffer'First (Positive'Last - 10).
   --  ID:
   Buffer(Buffer'First) := 16#01#;
   --  Seq:
   Buffer(Buffer'First + 1) := 0;
   Buffer(Buffer'First + 2) := 0;
   --  Len: Let's say 0 payload.
   Buffer(Buffer'First + 3) := 0;
   --  At this point, Index will be First + 4.
   --  The check is: Index + Natural(P.Length) + 2 > Buffer'Last + 1
   --  Index = (Positive'Last - 10) + 4 = Positive'Last - 6.
   --  P.Length = 0.
   --  LHS = (Positive'Last - 6) + 0 + 2 = Positive'Last - 4.
   --  RHS = Buffer'Last + 1 = Positive'Last + 1 => Constraint_Error!

   --  If we had a larger payload, say 255.
   --  Buffer(Buffer'First + 3) := 255;
   --  LHS = (Positive'Last - 6) + 255 + 2 = Positive'Last + 251 => Constraint_Error (Overflow)

   --  We use Length = 0 to hit the Buffer'Last + 1 check specifically.

   begin
      Deserialize (Buffer, P, Status);
      Put_Line ("SAFE: Deserialize completed without crashing.");
   exception
      when Constraint_Error =>
         Put_Line ("VULNERABILITY CONFIRMED: Constraint_Error raised (likely overflow).");
      when others =>
         Put_Line ("ERROR: Unexpected exception raised.");
   end;

end Test_Overflow;
