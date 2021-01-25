within MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits;
block Controller "Controller for room VAV box" // _99_01_benchmark

  constant Real conv_cfm_m3s=1./(35.3147*60);
  constant Real conv_ft_m=0.3048;

  parameter Modelica.SIunits.Temperature THeaOn=(70+459.67)*5/9
    "Occupied zone heating set-point temperature";

  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TRooHeaSet(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "Setpoint temperature for room for heating";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TRooCooSet(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "Setpoint temperature for room for cooling";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TRoo(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "Measured room temperature";

  // Controller gains
  parameter Real kHea(final unit="1/K")=0.1
    "Gain for heating control loop signal";
  parameter Modelica.SIunits.Time TiHea=900
    "Time constant of integrator block for heating control loop signal";
  parameter Real kCoo(final unit="1/K") = 0.1
    "Gain for cooling control loop signal";
  parameter Modelica.SIunits.Time TiCoo=900
    "Time constant of integrator block for cooling control loop signal";

  // Generating unoccupied boolean signal
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uOpeMod
    "Zone operation mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isUnOcc "Output true if unoccupied";
  Buildings.Controls.OBC.CDL.Logical.Not isNotUn "Output true if not unoccupied";
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntUn(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.unoccupied)
    "Constant signal for unoccupied mode";

  // PID loops
  Buildings.Controls.OBC.CDL.Continuous.LimPID conHeaLoo(
    final controllerType = controllerType,
    final k=kHea,
    final Ti=TiHea,
    final yMax=1,
    final yMin=0,
    reset=Buildings.Controls.OBC.CDL.Types.Reset.Parameter)
    "Heating loop signal";

  Buildings.Controls.OBC.CDL.Continuous.LimPID conCooLoo(
    final controllerType = controllerType,
    final k=kCoo,
    final Ti=TiCoo,
    final yMax=1,
    final yMin=0,
    reverseAction=true,
    reset=Buildings.Controls.OBC.CDL.Types.Reset.Parameter)
    "Cooling loop signal";

  parameter Modelica.SIunits.Area AFlo "Area of the zone";
  parameter Boolean have_occSen=false
    "Set to true if the zone has occupancy sensor";
  parameter Boolean have_winSen=false
    "Set to true if the zone has window switch";
  parameter Boolean have_CO2Sen=false
    "Set to true if the zone has CO2 sensor";
  parameter Modelica.SIunits.VolumeFlowRate vA_CooMax
    "Volume flow rate of this thermal zone";
  parameter Modelica.SIunits.VolumeFlowRate vA_Min
    "Zone minimum airflow setpoint";
  parameter Modelica.SIunits.VolumeFlowRate vA_HeaMax
    "Zone minimum airflow setpoint";
  parameter Modelica.SIunits.VolumeFlowRate VMinCon=0.1*vA_CooMax
    "VAV box controllable minimum";
  parameter Real outAirPerAre(final unit = "m3/(s.m2)")=0.06*conv_cfm_m3s/conv_ft_m^2
    "Outdoor air rate per unit area";
  parameter Modelica.SIunits.VolumeFlowRate outAirPerPer=5*conv_cfm_m3s
    "Outdoor air rate per person";
  parameter Real CO2Set=894E-6 "CO2 setpoint in volume fraction";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput nOcc if have_occSen
    "Number of occupants";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput ppmCO2 if have_CO2Sen
    "Measured CO2 concentration";
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uWin if have_winSen
    "Window status, true if open, false if closed";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.Reheat.SetPoints.ActiveAirFlow actAirSet( // shiyab added 190310
    final AFlo=AFlo,
    final have_occSen=have_occSen,
    final have_winSen=have_winSen,
    final have_CO2Sen=have_CO2Sen,
    final VCooMax=vA_CooMax,
    final VMin=vA_Min,
    final VHeaMax=vA_HeaMax,
    final VMinCon=VMinCon,
    final outAirPerAre=outAirPerAre,
    final outAirPerPer=outAirPerPer,
    final CO2Set=CO2Set)
    "Active airflow rate setpoint";

  parameter Real kVal(final unit="1/K")=0.5
    "Gain of controller for valve control";
  parameter Modelica.SIunits.Time TiVal=300
    "Time constant of integrator block for valve control";
  parameter Real kDam(final unit="1")=0.5
    "Gain of controller for damper control";
  parameter Modelica.SIunits.Time TiDam=300
    "Time constant of integrator block for damper control";
  parameter Modelica.SIunits.Temperature DATMax;
  parameter Modelica.SIunits.Temperature TDisMin=283.15
    "Lowest discharge air temperature";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDis(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "Measured supply air temperature after heating coil";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSupAHU(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "AHU supply air temperature";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VDis(
    final unit="m3/s",
    quantity="VolumeFlowRate")
    "Measured discharge airflow rate";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.Reheat.DamperValves damVal(
    final controllerTypeVal=controllerType,
    final kVal=kVal,
    final TiVal=TiVal,
    final controllerTypeDam=controllerType,
    final kDam=kDam,
    final TiDam=TiDam,
    final dTDisMax=DATMax-THeaOn,
    final DATMax=DATMax, // shiyab added 190423
    final TDisMin=TDisMin,
    V_flow_nominal=max(vA_CooMax, vA_HeaMax))
      "Damper and valve controller";

  parameter Modelica.SIunits.Time samplePeriod = 120
    "Sample period to calculate static pressure system requests";
  parameter Modelica.SIunits.Time durTimFlo=60
    "Duration time of airflow rate less than setpoint";
  parameter Modelica.SIunits.Time durTimDisAir=300
    "Duration time of discharge air temperature is less than setpoint";
  parameter Boolean have_heaWatCoi=false
    "Flag, true if there is a hot water coil";
  parameter Boolean have_heaPla=false
    "Flag, true if there is a boiler plant";
  parameter Modelica.SIunits.TemperatureDifference cooSetDif_1=2.8
    "Limit value of difference between zone temperature and cooling setpoint
    for generating 3 cooling SAT reset requests";
  parameter Modelica.SIunits.TemperatureDifference cooSetDif_2=1.7
    "Limit value of difference between zone temperature and cooling setpoint
    for generating 2 cooling SAT reset requests";
  parameter Modelica.SIunits.TemperatureDifference disAirSetDif_1=17
    "Limit value of difference between discharge air temperature and its setpoint
    for generating 3 hot water reset requests";
  parameter Modelica.SIunits.TemperatureDifference disAirSetDif_2=8.3
    "Limit value of difference between discharge air temperature and its setpoint
    for generating 2 hot water reset requests";
  parameter Modelica.SIunits.Time durTimTem=120
    "Duration time of zone temperature exceeds setpoint";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.Reheat.SystemRequests sysReq(
    samplePeriod=samplePeriod,
    durTimFlo=durTimFlo,
    have_heaWatCoi=have_heaWatCoi,
    have_heaPla=have_heaPla,
    cooSetDif_1=cooSetDif_1,
    cooSetDif_2=cooSetDif_2,
    disAirSetDif_1=disAirSetDif_1,
    disAirSetDif_2=disAirSetDif_2,
    durTimTem=durTimTem);
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yZonPreResReq
    "Zone static pressure reset requests";

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    min=0,
    max=1,
    final unit="1")
    "Signal for heating coil valve";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDam(
    min=0,
    max=1,
    final unit="1")
    "Signal for VAV damper";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yZonTemResReq
    "Zone cooling supply air temperature reset request";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput tNexNonOcc;

equation
  connect(conIntUn.y, isUnOcc.u1);
  connect(uOpeMod, isUnOcc.u2);
  connect(isUnOcc.y, isNotUn.u);

  connect(TRooHeaSet, conHeaLoo.u_s);
  connect(TRoo, conHeaLoo.u_m);
  connect(isNotUn.y, conHeaLoo.trigger);
  connect(TRooCooSet, conCooLoo.u_s);
  connect(TRoo, conCooLoo.u_m);
  connect(isNotUn.y, conCooLoo.trigger);

  connect(nOcc,actAirSet.nOcc);
  connect(uOpeMod,actAirSet.uOpeMod);
  connect(ppmCO2,actAirSet.ppmCO2);
  connect(uWin,actAirSet.uWin);

  connect(conHeaLoo.y,damVal.uHea);
  connect(conCooLoo.y,damVal.uCoo);
  connect(actAirSet.VActCooMax,damVal.VActCooMax);
  connect(actAirSet.VActCooMin,damVal.VActCooMin);
  connect(actAirSet.VActMin,damVal.VActMin);
  connect(actAirSet.VActHeaMax,damVal.VActHeaMax);
  connect(actAirSet.VActHeaMin,damVal.VActHeaMin);
  connect(VDis,damVal.VDis);
  connect(TDis,damVal.TDis);
  connect(TSupAHU,damVal.TSup);
  connect(TRooHeaSet,damVal.THeaSet);
  connect(TRoo,damVal.TRoo);
  connect(uOpeMod,damVal.uOpeMod);
  connect(damVal.yHeaVal,yVal);
  connect(damVal.yDam,yDam);

  connect(VDis,sysReq.VDis);
  connect(yDam,sysReq.uDam);
  connect(damVal.VDisSet,sysReq.VDisSet);
  connect(sysReq.yZonPreResReq, yZonPreResReq);

  connect(TRooCooSet,sysReq.TCooSet);
  connect(TRoo,sysReq.TRoo);
  connect(damVal.TDisSet,sysReq.TDisSet);
  connect(TDis,sysReq.TDis);
  connect(damVal.yHeaVal, sysReq.uHeaVal);
  connect(conCooLoo.y, sysReq.uCoo);
  connect(sysReq.yZonTemResReq, yZonTemResReq);

  connect(tNexNonOcc,sysReq.tNexNonOcc);
  connect(isUnOcc.y,sysReq.isUnOcc);

end Controller;
