package advancedThermostat
	constant Integer MAX_INDEX = 3;
	constant Modelica.SIunits.Time DELAY_TIME = 10;
	type parameterIndex = Integer(min=0, max=MAX_INDEX);
	type transformLogic = enumeration(minimum, maximum, first, last, sum, avg);
	
 model SignalHolder
 	output Boolean y; 
 	input Boolean u;
 protected
 	Modelica.SIunits.Time entryTime;
 initial equation	
 	y = false;
 	entryTime = 0;
 equation
 	when edge(u) then
 		entryTime = time;
 		y = true;
 	elsewhen entryTime + DELAY_TIME < time then
 		y = false;  
 	end when;
 end SignalHolder;







	
	function BooleanTransform
	  input Boolean source[:];
	  input parameterIndex maxIndex;
	  input transformLogic logic = transformLogic.last;
	  output Boolean result;
	protected
	  Boolean resoultArray[transformLogic];
	algorithm
	  if maxIndex == 0 then
	    resoultArray[transformLogic.minimum] := false;
	    resoultArray[transformLogic.maxaimum] := false;
	    resoultArray[transformLogic.first] := false;
	    resoultArray[transformLogic.last] := false;
	    resoultArray[transformLogic.sum] := false;
	    resoultArray[transformLogic.avg] := false;
	  else
	    resoultArray[transformLogic.minimum] := min(source[1:maxIndex]);
	    resoultArray[transformLogic.maxaimum] := max(source[1:maxIndex]);
	    resoultArray[transformLogic.first] := source[1];
	    resoultArray[transformLogic.last] := source[maxIndex];
	    resoultArray[transformLogic.sum] := sum(source[1:maxIndex]);
	    resoultArray[transformLogic.avg] := sum(source[1:maxIndex]) / maxIndex;
	  end if;
	  result := resoultArray[logic];
	end BooleanTransform;
	
	function RealTransform
	  input Real source[:];
	  input parameterIndex maxIndex;
	  input transformLogic logic = transformLogic.last;
	  output Real result;
	protected
	  Real resoultArray[transformLogic];
	algorithm
	  if maxIndex == 0 then
	    resoultArray[transformLogic.minimum] := 0;
	    resoultArray[transformLogic.maxaimum] := 0;
	    resoultArray[transformLogic.first] := 0;
	    resoultArray[transformLogic.last] := 0;
	    resoultArray[transformLogic.sum] := 0;
	    resoultArray[transformLogic.avg] := 0;
	  else
	    resoultArray[transformLogic.minimum] := min(source[1:maxIndex]);
	    resoultArray[transformLogic.maxaimum] := max(source[1:maxIndex]);
	    resoultArray[transformLogic.first] := source[1];
	    resoultArray[transformLogic.last] := source[maxIndex];
	    resoultArray[transformLogic.sum] := sum(source[1:maxIndex]);
	    resoultArray[transformLogic.avg] := sum(source[1:maxIndex]) / maxIndex;
	  end if;
	  result := resoultArray[logic];
	end RealTransform;
	
	function IntegerTransform
	  input Integer source[:];
	  input parameterIndex maxIndex;
	  input transformLogic logic = transformLogic.last;
	  output Integer result;
	protected
	  Integer resoultArray[transformLogic];
	algorithm
	  if maxIndex == 0 then
	    resoultArray[transformLogic.minimum] := 0;
	    resoultArray[transformLogic.maxaimum] := 0;
	    resoultArray[transformLogic.first] := 0;
	    resoultArray[transformLogic.last] := 0;
	    resoultArray[transformLogic.sum] := 0;
	    resoultArray[transformLogic.avg] := 0;
	  else
	    resoultArray[transformLogic.minimum] := min(source[1:maxIndex]);
	    resoultArray[transformLogic.maxaimum] := max(source[1:maxIndex]);
	    resoultArray[transformLogic.first] := source[1];
	    resoultArray[transformLogic.last] := source[maxIndex];
	    resoultArray[transformLogic.sum] := sum(source[1:maxIndex]);
	    resoultArray[transformLogic.avg] := sum(source[1:maxIndex]) / maxIndex;
	  end if;
	  result := resoultArray[logic];
	end IntegerTransform;
	
	connector ThermostatControlPort
		connector turn_thermostat_on
			Integer counter;
		end turn_thermostat_on;
		connector set_target_temperature
			Integer counter;
			Real target_temperature[MAX_INDEX];
		end set_target_temperature;
		connector turn_thermostat_off
			Integer counter;
		end turn_thermostat_off;
	
		output ThermostatControlPort.turn_thermostat_on turn_thermostat_on1;
		output ThermostatControlPort.set_target_temperature set_target_temperature1;
		output ThermostatControlPort.turn_thermostat_off turn_thermostat_off1;
	end ThermostatControlPort;

	connector TemperatureStreamPort
		connector measured_temperature
			Integer counter;
			Real measured_temperature[MAX_INDEX];
		end measured_temperature;
	
		output TemperatureStreamPort.measured_temperature measured_temperature1;
	end TemperatureStreamPort;

	connector HeatingControlPort
		connector turn_heating_on
			Integer counter;
		end turn_heating_on;
		connector turn_heating_off
			Integer counter;
		end turn_heating_off;
		connector set_hysteresis_intervallum
			Integer counter;
			Real hysteresis_intervallum[MAX_INDEX];
		end set_hysteresis_intervallum;
	
		input HeatingControlPort.turn_heating_on turn_heating_on1;
		input HeatingControlPort.turn_heating_off turn_heating_off1;
		output HeatingControlPort.set_hysteresis_intervallum set_hysteresis_intervallum1;
	end HeatingControlPort;

	
	model ThermostatControlPortTransformer 
		Modelica.Blocks.Interfaces.BooleanInput turn_thermostat_on 
			annotation(Placement(visible = true,
			transformation(origin = {-100, 80},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, 80}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
		Modelica.Blocks.Interfaces.BooleanInput set_target_temperature 
			annotation(Placement(visible = true,
			transformation(origin = {-100, 27},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, 27}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
		Modelica.Blocks.Interfaces.RealInput set_target_temperature_target_temperature 
			annotation(Placement(visible = true,
			transformation(origin = {-100, -26},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, -26}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
		Modelica.Blocks.Interfaces.BooleanInput turn_thermostat_off 
			annotation(Placement(visible = true,
			transformation(origin = {-100, -79},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, -79}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
	
		ThermostatControlPort ThermostatControlPort1;
	
		parameter Real set_target_temperature_target_temperature_initial = 0 
			annotation(Dialog(group = "Initial values"));
		
		SignalHolder turn_thermostat_onSignalHolder;
		SignalHolder set_target_temperatureSignalHolder;
		SignalHolder turn_thermostat_offSignalHolder;
	equation
	
	
		turn_thermostat_on = turn_thermostat_onSignalHolder.u;
		
		ThermostatControlPort1.turn_thermostat_on1.counter = 
			if turn_thermostat_onSignalHolder.y
				then 1 else 0;
		set_target_temperature = set_target_temperatureSignalHolder.u;
		ThermostatControlPort1.set_target_temperature1.counter = 1;
		turn_thermostat_off = turn_thermostat_offSignalHolder.u;
		
		ThermostatControlPort1.turn_thermostat_off1.counter = 
			if turn_thermostat_offSignalHolder.y
				then 1 else 0;
		
		ThermostatControlPort1.set_target_temperature1.target_temperature[1] = set_target_temperature_target_temperature;
		ThermostatControlPort1.set_target_temperature1.target_temperature[2] = set_target_temperature_target_temperature_initial;
		ThermostatControlPort1.set_target_temperature1.target_temperature[3] = set_target_temperature_target_temperature_initial;
	
	end ThermostatControlPortTransformer;

	model TemperatureStreamPortTransformer 
		Modelica.Blocks.Interfaces.BooleanInput measured_temperature 
			annotation(Placement(visible = true,
			transformation(origin = {-100, 80},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, 80}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
		Modelica.Blocks.Interfaces.RealInput measured_temperature_measured_temperature 
			annotation(Placement(visible = true,
			transformation(origin = {-100, -80},
			extent = {{-10, -10}, {10, 10}}, rotation = 0),
			iconTransformation(origin = {-90, -80}, 
			extent = {{-10, -10}, {10, 10}}, rotation = 0)));
	
		TemperatureStreamPort TemperatureStreamPort1;
	
		parameter Real measured_temperature_measured_temperature_initial = 0 
			annotation(Dialog(group = "Initial values"));
		
		SignalHolder measured_temperatureSignalHolder;
	equation
	
	
		measured_temperature = measured_temperatureSignalHolder.u;
		TemperatureStreamPort1.measured_temperature1.counter = 1;
		
		TemperatureStreamPort1.measured_temperature1.measured_temperature[1] = measured_temperature_measured_temperature;
		TemperatureStreamPort1.measured_temperature1.measured_temperature[2] = measured_temperature_measured_temperature_initial;
		TemperatureStreamPort1.measured_temperature1.measured_temperature[3] = measured_temperature_measured_temperature_initial;
	
	end TemperatureStreamPortTransformer;

 model HeatingControlPortTransformer 
 	Modelica.Blocks.Interfaces.BooleanOutput turn_heating_on 
 		annotation(Placement(visible = true,
 		transformation(origin = {110, 80},
 		extent = {{-10, -10}, {10, 10}}, rotation = 0),
 		iconTransformation(origin = {110, 80}, 
 		extent = {{-10, -10}, {10, 10}}, rotation = 0)));
 	Modelica.Blocks.Interfaces.BooleanOutput turn_heating_off 
 		annotation(Placement(visible = true,
 		transformation(origin = {110, -80},
 		extent = {{-10, -10}, {10, 10}}, rotation = 0),
 		iconTransformation(origin = {110, -80}, 
 		extent = {{-10, -10}, {10, 10}}, rotation = 0)));
 	Modelica.Blocks.Interfaces.BooleanInput set_hysteresis_intervallum 
 		annotation(Placement(visible = true,
 		transformation(origin = {-100, 80},
 		extent = {{-10, -10}, {10, 10}}, rotation = 0),
 		iconTransformation(origin = {-90, 80}, 
 		extent = {{-10, -10}, {10, 10}}, rotation = 0)));
 	Modelica.Blocks.Interfaces.RealInput set_hysteresis_intervallum_hysteresis_intervallum 
 		annotation(Placement(visible = true,
 		transformation(origin = {-100, -80},
 		extent = {{-10, -10}, {10, 10}}, rotation = 0),
 		iconTransformation(origin = {-90, -80}, 
 		extent = {{-10, -10}, {10, 10}}, rotation = 0)));
 
 	HeatingControlPort HeatingControlPort1;
 
 	parameter Real set_hysteresis_intervallum_hysteresis_intervallum_initial = 0 
 		annotation(Dialog(group = "Initial values"));
 	
 	SignalHolder set_hysteresis_intervallumSignalHolder;
 equation
 	turn_heating_on = HeatingControlPort1.turn_heating_on1.counter >= 1;
 	turn_heating_off = HeatingControlPort1.turn_heating_off1.counter >= 1;
 
 
 	set_hysteresis_intervallum = set_hysteresis_intervallumSignalHolder.u;
 	HeatingControlPort1.set_hysteresis_intervallum1.counter = 1;
 	
 	HeatingControlPort1.set_hysteresis_intervallum1.hysteresis_intervallum[1] = set_hysteresis_intervallum_hysteresis_intervallum;
 	HeatingControlPort1.set_hysteresis_intervallum1.hysteresis_intervallum[2] = set_hysteresis_intervallum_hysteresis_intervallum_initial;
 	HeatingControlPort1.set_hysteresis_intervallum1.hysteresis_intervallum[3] = set_hysteresis_intervallum_hysteresis_intervallum_initial;
 
 end HeatingControlPortTransformer;





end advancedThermostat;
