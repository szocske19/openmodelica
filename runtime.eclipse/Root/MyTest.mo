model MyTest
  import SI = Modelica.SIunits;
  SI.Velocity v;
  parameter SI.Acceleration a(min=0) = 10;
equation
  a = der(v);
end MyTest;