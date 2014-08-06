program ok1;
float b, c;
integer x;

begin
   read(b, c);
   x := (b + c) - (b - c);
   x := (1 + 2.4) - x;
   while (x > 0) do begin
      if (b = c) then
          write(b);
      else
          write(c);
      x := x - 1;
   end
end.
