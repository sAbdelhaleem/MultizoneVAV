within MultizoneVAV.UncertaintyModels.VAVReheat.ThermalZones;
model Floor "Model of a floor of the building" // _99_05_benchmarkMediumAccuracy

  // General parameters
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium model for air";

  // Conversion factors
  constant Integer numZon
    "Total number of served VAV boxes";

  constant Real conv_ft_m=0.3048;

  constant Real CO2PerPer=8.18E-6
    "CO2 emission per person [kg/s-person]";
  constant Real mWatPerPer=45E-6
    "Moisture generation rate per person [kg/s-person]";

  constant Modelica.SIunits.Height hRoo=3
    "Room height";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uOpeMod
    "Zone operation mode";

  Modelica.Blocks.Sources.Constant Zer_s(final k=0)
    "Constant zero";

  // Zone parameters
  parameter Modelica.SIunits.MassFlowRate mA_CooMaxAct_406
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMaxAct_222
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";

  parameter Modelica.SIunits.Area ARoo_406=478.8*conv_ft_m^2
    "Room area [m2]";
  parameter Modelica.SIunits.Area ARoo_222=1379.4*conv_ft_m^2
    "Room area [m2]";
  parameter Modelica.SIunits.Volume VRoo_406=hRoo*ARoo_406
    "Room volume";
  parameter Modelica.SIunits.Volume VRoo_222=hRoo*ARoo_222
    "Room volume";
  Modelica.Blocks.Math.Gain gaiCO2_406(k=CO2PerPer)
    "CO2 emission rate from occupants [kg/s]";
  Modelica.Blocks.Math.Gain gaiCO2_222(k=CO2PerPer)
    "CO2 emission rate from occupants [kg/s]";
  Modelica.Blocks.Math.Gain gaiWat_406(k=mWatPerPer)
    "Moisture generation rate from occupants [kg/s]";
  Modelica.Blocks.Math.Gain gaiWat_222(k=mWatPerPer)
    "Moisture generation rate from occupants [kg/s]";

  // Zones
  Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir zon_406(
    redeclare package Medium = Medium,
    m_flow_nominal=mA_CooMaxAct_406,
    V=VRoo_406,
    nPorts=4,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    mSenFac=3,
    use_C_flow=true)
    "Thermal zone 406";

  Buildings.Fluid.MixingVolumes.MixingVolumeMoistAir zon_222(
    redeclare package Medium = Medium,
    m_flow_nominal=mA_CooMaxAct_222,
    V=VRoo_222,
    nPorts=4,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    mSenFac=3,
    use_C_flow=true)
    "Thermal zone 222";

  // Zone sensors
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemRoo_222
    "Room temperature sensor [K]";
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemRoo_406
    "Room temperature sensor [K]";
  Modelica.Blocks.Routing.Multiplex2 T_multiplex2_1
    "Vector of all zone air temperaures";
  Modelica.Blocks.Interfaces.RealOutput TRooAir[numZon](
    each unit="K",
    each displayUnit="degC")
    "Room air temperatures [K]";

  Buildings.Fluid.Sensors.TraceSubstances senCO2_222(
    redeclare package Medium = Medium)
    "Sensor at volume [kg_CO2/kg_air]";
  Buildings.Fluid.Sensors.TraceSubstances senCO2_406(
    redeclare package Medium = Medium)
    "Sensor at volume [kg_CO2/kg_air]";
  Modelica.Blocks.Routing.Multiplex2 CO2_multiplex2_1
    "Vector of all zone CO2 concentrations";
  Buildings.Fluid.Sensors.Conversions.To_VolumeFraction volFraCO2[numZon](
    each MMMea=Modelica.Media.IdealGases.Common.SingleGasesData.CO2.MM)
    "CO2 volume fraction [m3_CO2/m3_air], multiply by 10^6 to get ppm";

  Buildings.Fluid.Sensors.RelativeHumidity senRH_222(
    redeclare package Medium = Medium)
    "Sensor for relative humidity [1]";
  Buildings.Fluid.Sensors.RelativeHumidity senRH_406(
    redeclare package Medium = Medium)
    "Sensor for relative humidity [1]";
  Modelica.Blocks.Routing.Multiplex2 RH_multiplex2_1
    "Vector of all zone relative humidities";
  Modelica.Blocks.Interfaces.RealOutput RHRooAir[numZon]
    "Relative humidity of room air [1]";

  Modelica.Blocks.Routing.Multiplex2 nOcc_multiplex2_1
    "Vector of all occupancy schedules";
  Modelica.Blocks.Interfaces.RealOutput nOcc[numZon]
    "Number of occupants in zone, schedule that resembles the existance of an occupancy sensor";

  // Weather data
  Buildings.BoundaryConditions.WeatherData.Bus weaBus;

  // Fluid connectors
  Modelica.Fluid.Interfaces.FluidPort_a ports_406[2](
    redeclare package Medium = Medium)
    "Fluid connector a1 (positive design flow direction is from port_a1 to port_b1)";

  Modelica.Fluid.Interfaces.FluidPort_a ports_222[2](
    redeclare package Medium = Medium)
    "Fluid connector b (positive design flow direction is from port_a1 to port_b1)";

  // Operation modes
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntOcc( // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.occupied)
    "Constant signal for unoccupied mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isOcc // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    "Output true if unoccupied";

  // Zone load calculations
  parameter Modelica.SIunits.ThermalConductance UA_406=47.59
    "Thermal conductance of zone envelope with the ambient air [W/K].
    Heat flow into zone is positive and out is negative";
  parameter Modelica.SIunits.ThermalConductance UA_222=75.24
    "Thermal conductance of zone envelope with the ambient air [W/K].
    Heat flow into zone is positive and out is negative";

  parameter Real nOcc_406=3
    "Nominal number of occupants in zone";
  parameter Real nOcc_222=7
    "Nominal number of occupants in zone";

  Buildings.Controls.OBC.CDL.Continuous.Gain occSch_406(k=nOcc_406)
    "Zone 406 occupancy";
  Buildings.Controls.OBC.CDL.Continuous.Gain occSch_222(k=nOcc_222)
    "Zone 222 occupancy";

  Modelica.Blocks.Sources.CombiTimeTable occSch(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1,
    tableOnFile=false,
    table=[-5,   0;
            7,   0;7+1/2,   2/7;9-1/2,   2/7;9+1/2,   3/7;10+1/2,  6/7;13-1/2,  6/7;13+1/2,  5/7;15-1/2,  5/7;15+1/2,  7/7;19-1/2,  7/7;19,  0;
            31,  0;31+1/2,  2/7;33-1/2,  2/7;33+1/2,  3/7;34+1/2,  6/7;37-1/2,  6/7;37+1/2,  5/7;39-1/2,  5/7;39+1/2,  7/7;43-1/2,  7/7;43,  0;
            55,  0;55+1/2,  2/7;57-1/2,  2/7;57+1/2,  3/7;58+1/2,  6/7;61-1/2,  6/7;61+1/2,  5/7;63-1/2,  5/7;63+1/2,  7/7;67-1/2,  7/7;67,  0;
            79,  0;79+1/2,  2/7;81-1/2,  2/7;81+1/2,  3/7;82+1/2,  6/7;85-1/2,  6/7;85+1/2,  5/7;87-1/2,  5/7;87+1/2,  7/7;91-1/2,  7/7;91,  0;
            103, 0;103+1/2, 2/7;105-1/2, 2/7;105+1/2, 3/7;106+1/2, 6/7;109-1/2, 6/7;109+1/2, 5/7;111-1/2, 5/7;111+1/2, 7/7;115-1/2, 7/7;115, 0;
                                                                                                                                        139, 0;
                                                                                                                                        163, 0],
    timeScale=3600)
    "Occupancy schedule";

  Modelica.Blocks.Sources.CombiTimeTable occSch_occupied(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1,
    tableOnFile=false,
    table=[-5,   0;
            7,   0;7+1/2,   1;19-1/2,  1;19,  0;
            31,  0;31+1/2,  1;43-1/2,  1;43,  0;
            55,  0;55+1/2,  1;67-1/2,  1;67,  0;
            79,  0;79+1/2,  1;91-1/2,  1;91,  0;
            103, 0;103+1/2, 1;115-1/2, 1;115, 0;
                                         139, 0;
                                         163, 0],
    timeScale=3600)
    "On/off signal for equipment and lighting heat gains";

  parameter Modelica.SIunits.HeatFlowRate senIHGPeo_flow=75
    "Sensible heat gains per person [W/per], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  parameter Modelica.SIunits.HeatFlowRate latIHGPeo_flow=55
    "Latent heat gains per person [W/per], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  parameter Modelica.SIunits.DensityOfHeatFlowRate IHGEqu_flow=7.79
    "Equipment load factor [W/m2], (ASHRAE Fundamentals Handbook 2017, Table 11 Ch18, 100% desktop medium)";
  parameter Modelica.SIunits.DensityOfHeatFlowRate IHGLit_flow_406=12
    "Lighting load factor [W/m2], (ASHRAE Fundamentals Handbook 2017, Table 2 Ch18, Office enclosed)";
  parameter Modelica.SIunits.DensityOfHeatFlowRate IHGLit_flow_222=10.6
    "Lighting load factor [W/m2], (ASHRAE Fundamentals Handbook 2017, Table 2 Ch18, Office Open plan)";

  parameter Real radFraOcc=0.6 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Occupants typical office conditions";
  parameter Real conFraOcc=0.4 "convective factor, ASHRAE Fundamentals Ch18, table 14 Occupants typical office conditions";
  parameter Real radFraEqu=0.3 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Office without fan";
  parameter Real conFraEqu=0.7 "convective factor, ASHRAE Fundamentals Ch18, table 14 Office without fan";
  parameter Real radFraLit=0.6 "radiative factor, ASHRAE Fundamentals Ch18, table 3 fluorescent without lens, space fraction=1";
  parameter Real conFraLit=0.4 "convective factor, ASHRAE Fundamentals Ch18, table 3 Office without fan";
  parameter Real radFraWal=0.46 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Through walls and floors, through windows (SHGC<0.5)";
  parameter Real conFraWal=0.54 "convective factor, ASHRAE Fundamentals Ch18, table 14 Through walls and floors, through windows (SHGC<0.5)";

  parameter Modelica.SIunits.Area AWinNE_406=4.67*6.56*3*conv_ft_m^2
    "North east window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinNW_406=0*conv_ft_m^2
    "North west window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinSE_406=0*conv_ft_m^2
    "South east window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinSW_406=0*conv_ft_m^2
    "South west window area [m2], W * H * numWindows";

  parameter Modelica.SIunits.Area AWinNE_222=4.67*6.56*1*conv_ft_m^2
    "North east window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinNW_222=4.67*6.56*2*conv_ft_m^2
    "North west window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinSE_222=0*conv_ft_m^2
    "South east window area [m2], W * H * numWindows";
  parameter Modelica.SIunits.Area AWinSW_222=0*conv_ft_m^2
    "South west window area [m2], W * H * numWindows";

  // Solar heat gain from https://susdesign.com/windowheatgain/index.php
  // zip = 16801, city = Pittsburgh, surface = default or unknown surface, window = double-glazed clear (aluminum),
  // orientation = 40 deg. E of N, 40 deg. N of W, 40 deg. S of E, 40 deg. W of S
  Modelica.Blocks.Sources.CombiTimeTable norSolGaiNE(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableOnFile=false,
    table=[
    0		   	,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    5		   	,0.0000			,0.0000			,0.0000			,0.0000			,16.1298		,43.3333		,32.2596		,3.2246			,0.0000			,0.0000			,0.0000			,0.0000;
    6		   	,0.0000			,0.0000			,6.4526			,50.0000		,122.5789		,170.0000		,158.0632		,90.3228		,20.0000		,0.0000			,0.0000			,0.0000;
    7		   	,0.0000			,10.7158		,54.8386		,120.0000		,170.9684		,206.6667		,203.2246		,161.2912		,100.0000		,25.8070		,0.0000			,0.0000;
    8		   	,3.2246			,21.4281		,58.0632		,106.6667		,148.3860		,183.3333		,180.6456		,145.1614		,96.6667		,41.9368		,10.0000		,3.2246;
    9		   	,9.6772			,14.2842		,29.0316		,60.0000		,96.7754		,126.6667		,122.5789		,90.3228		,53.3333		,25.8070		,10.0000		,6.4526;
    10			,12.9018		,17.8561		,25.8070		,36.6667		,51.6140		,70.0000		,67.7404		,51.6140		,36.6667		,25.8070		,13.3333		,9.6772;
    11			,12.9018		,17.8561		,25.8070		,36.6667		,45.1614		,53.3333		,51.6140		,45.1614		,40.0000		,29.0316		,16.6667		,12.9018;
    12			,12.9018		,17.8561		,29.0316		,36.6667		,41.9368		,50.0000		,51.6140		,45.1614		,40.0000		,29.0316		,16.6667		,12.9018;
    13			,12.9018		,17.8561		,25.8070		,33.3333		,41.9368		,50.0000		,48.3860		,45.1614		,40.0000		,29.0316		,16.6667		,12.9018;
    14			,12.9018		,17.8561		,25.8070		,33.3333		,38.7088		,46.6667		,48.3860		,41.9368		,36.6667		,25.8070		,13.3333		,9.6772;
    15			,9.6772			,14.2842		,19.3544		,26.6667		,35.4842		,43.3333		,41.9368		,35.4842		,30.0000		,19.3544		,10.0000		,6.4526;
    16			,3.2246			,7.1439			,12.9018		,23.3333		,29.0316		,36.6667		,35.4842		,29.0316		,23.3333		,12.9018		,3.3333			,3.2246;
    17			,0.0000			,0.0000			,6.4526			,13.3333		,22.5789		,26.6667		,25.8070		,19.3544		,13.3333		,3.2246			,0.0000			,0.0000;
    18			,0.0000			,0.0000			,0.0000			,3.3333			,9.6772			,16.6667		,16.1298		,9.6772			,3.3333			,0.0000			,0.0000			,0.0000;
    19			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,3.3333			,3.2246			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    20			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    24			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000
    ],
    timeScale=3600)
    "Hourly solar heat gain [W/m^2] for north east window";

  Modelica.Blocks.Sources.CombiTimeTable norSolGaiNW(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableOnFile=false,
    table=[
    0			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    5			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,3.3333			,3.2258			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    6			,0.0000			,0.0000			,0.0000			,3.3333			,9.6774			,16.6667		,16.1290		,9.6774			,3.3333			,0.0000			,0.0000			,0.0000;
    7			,0.0000			,0.0000			,6.4516			,13.3333		,22.5806		,26.6667		,25.8065		,19.3548		,13.3333		,3.2258			,0.0000			,0.0000;
    8			,3.2258			,7.1429			,12.9032		,23.3333		,29.0323		,36.6667		,35.4839		,29.0323		,23.3333		,12.9032		,3.3333			,3.2258;
    9			,9.6774			,14.2857		,19.3548		,26.6667		,35.4839		,43.3333		,41.9355		,35.4839		,30.0000		,19.3548		,10.0000		,6.4516;
    10		,12.9032		,17.8571		,25.8065		,33.3333		,38.7097		,46.6667		,48.3871		,41.9355		,36.6667		,25.8065		,13.3333		,9.6774;
    11		,12.9032		,17.8571		,25.8065		,33.3333		,41.9355		,50.0000		,48.3871		,45.1613		,40.0000		,29.0323		,16.6667		,12.9032;
    12		,12.9032		,17.8571		,29.0323		,36.6667		,41.9355		,50.0000		,51.6129		,45.1613		,40.0000		,29.0323		,16.6667		,12.9032;
    13		,12.9032		,17.8571		,25.8065		,36.6667		,45.1613		,56.6667		,54.8387		,48.3871		,40.0000		,29.0323		,16.6667		,12.9032;
    14		,12.9032		,17.8571		,29.0323		,46.6667		,74.1935		,93.3333		,90.3226		,67.7419		,46.6667		,29.0323		,13.3333		,9.6774;
    15		,12.9032		,25.0000		,58.0645		,96.6667		,135.4839		,163.3333		,161.2903		,132.2581		,90.0000		,48.3871		,16.6667		,9.6774;
    16		,12.9032		,42.8571		,96.7742		,143.3333		,183.8710		,216.6667		,216.1290		,183.8710		,143.3333		,80.6452		,23.3333		,6.4516;
    17		,0.0000			,14.2857		,74.1935		,146.6667		,196.7742		,233.3333		,232.2581		,190.3226		,130.0000		,41.9355		,3.3333			,0.0000;
    18		,0.0000			,0.0000			,6.4516			,60.0000		,138.7097		,186.6667		,174.1935		,103.2258		,26.6667		,0.0000			,0.0000			,0.0000;
    19		,0.0000			,0.0000			,0.0000			,0.0000			,16.1290		,46.6667		,32.2581		,3.2258			,0.0000			,0.0000			,0.0000			,0.0000;
    20		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    24		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000
    ],
    timeScale=3600)
    "Hourly solar heat gain [W/m^2] for north west window";

  Modelica.Blocks.Sources.CombiTimeTable norSolGaiSE(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableOnFile=false,
    table=[
    0			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    5			,0.0000			,0.0000			,0.0000			,0.0000			,9.6774			,20.0000		,16.1290		,3.2258			,0.0000			,0.0000			,0.0000			,0.0000;
    6			,0.0000			,0.0000			,6.4516			,50.0000		,90.3226		,110.0000		,110.0000		,106.4516		,80.0000		,25.8065		,0.0000			,0.0000;
    7			,0.0000			,35.7143		,112.9032		,160.0000		,170.9677		,180.0000		,187.0968		,187.0968		,170.0000		,74.1935		,6.6667			,0.0000;
    8			,77.4194		,150.0000		,212.9032		,216.6667		,209.6774		,220.0000		,225.8065		,241.9355		,263.3333		,225.8065		,106.6667		,54.8387;
    9			,158.0645		,200.0000		,241.9355		,230.0000		,219.3548		,226.6667		,235.4839		,254.8387		,290.0000		,280.6452		,183.3333		,135.4839;
    10		,170.9677		,203.5714		,232.2581		,216.6667		,200.0000		,203.3333		,212.9032		,238.7097		,276.6667		,277.4194		,193.3333		,151.6129;
    11		,154.8387		,175.0000		,196.7742		,176.6667		,158.0645		,156.6667		,164.5161		,190.3226		,233.3333		,241.9355		,173.3333		,138.7097;
    12		,119.3548		,132.1429		,138.7097		,113.3333		,96.7742		,93.3333		,100.0000		,122.5806		,160.0000		,177.4194		,133.3333		,109.6774;
    13		,74.1935		,75.0000		,70.9677		,53.3333		,51.6129		,56.6667		,58.0645		,61.2903		,76.6667		,96.7742		,80.0000		,67.7419;
    14		,29.0323		,25.0000		,29.0323		,33.3333		,41.9355		,46.6667		,48.3871		,41.9355		,40.0000		,35.4839		,30.0000		,25.8065;
    15		,9.6774			,14.2857		,19.3548		,26.6667		,35.4839		,43.3333		,41.9355		,35.4839		,30.0000		,22.5806		,10.0000		,6.4516;
    16		,3.2258			,7.1429			,12.9032		,23.3333		,29.0323		,36.6667		,35.4839		,29.0323		,23.3333		,12.9032		,3.3333			,3.2258;
    17		,0.0000			,0.0000			,6.4516			,13.3333		,22.5806		,26.6667		,25.8065		,19.3548		,13.3333		,3.2258			,0.0000			,0.0000;
    18		,0.0000			,0.0000			,0.0000			,3.3333			,9.6774			,16.6667		,16.1290		,9.6774			,3.3333			,0.0000			,0.0000			,0.0000;
    19		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,3.3333			,3.2258			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    20		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    24		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000
    ],
    timeScale=3600)
    "Hourly solar heat gain [W/m^2] for south east window";

  Modelica.Blocks.Sources.CombiTimeTable norSolGaiSW(
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    tableOnFile=false,
    table=[
    0			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    5			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,3.2258			,3.2258			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    6			,0.0000			,0.0000			,0.0000			,3.2258			,9.6774			,16.1290		,16.1290		,9.6774			,3.2258			,0.0000			,0.0000			,0.0000;
    7			,0.0000			,0.0000			,6.4516			,12.9032		,22.5806		,25.8065		,25.8065		,19.3548		,12.9032		,3.2258			,0.0000			,0.0000;
    8			,3.2258			,6.4516			,12.9032		,22.5806		,29.0323		,35.4839		,35.4839		,29.0323		,22.5806		,12.9032		,6.4516			,3.2258;
    9			,16.1290		,16.1290		,22.5806		,29.0323		,35.4839		,41.9355		,41.9355		,38.7097		,29.0323		,25.8065		,19.3548		,16.1290;
    10		,54.8387		,48.3871		,45.1613		,35.4839		,41.9355		,48.3871		,48.3871		,45.1613		,48.3871		,64.5161		,58.0645		,51.6129;
    11		,103.2258		,96.7742		,103.2258		,74.1935		,61.2903		,58.0645		,64.5161		,80.6452		,109.6774		,141.9355		,109.6774		,96.7742;
    12		,145.1613		,141.9355		,167.7419		,132.2581		,112.9032		,100.0000		,112.9032		,141.9355		,183.8710		,212.9032		,154.8387		,132.2581;
    13		,170.9677		,174.1935		,212.9032		,180.6452		,161.2903		,151.6129		,167.7419		,200.0000		,238.7097		,261.2903		,187.0968		,154.8387;
    14		,180.6452		,190.3226		,235.4839		,206.4516		,193.5484		,187.0968		,203.2258		,232.2581		,270.9677		,287.0968		,196.7742		,161.2903;
    15		,158.0645		,180.6452		,235.4839		,209.6774		,200.0000		,193.5484		,212.9032		,238.7097		,270.9677		,277.4194		,177.4194		,135.4839;
    16		,77.4194		,132.2581		,196.7742		,187.0968		,183.8710		,177.4194		,193.5484		,212.9032		,232.2581		,212.9032		,100.0000		,54.8387;
    17		,0.0000			,29.0323		,103.2258		,132.2581		,138.7097		,135.4839		,148.3871		,154.8387		,141.9355		,67.7419		,6.4516			,0.0000;
    18		,0.0000			,0.0000			,6.4516			,38.7097		,67.7419		,74.1935		,77.4194		,61.2903		,19.3548		,0.0000			,0.0000			,0.0000;
    19		,0.0000			,0.0000			,0.0000			,0.0000			,6.4516			,12.9032		,9.6774			,3.2258			,0.0000			,0.0000			,0.0000			,0.0000;
    20		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000;
    24		,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000			,0.0000
    ],
    timeScale=3600)
    "Hourly solar heat gain [W/m^2] for south west window";

    parameter Real nonSolRTF[24]={
      0.22,
      0.10,
      0.06,
      0.05,
      0.05,
      0.04,
      0.04,
      0.04,
      0.04,
      0.03,
      0.03,
      0.03,
      0.03,
      0.03,
      0.03,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02}
      "Nonsolar Radiant Time Factors (RTF), (Table 19 ASHRAE Fundamentals 2017 Ch18: Medium, with carpet, 50% glass)";

    parameter Real solRTF[24]={
      0.26,
      0.12,
      0.07,
      0.05,
      0.04,
      0.04,
      0.03,
      0.03,
      0.03,
      0.03,
      0.03,
      0.03,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02,
      0.02}
      "Solar Radiant Time Factors (RTF), (Table 20 ASHRAE Fundamentals 2017 Ch18: Medium, with carpet, 50% glass)";

    parameter Real CTF[24]={
      0.034,
      0.033,
      0.032,
      0.032,
      0.034,
      0.037,
      0.041,
      0.044,
      0.046,
      0.048,
      0.049,
      0.050,
      0.049,
      0.049,
      0.048,
      0.047,
      0.046,
      0.044,
      0.043,
      0.041,
      0.040,
      0.039,
      0.037,
      0.036}
      "Conduction time factors (CTF) (column 3) (Table 16 ASHRAE Fundamentals 2017 Ch18: Brick, R-1.8, Insulation Board, 200 mm LW, Conc, Gyp. Board)";

  Buildings.Utilities.Time.CalendarTime calTim(zerTim=Buildings.Utilities.Time.Types.ZeroTime.NY2019)
    "Outputs month during simulation time";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.CDL.Routing.ExtractSignal extSig_norSolGaiNE(
    nin=12,
    nout=1,
    extract={calTim.month})
    "Extracts one month, simulation month, from the yearly data";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.CDL.Routing.ExtractSignal extSig_norSolGaiNW(
    nin=12,
    nout=1,
    extract={calTim.month})
    "Extracts one month, simulation month, from the yearly data";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.CDL.Routing.ExtractSignal extSig_norSolGaiSE(
    nin=12,
    nout=1,
    extract={calTim.month})
    "Extracts one month, simulation month, from the yearly data";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.CDL.Routing.ExtractSignal extSig_norSolGaiSW(
    nin=12,
    nout=1,
    extract={calTim.month})
    "Extracts one month, simulation month, from the yearly data";

  MultizoneVAV.LoadCalculation.RTSZoneLoad zonLoa_406(
    ARoo=ARoo_406,
    AWinNE=AWinNE_406,
    AWinNW=AWinNW_406,
    AWinSE=AWinSE_406,
    AWinSW=AWinSW_406,
    senIHGPeo_flow=senIHGPeo_flow,
    latIHGPeo_flow=latIHGPeo_flow,
    IHGEqu_flow=IHGEqu_flow,
    IHGLit_flow=IHGLit_flow_406,
    radFraOcc=radFraOcc,
    conFraOcc=conFraOcc,
    radFraEqu=radFraEqu,
    conFraEqu=conFraEqu,
    radFraLit=radFraLit,
    conFraLit=conFraLit,
    radFraWal=radFraWal,
    conFraWal=conFraWal,
    nonSolRTF=nonSolRTF,
    solRTF=solRTF,
    CTF=CTF,
    UA=UA_406)
    "Load calculation for zone 406";

  MultizoneVAV.LoadCalculation.RTSZoneLoad zonLoa_222(
    ARoo=ARoo_222,
    AWinNE=AWinNE_222,
    AWinNW=AWinNW_222,
    AWinSE=AWinSE_222,
    AWinSW=AWinSW_222,
    senIHGPeo_flow=senIHGPeo_flow,
    latIHGPeo_flow=latIHGPeo_flow,
    IHGEqu_flow=IHGEqu_flow,
    IHGLit_flow=IHGLit_flow_222,
    radFraOcc=radFraOcc,
    conFraOcc=conFraOcc,
    radFraEqu=radFraEqu,
    conFraEqu=conFraEqu,
    radFraLit=radFraLit,
    conFraLit=conFraLit,
    radFraWal=radFraWal,
    conFraWal=conFraWal,
    nonSolRTF=nonSolRTF,
    solRTF=solRTF,
    CTF=CTF,
    UA=UA_222)
    "Load calculation for zone 222";

  // Noise
  Modelica.Blocks.Math.Add addNoise_senTemRoo_222; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_senTemRoo_222( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senTemRoo_406; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_senTemRoo_406( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  Buildings.Utilities.Comfort.Fanger theCom_406(
    use_pAir_in=true,
    use_ICl_in=false,
    ICl=0.89,
    M=70,
    vAir=0.1)
    "Thermal comfort model";

  Buildings.Utilities.Comfort.Fanger theCom_222(
    use_pAir_in=true,
    use_ICl_in=false,
    ICl=0.89,
    M=70,
    vAir=0.1)
    "Thermal comfort model";

equation

  // Zone sensors
  connect(senTemRoo_406.port,zon_406.heatPort);
  connect(senTemRoo_222.port,zon_222.heatPort);
  connect(senCO2_406.port,zon_406.ports[3]);
  connect(senCO2_222.port,zon_222.ports[3]);
  connect(senRH_406.port,zon_406.ports[4]);
  connect(senRH_222.port,zon_222.ports[4]);

/*  connect(senTemRoo_406.T,T_multiplex2_1.u1[1]);
  connect(senTemRoo_222.T,T_multiplex2_1.u2[1]); // Noise Source */
  connect(normalNoise_senTemRoo_406.y, addNoise_senTemRoo_406.u1); // Noise Source
  connect(senTemRoo_406.T, addNoise_senTemRoo_406.u2); // Noise Source
  connect(addNoise_senTemRoo_406.y, T_multiplex2_1.u1[1]); // Noise Source
  connect(normalNoise_senTemRoo_222.y, addNoise_senTemRoo_222.u1); // Noise Source
  connect(senTemRoo_222.T, addNoise_senTemRoo_222.u2); // Noise Source
  connect(addNoise_senTemRoo_222.y, T_multiplex2_1.u2[1]); // Noise Source

  connect(T_multiplex2_1.y, TRooAir);
  connect(senCO2_406.C,CO2_multiplex2_1.u1[1]);
  connect(senCO2_222.C,CO2_multiplex2_1.u2[1]);
  connect(CO2_multiplex2_1.y,volFraCO2.m);
  connect(senRH_406.phi,RH_multiplex2_1.u1[1]);
  connect(senRH_222.phi,RH_multiplex2_1.u2[1]);
  connect(RH_multiplex2_1.y, RHRooAir);

  connect(occSch.y[1],occSch_406.u);
  connect(occSch.y[1],occSch_222.u);
  connect(occSch_406.y,nOcc_multiplex2_1.u1[1]);
  connect(occSch_222.y,nOcc_multiplex2_1.u2[1]);
  connect(nOcc_multiplex2_1.y, nOcc);

  connect(ports_222[1],zon_222.ports[1]);
  connect(ports_406[1],zon_406.ports[1]);
  connect(zon_222.ports[2],ports_222[2]);
  connect(zon_406.ports[2],ports_406[2]);

  connect(conIntOcc.y, isOcc.u1); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(uOpeMod, isOcc.u2); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted

  // CO2 and Water gains into zones
  connect(nOcc[1],gaiCO2_406.u);
  connect(gaiCO2_406.y,zon_406.C_flow[1]);

  connect(nOcc[1],gaiWat_406.u);
  connect(gaiWat_406.y,zon_406.mWat_flow);

  connect(nOcc[2],gaiCO2_222.u);
  connect(gaiCO2_222.y,zon_222.C_flow[1]);

  connect(nOcc[2],gaiWat_222.u);
  connect(gaiWat_222.y,zon_222.mWat_flow);

  // Zone load calculations
  connect(norSolGaiNE.y[:],extSig_norSolGaiNE.u);
  connect(norSolGaiNW.y[:],extSig_norSolGaiNW.u);
  connect(norSolGaiSE.y[:],extSig_norSolGaiSE.u);
  connect(norSolGaiSW.y[:],extSig_norSolGaiSW.u);

  connect(extSig_norSolGaiNE.y[1],zonLoa_406.norSolGaiNE.u);
  connect(extSig_norSolGaiNW.y[1],zonLoa_406.norSolGaiNW.u);
  connect(extSig_norSolGaiSE.y[1],zonLoa_406.norSolGaiSE.u);
  connect(extSig_norSolGaiSW.y[1],zonLoa_406.norSolGaiSW.u);

  connect(extSig_norSolGaiNE.y[1],zonLoa_222.norSolGaiNE.u);
  connect(extSig_norSolGaiNW.y[1],zonLoa_222.norSolGaiNW.u);
  connect(extSig_norSolGaiSE.y[1],zonLoa_222.norSolGaiSE.u);
  connect(extSig_norSolGaiSW.y[1],zonLoa_222.norSolGaiSW.u);

  connect(isOcc.y,zonLoa_406.isOcc); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(isOcc.y,zonLoa_222.isOcc); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted

  connect(nOcc[1],zonLoa_406.nOcc);
  connect(nOcc[2],zonLoa_222.nOcc);

  connect(occSch_occupied.y[1],zonLoa_406.occSch_occupied);
  connect(occSch_occupied.y[1],zonLoa_222.occSch_occupied);

  connect(weaBus.TDryBul,zonLoa_406.TOut);
  connect(senTemRoo_406.T,zonLoa_406.TRoo);

  connect(weaBus.TDryBul,zonLoa_222.TOut);
  connect(senTemRoo_222.T,zonLoa_222.TRoo);

  connect(zonLoa_406.cond_Q_flow.port, zon_406.heatPort);
  connect(zonLoa_406.IHG_Q_flow.port, zon_406.heatPort);
  connect(zonLoa_222.cond_Q_flow.port, zon_222.heatPort);
  connect(zonLoa_222.IHG_Q_flow.port, zon_222.heatPort);

  connect(senTemRoo_406.T, theCom_406.TAir);
  connect(senTemRoo_406.T, theCom_406.TRad);
  connect(RHRooAir[1], theCom_406.phi);
  connect(weaBus.pAtm, theCom_406.pAir_in);

  connect(senTemRoo_222.T, theCom_222.TAir);
  connect(senTemRoo_222.T, theCom_222.TRad);
  connect(RHRooAir[2], theCom_222.phi);
  connect(weaBus.pAtm, theCom_222.pAir_in);

end Floor;
