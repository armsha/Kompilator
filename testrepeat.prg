program ok2;
integer a, b;

begin
     read(b, a);
     a := 12 - (100 + a)*3;
     b := (a + a)/(b - b);
     write(a,b);
     repeat 
         a := a + 1;
     until a = 120;
     write( b );
     if (a <= b) then
        a := b;
    else
        b := a;
     repeat 
         a := a + 1;
     until a = 120;
end.
