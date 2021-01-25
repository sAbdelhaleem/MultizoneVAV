within MultizoneVAV.UncertaintyModels.VAVReheat.ThermalZones;
model VAVBranch "Supply branch of a VAV system" // _99_02_benchmark

  constant Modelica.SIunits.SpecificHeatCapacity Cp_w
    "water specific heat [J/kg-K]";
  constant Modelica.SIunits.SpecificHeatCapacity Cp_a
    "air specific heat [J/kg-K]";

  // Adjustment to read components pressure drop
  Buildings.Fluid.Sensors.RelativePressure dpHeaCoi(
    redeclare package Medium = MediumA);
  Buildings.Fluid.Sensors.RelativePressure dpDam(
    redeclare package Medium = MediumA);

  // General parameters
  replaceable package MediumA = Modelica.Media.Interfaces.PartialMedium
    "Medium model for air";
  replaceable package MediumW = Modelica.Media.Interfaces.PartialMedium
    "Medium model for water";

  // Zone parameters
  parameter Modelica.SIunits.MassFlowRate mA_CooMax
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_HeaMax
    "Nominal heating maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMaxAct
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";

  parameter Modelica.SIunits.MassFlowRate mW_HeaCoi = mA_HeaMax*Cp_a*(latHea-eatHea)/(Cp_w*(HeaCoiEWT-lwtHea))
    "Nominal water mass flow rate for terminal coil [kg/s]";
  parameter Modelica.SIunits.PressureDifference dpA_HeaCoi
    "Maximum air pressure drop for terminal coil [Pa]";
  parameter Modelica.SIunits.PressureDifference dpA_dam
    "Nominal air pressure drop for terminal damper [Pa]";
  parameter Modelica.SIunits.PressureDifference dpW_HeaCoi
    "Nominal water pressure drop for terminal coil [Pa]";

  // Hot water valve designed to open 100% at 99.6% Heating Dry Bulb (6.7 F), ASHRAE Fundamentals: Ch14 Climatic Design Information
  parameter Modelica.SIunits.Temperature eatHea
    "Nominal entering air temperature for heating coil";
  parameter Modelica.SIunits.Temperature latHea
    "Nominal leaving air temperature for heating coil";
  parameter Modelica.SIunits.Temperature HeaCoiEWT
    "Nominal entering water temperature for heating coils [K]";
  parameter Modelica.SIunits.Temperature lwtHea
    "Nominal leaving water temperature for heating coil";
  parameter Modelica.SIunits.Efficiency eps
    "Heat exchanger effectiveness [1]";

  parameter Boolean allowFlowReversal=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal";

  // Damper
  Buildings.Fluid.Actuators.Dampers.PressureIndependent dam(
    redeclare package Medium = MediumA,
    m_flow_nominal=mA_CooMax,
    dp_nominal = dpA_dam,
    dpFixed_nominal=dpA_HeaCoi,
    allowFlowReversal=allowFlowReversal) "VAV box for room";

  // Heat exchanger
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness HeaCoi(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal = mA_HeaMax,
    m2_flow_nominal = mW_HeaCoi,
    dp1_nominal =  0,
    dp2_nominal = 0,
    allowFlowReversal1=allowFlowReversal,
    allowFlowReversal2=allowFlowReversal,
    eps=eps)
    "Heat exchanger of terminal box";
/*
  Buildings.Fluid.HeatExchangers.DryEffectivenessNTU HeaCoi(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=mA_HeaMax,
    m2_flow_nominal=mW_HeaCoi,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    Q_flow_nominal=eps*mA_HeaMax*Cp_a*(latHea-eatHea),
    dp1_nominal=0,
    dp2_nominal=0,
    allowFlowReversal1=allowFlowReversal,
    allowFlowReversal2=false,
    T_a1_nominal=eatHea,
    T_a2_nominal=HeaCoiEWT)
    "Heating coil";
*/
  Buildings.Fluid.Sources.MassFlowSource_T souWat_HeaCoi(
    nPorts=1,
    redeclare package Medium = MediumW,
    use_m_flow_in=true,
    T=HeaCoiEWT)
    "Source for water flow rate [kg/s]";

  Buildings.Fluid.Sources.FixedBoundary sinWat_HeaCoi(
    nPorts=1,
    redeclare package Medium = MediumW)
    "Sink for water circuit";

  Buildings.Controls.OBC.CDL.Continuous.Gain gaiWatFlo_Hea(
    final k=mW_HeaCoi)
    "Gain for HW mass flow rate [kg/s]";

  // Sensors
  Buildings.Fluid.Sensors.TemperatureTwoPort THeaCoi_a2(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_HeaCoi,
    allowFlowReversal=allowFlowReversal)
    "Entering water temperature sensor [K]";

  Buildings.Fluid.Sensors.TemperatureTwoPort THeaCoi_b2(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_HeaCoi,
    allowFlowReversal=allowFlowReversal)
    "Leaving water temperature sensor [K]";

  Buildings.Fluid.Sensors.VolumeFlowRate senVolFlo(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_CooMaxAct,
    allowFlowReversal=allowFlowReversal)
    "Sensor for volume flow rate [m3/s]";

  Buildings.Fluid.Sensors.TemperatureTwoPort senDAT(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_CooMaxAct,
    allowFlowReversal=allowFlowReversal)
    "Discharge air temperature [K]";

  // Inputs
  Modelica.Blocks.Interfaces.RealInput yVAV
    "Actuator position for VAV damper (0: closed, 1: open)";

  Modelica.Blocks.Interfaces.RealInput yVal
    "Actuator position for reheat valve (0: closed, 1: open)";

  // Fluid connectors
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare package Medium = MediumA)
    "Fluid connector a1 (positive design flow direction is from port_a1 to port_b1)";

  Modelica.Fluid.Interfaces.FluidPort_a port_b(
    redeclare package Medium = MediumA)
    "Fluid connector b (positive design flow direction is from port_a1 to port_b1)";

equation
  connect(port_a,HeaCoi.port_a1);
  connect(HeaCoi.port_b1,dam.port_a);
  connect(dam.port_b,senVolFlo.port_a);
  connect(senVolFlo.port_b,senDAT.port_a);
  connect(senDAT.port_b,port_b);

  connect(yVal,gaiWatFlo_Hea.u);
  connect(gaiWatFlo_Hea.y,souWat_HeaCoi.m_flow_in);
  connect(souWat_HeaCoi.ports[1],THeaCoi_a2.port_a);
  connect(THeaCoi_a2.port_b,HeaCoi.port_a2);
  connect(HeaCoi.port_b2,THeaCoi_b2.port_a);
  connect(THeaCoi_b2.port_b,sinWat_HeaCoi.ports[1]);

  connect(yVAV,dam.y);

  // Adjustment to read components pressure drop
  connect(HeaCoi.port_b1,dpHeaCoi.port_a);
  connect(HeaCoi.port_a1,dpHeaCoi.port_b);
  connect(dam.port_b,dpDam.port_a);
  connect(dam.port_a,dpDam.port_b);

end VAVBranch;
