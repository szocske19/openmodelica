package TypeDepTest
  type CType = Integer(final min=0);
  type DType
    extends CType(final max=10); extends Modelica.SIunits.Velocity ;
  end DType;
  annotation(
    Icon(coordinateSystem(initialScale = 0.5)));
end TypeDepTest;
