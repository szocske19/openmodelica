model fullRobot
  "6 degree of freedom robot with path planning, controllers, motors, brakes, gears and mechanics"
  extends Modelica.Icons.Example;

  import SI = Modelica.SIunits;
  import Components = Modelica.Mechanics.MultiBody.Examples.Systems.RobotR3.Components;
  import RobotR3 = Modelica.Mechanics.MultiBody.Examples.Systems.RobotR3;
  
  parameter SI.Mass mLoad(min=0) = 15 "Mass of load";
  parameter SI.Position rLoad[3]={0.1,0.25,0.1}
    "Distance from last flange to load mass";
  parameter SI.Acceleration g=9.81 "Gravity acceleration";
  parameter SI.Time refStartTime=0 "Start time of reference motion";
  parameter SI.Time refSwingTime=0.5
    "Additional time after reference motion is in rest before simulation is stopped";

  parameter Real startAngle1(unit="deg") = -60 "Start angle of axis 1"
    annotation (Dialog(tab="Reference", group="startAngles"));
  parameter Real startAngle2(unit="deg") = 20 "Start angle of axis 2"
    annotation (Dialog(tab="Reference", group="startAngles"));
  parameter Real startAngle3(unit="deg") = 90 "Start angle of axis 3"
    annotation (Dialog(tab="Reference", group="startAngles"));
  parameter Real startAngle4(unit="deg") = 0 "Start angle of axis 4"
    annotation (Dialog(tab="Reference", group="startAngles"));
  parameter Real startAngle5(unit="deg") = -110 "Start angle of axis 5"
    annotation (Dialog(tab="Reference", group="startAngles"));
  parameter Real startAngle6(unit="deg") = 0 "Start angle of axis 6"
    annotation (Dialog(tab="Reference", group="startAngles"));

  parameter Real endAngle1(unit="deg") = 60 "End angle of axis 1"
    annotation (Dialog(tab="Reference", group="endAngles"));
  parameter Real endAngle2(unit="deg") = -70 "End angle of axis 2"
    annotation (Dialog(tab="Reference", group="endAngles"));
  parameter Real endAngle3(unit="deg") = -35 "End angle of axis 3"
    annotation (Dialog(tab="Reference", group="endAngles"));
  parameter Real endAngle4(unit="deg") = 45 "End angle of axis 4"
    annotation (Dialog(tab="Reference", group="endAngles"));
  parameter Real endAngle5(unit="deg") = 110 "End angle of axis 5"
    annotation (Dialog(tab="Reference", group="endAngles"));
  parameter Real endAngle6(unit="deg") = 45 "End angle of axis 6"
    annotation (Dialog(tab="Reference", group="endAngles"));

  parameter SI.AngularVelocity refSpeedMax[6]={3,1.5,5,3.1,3.1,4.1}
    "Maximum reference speeds of all joints"
    annotation (Dialog(tab="Reference", group="Limits"));
  parameter SI.AngularAcceleration refAccMax[6]={15,15,15,60,60,60}
    "Maximum reference accelerations of all joints"
    annotation (Dialog(tab="Reference", group="Limits"));

  parameter Real kp1=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 1"));
  parameter Real ks1=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 1"));
  parameter SI.Time Ts1=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 1"));
  parameter Real kp2=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 2"));
  parameter Real ks2=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 2"));
  parameter SI.Time Ts2=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 2"));
  parameter Real kp3=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 3"));
  parameter Real ks3=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 3"));
  parameter SI.Time Ts3=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 3"));
  parameter Real kp4=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 4"));
  parameter Real ks4=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 4"));
  parameter SI.Time Ts4=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 4"));
  parameter Real kp5=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 5"));
  parameter Real ks5=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 5"));
  parameter SI.Time Ts5=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 5"));
  parameter Real kp6=5 "Gain of position controller"
    annotation (Dialog(tab="Controller", group="Axis 6"));
  parameter Real ks6=0.5 "Gain of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 6"));
  parameter SI.Time Ts6=0.05
    "Time constant of integrator of speed controller"
    annotation (Dialog(tab="Controller", group="Axis 6"));
  Components.MechanicalStructure mechanics(
    mLoad=mLoad,
    rLoad=rLoad,
    g=g) annotation (Placement(transformation(extent={{35,-35},{95,25}})));
  Modelica.Mechanics.MultiBody.Examples.Systems.RobotR3.Components.PathPlanning6
    pathPlanning(
    naxis=6,
    angleBegDeg={startAngle1,startAngle2,startAngle3,startAngle4,startAngle5,
        startAngle6},
    angleEndDeg={endAngle1,endAngle2,endAngle3,endAngle4,endAngle5,endAngle6},
    speedMax=refSpeedMax,
    accMax=refAccMax,
    startTime=refStartTime,
    swingTime=refSwingTime) annotation (Placement(transformation(extent={{-5,
            50},{-25,70}})));

  RobotR3.Components.AxisType1 axis1(
    w=4590,
    ratio=-105,
    c=43,
    cd=0.005,
    Rv0=0.4,
    Rv1=(0.13/160),
    kp=kp1,
    ks=ks1,
    Ts=Ts1) annotation (Placement(transformation(extent={{-25,-75},{-5,-55}})));
  RobotR3.Components.AxisType1 axis2(
    w=5500,
    ratio=210,
    c=8,
    cd=0.01,
    Rv1=(0.1/130),
    Rv0=0.5,
    kp=kp2,
    ks=ks2,
    Ts=Ts2) annotation (Placement(transformation(extent={{-25,-55},{-5,-35}})));

  RobotR3.Components.AxisType1 axis3(
    w=5500,
    ratio=60,
    c=58,
    cd=0.04,
    Rv0=0.7,
    Rv1=(0.2/130),
    kp=kp3,
    ks=ks3,
    Ts=Ts3) annotation (Placement(transformation(extent={{-25,-35},{-5,-15}})));
  RobotR3.Components.AxisType2 axis4(
    k=0.2365,
    w=6250,
    D=0.55,
    J=1.6e-4,
    ratio=-99,
    Rv0=21.8,
    Rv1=9.8,
    peak=26.7/21.8,
    kp=kp4,
    ks=ks4,
    Ts=Ts4) annotation (Placement(transformation(extent={{-25,-15},{-5,5}})));
  RobotR3.Components.AxisType2 axis5(
    k=0.2608,
    w=6250,
    D=0.55,
    J=1.8e-4,
    ratio=79.2,
    Rv0=30.1,
    Rv1=0.03,
    peak=39.6/30.1,
    kp=kp5,
    ks=ks5,
    Ts=Ts5) annotation (Placement(transformation(extent={{-25,5},{-5,25}})));
  RobotR3.Components.AxisType2 axis6(
    k=0.0842,
    w=7400,
    D=0.27,
    J=4.3e-5,
    ratio=-99,
    Rv0=10.9,
    Rv1=3.92,
    peak=16.8/10.9,
    kp=kp6,
    ks=ks6,
    Ts=Ts6) annotation (Placement(transformation(extent={{-25,25},{-5,45}})));
protected
  Components.ControlBus controlBus
    annotation (Placement(transformation(
        origin={-80,-10},
        extent={{-20,-20},{20,20}},
        rotation=90)));
equation
  connect(axis2.flange, mechanics.axis2) annotation (Line(points={{-5,-45},{
          25,-45},{25,-21.5},{33.5,-21.5}}));
  connect(axis1.flange, mechanics.axis1) annotation (Line(points={{-5,-65},{
          30,-65},{30,-30.5},{33.5,-30.5}}));
  connect(axis3.flange, mechanics.axis3) annotation (Line(points={{-5,-25},{
          15,-25},{15,-12.5},{33.5,-12.5}}));
  connect(axis4.flange, mechanics.axis4) annotation (Line(points={{-5,-5},{15,
          -5},{15,-3.5},{33.5,-3.5}}));
  connect(axis5.flange, mechanics.axis5)
    annotation (Line(points={{-5,15},{10,15},{10,5.5},{33.5,5.5}}, color={0,0,
          0}));
  connect(axis6.flange, mechanics.axis6) annotation (Line(points={{-5,35},{20,
          35},{20,14.5},{33.5,14.5}}));
  connect(controlBus, pathPlanning.controlBus)
                                       annotation (Line(
      points={{-80,-10},{-80,60},{-25,60}},
      color={255,204,51},
      thickness=0.5));
  connect(controlBus.axisControlBus1, axis1.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-80.1,-14.5},{-79,-14.5},{-79,-17},{-65,-17},{-65,
          -65},{-25,-65}},
      color={255,204,51},
      thickness=0.5));

  connect(controlBus.axisControlBus2, axis2.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-79,-9.9},{-79,-15},{-62.5,-15},{-62.5,-45},{-25,
          -45}},
      color={255,204,51},
      thickness=0.5));

  connect(controlBus.axisControlBus3, axis3.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-77,-9.9},{-77,-12.5},{-61,-12.5},{-61,-25},{-25,
          -25}},
      color={255,204,51},
      thickness=0.5));

  connect(controlBus.axisControlBus4, axis4.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-60.5,-9.9},{-60.5,-5},{-25,-5}},
      color={255,204,51},
      thickness=0.5));
  connect(controlBus.axisControlBus5, axis5.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-77,-9.9},{-77,-7},{-63,-7},{-63,15},{-25,15}},
      color={255,204,51},
      thickness=0.5));
  connect(controlBus.axisControlBus6, axis6.axisControlBus) annotation (
    Text(
      string="%first",
      index=-1,
      extent=[-6,3; -6,3]), Line(
      points={{-80.1,-9.9},{-79,-9.9},{-79,-5},{-65,-5},{-65,35},{-25,35}},
      color={255,204,51},
      thickness=0.5));
  annotation (
    experiment(StopTime=2),
    __Dymola_Commands(
      file="modelica://Modelica/Resources/Scripts/Dymola/Mechanics/MultiBody/Examples/Systems/Run.mos"
        "Simulate",
      file="modelica://Modelica/Resources/Scripts/Dymola/Mechanics/MultiBody/Examples/Systems/fullRobotPlot.mos"
        "Plot result of axis 3 + animate"),
    Documentation(info="<html>
<p>
This is a detailed model of the robot. For animation CAD data
is used. Translate and simulate with the default settings
(default simulation time = 3 s). Use command script \"modelica://Modelica/Resources/Scripts/Dymola/Mechanics/MultiBody/Examples/Systems/fullRobotPlot.mos\"
to plot variables.
</p>

<p>
<IMG src=\"modelica://Modelica/Resources/Images/Mechanics/MultiBody/Examples/Systems/r3_fullRobot.png\" ALT=\"model Examples.Loops.Systems.RobotR3.fullRobot\">
</p>
</html>"));
end fullRobot;
