block BooleanTable
  "Generate a Boolean output signal based on a vector of time instants"

  parameter Boolean startValue=false
    "Start value of y. At time = table[1], y changes to 'not startValue'";
  parameter Modelica.SIunits.Time table[:]={0,1}
    "Vector of time points. At every time point, the output y gets its opposite value (e.g., table={0,1})";
  extends Interfaces.partialBooleanSource;

protected
  function getFirstIndex "Get first index of table and check table"
    extends Modelica.Icons.Function;
    input Real table[:] "Vector of time instants";
    input Modelica.SIunits.Time simulationStartTime "Simulation start time";
    input Boolean startValue "Value of y for time < table[1]";
    output Integer index "First index to be used";
    output Modelica.SIunits.Time nextTime "Time instant of first event";
    output Boolean y "Value of y at simulationStartTime";
  protected
    Integer j;
    Integer n=size(table, 1) "Number of table points";
  algorithm
    if size(table, 1) == 0 then
      index := 0;
      nextTime := Modelica.Constants.inf;
      y := startValue;
    elseif size(table, 1) == 1 then
      index := 1;
      if table[1] > simulationStartTime then
        nextTime := table[1];
        y := startValue;
      else
        nextTime := Modelica.Constants.inf;
        y := not startValue;
      end if;
    else
      // Check whether time values are strict monotonically increasing
      for i in 2:n loop
        assert(table[i] > table[i-1],
          "Time values of table not strict monotonically increasing: table["
           + String(i - 1) + "] = " + String(table[i - 1]) + ", table[" +
          String(i) + "] = " + String(table[i]));
      end for;

      // Determine first index in table
      j := 1;
      y := startValue;
      while j <= n and table[j] <= simulationStartTime loop
        y := not y;
        j := j + 1;
      end while;

      if j > n then
        nextTime := Modelica.Constants.inf;
      else
        nextTime := table[j];
      end if;

      index := j;
    end if;
  end getFirstIndex;

  parameter Integer n=size(table, 1) "Number of table points";
  Modelica.SIunits.Time nextTime;
  Integer index "Index of actual table entry";
initial algorithm
  (index,nextTime,y) := getFirstIndex(table,time,startValue);
algorithm
  when time >= pre(nextTime) and n > 0 then
    if index < n then
      index := index + 1;
      nextTime := table[index];
      y := not y;
    elseif index == n then
      index := index + 1;
      y := not y;
    end if;
  end when;
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics={Rectangle(
          extent={{-18,70},{32,-50}},
          lineColor={255,255,255},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid), Line(points={{-18,-50},{-18,70},{32,
              70},{32,-50},{-18,-50},{-18,-20},{32,-20},{32,10},{-18,10},{-18,
              40},{32,40},{32,70},{32,70},{32,-51}})}),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{
            100,100}}),graphics={Rectangle(
            extent={{-34,66},{16,-54}},
            lineColor={255,255,255},
            fillColor={192,192,192},
            fillPattern=FillPattern.Solid),Line(points={{-34,-54},{-34,66},{
          16,66},{16,-54},{-34,-54},{-34,-24},{16,-24},{16,6},{-34,6},{-34,36},
          {16,36},{16,66},{16,66},{16,-55}}),Text(
            extent={{-29,59},{10,44}},
            lineColor={0,0,0},
            textString="time")}),
    Documentation(info="<html>
<p>
The Boolean output y is a signal defined by parameter vector <b>table</b>.
In the vector time points are stored. At every time point, the output y
changes its value to the negated value of the previous one.
</p>

<p>
<img src=\"modelica://Modelica/Resources/Images/Blocks/Sources/BooleanTable.png\"
   alt=\"BooleanTable.png\">
</p>

<p>
The precise semantics is:
</p>

<pre>
<b>if</b> size(table,1) == 0 <b>then</b>
   y = startValue;
<b>else</b>
   //            time &lt; table[1]: y = startValue
   // table[1] &le; time &lt; table[2]: y = not startValue
   // table[2] &le; time &lt; table[3]: y = startValue
   // table[3] &le; time &lt; table[4]: y = not startValue
   // ...
<b>end if</b>;
</pre>
<p>
Note, the result of this block depends only on time, but not on the simulation start time
(changing the simulation start time, will result exactly in the same output y at the same
time instant ti);
</p>
</html>"));
end BooleanTable;
