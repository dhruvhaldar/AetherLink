with Interfaces; use Interfaces;

package Sanitization with SPARK_Mode is

   --  Returns True if the byte represents a printable ASCII character (32-126).
   --  This defines the "safe" set of characters for terminal output.
   function Is_Safe (B : Unsigned_8) return Boolean;

   --  Sanitizes the input string by replacing any non-safe characters with a placeholder.
   --  Default placeholder is '.' to match existing behavior.
   function Sanitize (Input : String; Placeholder : Character := '.') return String;

end Sanitization;
