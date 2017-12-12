class ExternalCombiTimeTable2 "External object of 1-dim. table where first column is time"
  extends ExternalObject;

  function constructor "Initialize 1-dim. table where first column is time"
    extends Modelica.Icons.Function;
    input String tableName "Table name";
    input String fileName "File name";
    input Real table[:, :];
    input Modelica.SIunits.Time startTime;
    input Integer columns[:];
    input Modelica.Blocks.Types.Smoothness smoothness;
    input Modelica.Blocks.Types.Extrapolation extrapolation;
    output ExternalCombiTimeTable2 externalCombiTimeTable;
  
    external "C" externalCombiTimeTable = ModelicaStandardTables_CombiTimeTable_init(tableName, fileName, table, size(table, 1), size(table, 2), startTime, columns, size(columns, 1), smoothness, extrapolation) annotation(
      Library = {"ModelicaStandardTables"});
  end constructor;

  function destructor "Terminate 1-dim. table where first column is time"
    extends Modelica.Icons.Function;
    input ExternalCombiTimeTable2 externalCombiTimeTable;
  
    external "C" ModelicaStandardTables_CombiTimeTable_close(externalCombiTimeTable) annotation(
      Library = {"ModelicaStandardTables"});
  end destructor;
end ExternalCombiTimeTable2;
