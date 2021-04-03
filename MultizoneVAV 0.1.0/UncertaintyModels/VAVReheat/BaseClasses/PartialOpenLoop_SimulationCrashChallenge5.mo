within MultizoneVAV.UncertaintyModels.VAVReheat.BaseClasses;
partial model PartialOpenLoop_SimulationCrashChallenge5 // _99_12_benchmarkwoTMixNoiseMediumAccuracy
  "Partial model of variable air volume flow system with terminal reheat and five thermal zones"

  // General parameters
  package MediumA = Buildings.Media.Air(extraPropertiesNames={"CO2"})
    "Medium for air";
  package MediumW = Buildings.Media.Water
    "Medium for water";

  constant Integer numZon=2
    "Total number of served VAV boxes";

  parameter Boolean allowFlowReversal=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal";

  constant Modelica.SIunits.SpecificHeatCapacity Cp_w=4200
    "water specific heat [J/kg-K]";
  constant Modelica.SIunits.SpecificHeatCapacity Cp_a=1006
    "air specific heat [J/kg-K]";

//  parameter Real deltaMovAvg=5*60
//    "Used to prevent rapid engage/disengage of freeze protection when noise is added to MAT";

  Modelica.Blocks.Sources.Constant gaiWatFlo_ahuHea_freStaEng(final k=0.05)
    "AHU HW valve opening if freeze stat is engaged";

  Modelica.Blocks.Sources.Constant fanSpe_isUnOcc(final k=0)
    "Fan speed when AHU is off to prevent simulation failure";

  parameter Real yFanMin = 0.0
    "Lowest allowed fan speed if fan is on";

  parameter Modelica.SIunits.Area AFlo[numZon]={flo.ARoo_406,flo.ARoo_222}
    "Floor area of each zone";
  parameter Modelica.SIunits.Area ATot=sum(AFlo)
    "Total floor area";

  Modelica.Blocks.Sources.Constant Zer_s(final k=0)
    "Constant zero";
  Modelica.Blocks.Sources.Constant One_s(final k=1)
    "Constant one";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_occ_temp
    "Switch that output one if operation mode is occupied and zero otherwise";

  // Adjustment to set control into manual
  Modelica.Blocks.Sources.Constant ecoLockOut_s(final k=(32+459.67)*5/9)
    "Temperature to manually lock/unlock economizer functionality";
  Modelica.Blocks.Sources.Constant ovrRid_fanSpe(final k=0.745)
    "Manual fan speed signal";
  Modelica.Blocks.Sources.Constant ovrRid_yVAV_406(final k=1)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_yVAV_222(final k=1)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_yVal_406(final k=1)
    "DryEffectivenessNTU models can't be overidden with zero";
  Modelica.Blocks.Sources.Constant ovrRid_yVal_222(final k=1)
    "DryEffectivenessNTU models can't be overidden with zero";
  Modelica.Blocks.Sources.Constant ovrRid_ecoOut(final k=0.5)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_ecoRet(final k=0.5)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_ecoExh(final k=1)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_ahuCoo(final k=0)
    "Constant signal";
  Modelica.Blocks.Sources.Constant ovrRid_ahuHea(final k=1)
    "DryEffectivenessNTU models can't be overidden with zero";

  // Conversion factors
  constant Real conv_cfm_kgs=0.0765*0.45359237/60; // [lbm/ft^3]*[kg/lbm]/[s/min]
  constant Real conv_gpm_kgs=3.79/60; // [kg/gal]/[s/min]
  constant Real conv_ft_Pa=2988.98;
  constant Real conv_in_Pa=2988.98/12;
  constant Real conv_cfm_m3s=1./(35.3147*60);
  constant Real conv_volFrac_masFrac=(1./1.225)*1.842; // [m3_a/kg_a]*[kg_co2/m3_co2]
  constant Real conv_hp_W=745.699872;

  // Pressure loss in system, from duct pressure loss calculations
  parameter Modelica.SIunits.PressureDifference dpA_upStr_damOut=0.0601*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_damOut=0.035059*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dnStr_damRet=0.2374*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_damRet=0.0390534*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dnStr_damExh=0.40681*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_damExh=0.061021*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_upStr_fanSup=1.85949*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dnStr_fanSup=0.25456*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_balAdjAirFlo_terUni=.59*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_upStr_terUni_406=0.15674*conv_in_Pa+dpA_balAdjAirFlo_terUni;
  parameter Modelica.SIunits.PressureDifference dpA_dam_406=0.3227*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dnStr_terUni_406=0.9188*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_upStr_terUni_222=0.05697*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dam_222=0.3227*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_dnStr_terUni_222=1.01857*conv_in_Pa-dpA_balAdjAirFlo_terUni;
  parameter Modelica.SIunits.PressureDifference dpA_retDuc_406=0.49887*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_retDuc_222=0.49887*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dpA_retDuc=0.045*conv_in_Pa;

  // Supply fan curve parameters for Unit Size 03B (91/2-inch FC), TRANE Fan Performance Data for Unit Sizes 3 to 30
  parameter Modelica.SIunits.VolumeFlowRate vA_FanShuOff = 189.769*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_Fan_nominal = 1300*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_FanMed = 2311.5372*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_FanMaxFlo = 2737.0831*conv_cfm_m3s;
  parameter Modelica.SIunits.PressureDifference dp_FanShuOff= 2.045895*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_Fan_nominal= 1.98078*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_FanMed= 1.1215*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_FanMaxFlo= 0*conv_in_Pa;
  parameter Modelica.SIunits.HeatFlowRate P_FanShuOff= 0.260636*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_Fan_nominal= 0.9536104*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_FanMed= 2*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_FanMaxFlo= 2.53742*conv_hp_W;

/*
  // Supply fan curve parameters for Unit Size 03B (91/2-inch FC), TRANE Fan Performance Data for Unit Sizes 3 to 30
  parameter Modelica.SIunits.VolumeFlowRate vA_FanShuOff = 211.4076*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_Fan_nominal = 1300*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_FanMed = 2158.026*conv_cfm_m3s;
  parameter Modelica.SIunits.VolumeFlowRate vA_FanMaxFlo = 3078*conv_cfm_m3s;
  parameter Modelica.SIunits.PressureDifference dp_FanShuOff= 2.58605*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_Fan_nominal= 2.573*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_FanMed= 2.0459*conv_in_Pa;
  parameter Modelica.SIunits.PressureDifference dp_FanMaxFlo= 0*conv_in_Pa;
  parameter Modelica.SIunits.HeatFlowRate P_FanShuOff= 0.3719*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_Fan_nominal= 1.183579*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_FanMed= 2.27492*conv_hp_W;
  parameter Modelica.SIunits.HeatFlowRate P_FanMaxFlo= 3.712092*conv_hp_W;
*/
  // Duct static pressure trim & respond parameters
//  parameter Modelica.SIunits.PressureDifference pMinSet(displayUnit="Pa") = 0.1/12*conv_ft_Pa // with Trim and Respond
  parameter Modelica.SIunits.PressureDifference pMinSet(displayUnit="Pa") = 0.94/12*conv_ft_Pa // without Trim and Respond
    "Minimum setpoint for duct static pressure trim & respond";
//  parameter Modelica.SIunits.PressureDifference pMaxSet(displayUnit="Pa") = 2.586/12*conv_ft_Pa // with Trim and Respond
  parameter Modelica.SIunits.PressureDifference pMaxSet(displayUnit="Pa") = 0.94/12*conv_ft_Pa // without Trim and Respond
    "Maximum setpoint for duct static pressure trim & respond";
  parameter Modelica.SIunits.PressureDifference pIniSet(displayUnit="Pa") = 0.2617/12*conv_ft_Pa // with Trim and Respond
    "Initial setpoint for duct static pressure trim & respond";
  parameter Modelica.SIunits.PressureDifference pTriAmo(displayUnit="Pa") = -0.01/12*conv_ft_Pa
    "Trim amount for duct static pressure trim & respond";
  parameter Modelica.SIunits.PressureDifference pResAmo(displayUnit="Pa") = 0.04/12*conv_ft_Pa
    "Respond amount (must be opposite in to triAmo) for duct static pressure trim & respond";
  parameter Modelica.SIunits.Time pDelTim = 0*60
   "Delay time after which trim and respond is activated for duct static pressure trim & respond";
  parameter Integer pNumIgnReq=0
    "Number of ignorable requests for duct static pressure trim & respond";

  // AHU supply air temperature trim & respond parameters
  parameter Integer numIgnReqSupTem=0
    "Number of ignorable requests for supply temperature control";
  parameter Modelica.SIunits.Time delTimSupTem=0*60
    "Delay timer for supply temperature control";

  // AHU supply air temperature loop parameters
  parameter Real uHeaMax(min=-0.9)=-0.34
    "Upper limit of controller signal when heating coil is off. Require -1 < uHeaMax < uCooMin < 1.";
  parameter Real uCooMin(max=0.9)=0.34
    "Lower limit of controller signal when cooling coil is off. Require -1 < uHeaMax < uCooMin < 1.";

  // Occupancy schedule
  Buildings.Controls.SetPoints.OccupancySchedule occSch(occupancy=3600*{7,19,31,43,55,67,79,91,103,115},
  period=7*24*3600)
    "Occupancy schedule";

  // AHU parameters
  // AHU cooling coil parameters from FSB design documents
  parameter Modelica.SIunits.Temperature eatCoo=(76+459.67)*5/9
    "Nominal entering air temperature for cooling coil";
  parameter Modelica.SIunits.Temperature latCoo=(53.6+459.67)*5/9
    "Nominal leaving air temperature for cooling coil";
  parameter Modelica.SIunits.Temperature ewtCoo=(45+459.67)*5/9
    "Nominal entering water temperature for cooling coil";
  parameter Modelica.SIunits.Temperature lwtCoo=(55+459.67)*5/9
    "Nominal leaving water temperature for cooling coil";
  parameter Modelica.SIunits.SpecificEnthalpy eahCoo=48.89704e+3
    "Nominal entering air enthapy for cooling coil [J/kg], Tdb = 77 F, RH = 50%";
  parameter Modelica.SIunits.SpecificEnthalpy lahCoo=34.103763e+3
    "Nominal leaving air enthalpy for cooling coil [J/kg], Tdb = 53.6 F, RH = 100%";
  parameter Real eps_ahuCoo = 1
    "Heat exchanger UA factor";

  // Hot water valve designed to open 100% at 99% Heating Dry Bulb (6.7 F), ASHRAE Fundamentals: Ch14 Climatic Design Information
  parameter Modelica.SIunits.Temperature eatHea=(49.47+459.67)*5/9 // Mixed air temperature for the outdoor air design condition at minimum outdoor airflow and 70 F Return air temperature (zones maintaining set-points)
    "Nominal entering air temperature for heating coil";
  parameter Modelica.SIunits.Temperature latHea=(63.9+459.67)*5/9 // The fan will raise the temperature up to 65 F for VHeaMax
    "Nominal leaving air temperature for heating coil";
  parameter Modelica.SIunits.Temperature HeaCoiEWT=(180+459.67)*5/9
    "Nominal entering water temperature for heating coils [K]";
  parameter Modelica.SIunits.Temperature lwtHea=(162+459.67)*5/9
    "Nominal leaving water temperature for heating coil";
  parameter Modelica.SIunits.Efficiency eps_ahuHea = 1
    "Heat exchanger Q_flow_nominal factor";

  parameter Modelica.SIunits.Efficiency eps_ahuHea_conEff = 0.16
    "Heat exchanger Q_flow_nominal factor";

  parameter Modelica.SIunits.MassFlowRate mA_AHU = (VCooMax_222+VCooMax_406)*conv_cfm_kgs
    "Nominal AHU air mass flow rate [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_AHUAct = (VCooMaxAct_222+VCooMaxAct_406)*conv_cfm_kgs
    "Nominal AHU air mass flow rate [kg/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_AHU = (VCooMax_222+VCooMax_406)*conv_cfm_m3s
    "Nominal AHU volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_AHUAct = (VCooMaxAct_222+VCooMaxAct_406)*conv_cfm_m3s
    "Nominal AHU volume flow rate [m3/s]";

  parameter Modelica.SIunits.MassFlowRate mW_ahuCoo = mA_AHUAct*(eahCoo-lahCoo)/(Cp_w*(lwtCoo-ewtCoo))
    "Nominal water mass flow rate for AHU CHW coil [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mW_ahuHea = mA_AHUAct*Cp_a*(latHea-eatHea)/(Cp_w*(HeaCoiEWT-lwtHea))
    "Nominal water mass flow rate for AHU HW coil [kg/s]";

  parameter Modelica.SIunits.Temperature TOutMax=(70+459.67)*5/9
    "Maximum outdoor air temperature used to reset AHU supply air temperature";
  parameter Modelica.SIunits.Temperature TOutMin=(60+459.67)*5/9
    "Minimum outdoor air temperature used to reset AHU supply air temperature";
  parameter Modelica.SIunits.Temperature TSupMax=(65+459.67)*5/9
    "Maximum supply air temperature for AHU heating coil";
  parameter Modelica.SIunits.Temperature TSupMin=(55+459.67)*5/9
    "Minimum AHU supply air temperature for AHU cooling coil (before fan)";
  parameter Modelica.SIunits.Temperature TSupDes=(55+459.67)*5/9
    "Nominal AHU supply air temperature set-point";

  parameter Real VRetMax=1692
    "Nominal recirculation maximum flow rate for AHU [cfm]";
  parameter Modelica.SIunits.MassFlowRate mA_retMax = VRetMax*conv_cfm_kgs
    "Nominal recirculation maximum air mass flow rate [kg/s]";

  // Terminal Unit Parameters
  parameter Modelica.SIunits.Temperature THeaOn=(70+459.67)*5/9
    "Occupied zone heating set-point temperature";
  parameter Modelica.SIunits.Temperature TCooOn=(73+459.67)*5/9
    "Occupied zone cooling set-point temperature";
  parameter Modelica.SIunits.Temperature THeaOff=(60+459.67)*5/9
    "Unoccupied zone heating set-point temperature";
  parameter Modelica.SIunits.Temperature TCooOff=(85+459.67)*5/9
    "Unoccupied zone cooling set-point temperature";

  parameter Modelica.SIunits.Temperature DATMax_406=(85+459.67)*5/9
    "Maximum discharge air temperature for terminal coil";
  parameter Modelica.SIunits.Temperature DATMax_222=(85+459.67)*5/9
    "Maximum discharge air temperature for terminal coil";

  parameter Real VCooMax_406=870
    "Nominal cooling maximum flow rate for terminal [cfm]";
  parameter Real VCooMax_222=1245
    "Nominal cooling maximum flow rate for terminal [cfm]";
  parameter Real VCooMaxAct_406=400
    "Nominal cooling maximum flow rate for terminal [cfm]";
  parameter Real VCooMaxAct_222=900
    "Nominal cooling maximum flow rate for terminal [cfm]";
  parameter Real VHeaMax_406=320
    "Nominal heating maximum flow rate for terminal [cfm]";
  parameter Real VHeaMax_222=390
    "Nominal heating maximum flow rate for terminal [cfm]";
  parameter Real VMin_406=220
    "Nominal minimum flow rate for terminal [cfm]";
  parameter Real VMin_222=235
    "Nominal minimum flow rate for terminal [cfm]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMax_406 = VCooMax_406*conv_cfm_kgs
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMax_222 = VCooMax_222*conv_cfm_kgs
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMaxAct_406 = VCooMaxAct_406*conv_cfm_kgs
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_CooMaxAct_222 = VCooMaxAct_222*conv_cfm_kgs
    "Nominal cooling maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_HeaMax_406 = VHeaMax_406*conv_cfm_kgs
    "Nominal heating maximum mass flow rate for terminal [kg/s]";
  parameter Modelica.SIunits.MassFlowRate mA_HeaMax_222 = VHeaMax_222*conv_cfm_kgs
    "Nominal heating maximum mass flow rate for terminal [kg/s]";

  parameter Modelica.SIunits.VolumeFlowRate vA_CooMaxAct_406 = VCooMaxAct_406*conv_cfm_m3s
    "Nominal cooling maximum volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_CooMaxAct_222 = VCooMaxAct_222*conv_cfm_m3s
    "Nominal cooling maximum volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_Min_406 = VMin_406*conv_cfm_m3s
    "Nominal minimum volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_Min_222 = VMin_222*conv_cfm_m3s
    "Nominal minimum volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_HeaMax_406 = VHeaMax_406*conv_cfm_m3s
    "Nominal heating maximum volume flow rate [m3/s]";
  parameter Modelica.SIunits.VolumeFlowRate vA_HeaMax_222 = VHeaMax_222*conv_cfm_m3s
    "Nominal heating maximum volume flow rate [m3/s]";

  // Hot water valve designed to open 100% at 99% Heating Dry Bulb (6.7 F), ASHRAE Fundamentals: Ch14 Climatic Design Information
  parameter Modelica.SIunits.Temperature eatHea_406=(64.5+459.67)*5/9
    "Nominal entering air temperature for heating coil";
  parameter Modelica.SIunits.Temperature latHea_406=(85+459.67)*5/9
    "Nominal leaving air temperature for heating coil";
  parameter Modelica.SIunits.Efficiency epsTerUni_406 = 1
    "Heat exchanger Q_flow_nominal factor";

  parameter Modelica.SIunits.Efficiency epsTerUni_406_conEff = 0.175
    "Heat exchanger Q_flow_nominal factor";

  parameter Modelica.SIunits.Temperature eatHea_222=(64.5+459.67)*5/9
    "Nominal entering air temperature for heating coil";
  parameter Modelica.SIunits.Temperature latHea_222=(85+459.67)*5/9
    "Nominal leaving air temperature for heating coil";
  parameter Modelica.SIunits.Efficiency epsTerUni_222 = 1
    "Heat exchanger Q_flow_nominal factor";

  parameter Modelica.SIunits.Efficiency epsTerUni_222_conEff = 0.195
    "Heat exchanger Q_flow_nominal factor";

  // Weather data
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam="modelica://MultizoneVAV/UncertaintyModels/LibraryModifications/Buildings_S/Resources/weatherdata/USA_PA_State.College-Penn.State.University.725128_TMY3.mos")
    "Weather data reader";
  Buildings.BoundaryConditions.WeatherData.Bus weaBus;
  Buildings.Fluid.Sources.Outside amb(
    redeclare package Medium = MediumA,
    nPorts=4,
    use_C_in=true)
    "Ambient conditions";
  Modelica.Blocks.Sources.Constant CO2_amb[1](
    k=4.5E-4*conv_volFrac_masFrac)
    "Mass fraction of CO2 in ambient air [kg_co2/kg_air]";

  // Terminal units
  MultizoneVAV.UncertaintyModels.VAVReheat.ThermalZones.VAVBranch terUni_406(
    redeclare package MediumA=MediumA,
    redeclare package MediumW=MediumW,
    Cp_a=Cp_a,
    Cp_w=Cp_w,
    mA_CooMax=mA_CooMax_406,
    mA_HeaMax=mA_HeaMax_406,
    mA_CooMaxAct=mA_CooMaxAct_406,
    dpA_HeaCoi=dpA_upStr_terUni_406+dpA_dnStr_terUni_406,
    dpW_HeaCoi=0,
    dpA_dam=dpA_dam_406,
    allowFlowReversal=allowFlowReversal,
    eatHea=eatHea_406,
    latHea=latHea_406,
    HeaCoiEWT=HeaCoiEWT,
    lwtHea=lwtHea,
//    eps=epsTerUni_406)
    eps=epsTerUni_406_conEff)
    "Zone 406 terminal unit";

  MultizoneVAV.UncertaintyModels.VAVReheat.ThermalZones.VAVBranch terUni_222(
    redeclare package MediumA=MediumA,
    redeclare package MediumW=MediumW,
    Cp_a=Cp_a,
    Cp_w=Cp_w,
    mA_CooMax=mA_CooMax_222,
    mA_HeaMax=mA_HeaMax_222,
    mA_CooMaxAct=mA_CooMaxAct_222,
    dpA_HeaCoi=dpA_upStr_terUni_222+dpA_dnStr_terUni_222,
    dpW_HeaCoi=0,
    dpA_dam=dpA_dam_222,
    allowFlowReversal=allowFlowReversal,
    eatHea=eatHea_222,
    latHea=latHea_222,
    HeaCoiEWT=HeaCoiEWT,
    lwtHea=lwtHea,
//    eps=epsTerUni_222)
    eps=epsTerUni_222_conEff)
    "Zone 222 terminal unit";

  // Floor
  MultizoneVAV.UncertaintyModels.VAVReheat.ThermalZones.Floor flo(
    redeclare final package Medium = MediumA,
    numZon=numZon,
    mA_CooMaxAct_406=mA_CooMaxAct_406,
    mA_CooMaxAct_222=mA_CooMaxAct_222)
    "Model of a floor of the building that is served by this VAV system";

  // Duct fittings
  Buildings.Fluid.FixedResistances.Junction splRet_406(
    redeclare package Medium = MediumA,
    m_flow_nominal={mA_AHUAct,mA_AHUAct - mA_CooMaxAct_406,
        mA_CooMaxAct_406},
    from_dp=false,
    linearized=true,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    dp_nominal(each displayUnit="Pa") = {0,0,0},
    portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Entering)
    "Splitter for room return";

  Buildings.Fluid.FixedResistances.Junction splSup_406(
    redeclare package Medium = MediumA,
    m_flow_nominal={mA_AHUAct,mA_AHUAct - mA_CooMaxAct_406,
        mA_CooMaxAct_406},
    from_dp=true,
    linearized=true,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    dp_nominal(each displayUnit="Pa") = {0,0,0},
    portFlowDirection_1=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=if allowFlowReversal then Modelica.Fluid.Types.PortFlowDirection.Bidirectional
         else Modelica.Fluid.Types.PortFlowDirection.Leaving)
    "Splitter for room supply";

  // AHU coils
  Buildings.Fluid.HeatExchangers.WetCoilCounterFlow ahuCoo(
    UA_nominal=eps_ahuCoo*mW_ahuCoo*Cp_w*(lwtCoo-ewtCoo)/
        Buildings.Fluid.HeatExchangers.BaseClasses.lmtd(
        T_a1=eatCoo,
        T_b1=latCoo,
        T_a2=ewtCoo,
        T_b2=lwtCoo),
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumA,
    m1_flow_nominal=mW_ahuCoo,
    m2_flow_nominal=mA_AHUAct,
    dp2_nominal=0,
    dp1_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    allowFlowReversal1=false,
    allowFlowReversal2=allowFlowReversal)
    "Cooling coil";
/*
  Buildings.Fluid.HeatExchangers.DryEffectivenessNTU ahuHea(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=mA_AHUAct,
    m2_flow_nominal=mW_ahuHea,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    Q_flow_nominal=eps_ahuHea*mA_AHUAct*Cp_a*(latHea-eatHea),
    dp1_nominal=0,
    dp2_nominal=0,
    allowFlowReversal1=allowFlowReversal,
    allowFlowReversal2=false,
    T_a1_nominal=eatHea,
    T_a2_nominal=HeaCoiEWT)
    "Heating coil";
*/
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness ahuHea(
    redeclare package Medium1 = MediumA,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal = mA_AHUAct,
    m2_flow_nominal = mW_ahuHea,
    dp1_nominal = 0,
    dp2_nominal = 0,
    allowFlowReversal1=allowFlowReversal,
    allowFlowReversal2=false,
    eps=eps_ahuHea_conEff)
    "Heating coil";

  Buildings.Fluid.Sources.MassFlowSource_T souWat_ahuCoo(
    nPorts=1,
    redeclare package Medium = MediumW,
    use_m_flow_in=true,
    T=ewtCoo)
    "Source for water flow rate";
  Buildings.Fluid.Sources.MassFlowSource_T souWat_ahuHea(
    nPorts=1,
    redeclare package Medium = MediumW,
    use_m_flow_in=true,
    T=HeaCoiEWT)
    "Source for water flow rate";

  Buildings.Fluid.Sources.FixedBoundary sinWat_ahuCoo(
    nPorts=1,
    redeclare package Medium = MediumW)
    "Sink for water circuit";
  Buildings.Fluid.Sources.FixedBoundary sinWat_ahuHea(
    nPorts=1,
    redeclare package Medium = MediumW)
    "Sink for water circuit";

  Buildings.Controls.OBC.CDL.Continuous.Gain gaiWatFlo_ahuCoo(
    final k=mW_ahuCoo)
    "Gain for CHW mass flow rate";
  Buildings.Controls.OBC.CDL.Continuous.Gain gaiWatFlo_ahuHea(
    final k=mW_ahuHea)
    "Gain for HW mass flow rate";

  // Pressure Drop
  Buildings.Fluid.FixedResistances.PressureDrop dp_retDuc(
    m_flow_nominal=mA_AHU,
    redeclare package Medium = MediumA,
    allowFlowReversal=allowFlowReversal,
    dp_nominal=dpA_retDuc+dpA_retDuc_406+dpA_retDuc_222)
    "Static pressure loss for return duct";

  Buildings.Fluid.FixedResistances.PressureDrop dp_supDuc(
    m_flow_nominal=mA_AHU,
    redeclare package Medium = MediumA,
    allowFlowReversal=allowFlowReversal,
    dp_nominal=dpA_upStr_fanSup+dpA_dnStr_fanSup)
    "Static pressure loss for return duct";

  // AHU fans
  Buildings.Fluid.Movers.SpeedControlled_y fanSup(
    redeclare package Medium = MediumA,
    per(use_powerCharacteristic=true),
    per(pressure(V_flow={vA_FanShuOff,vA_Fan_nominal,vA_FanMed,vA_FanMaxFlo}, dp={dp_FanShuOff,dp_Fan_nominal,dp_FanMed,dp_FanMaxFlo})),
    per(power(V_flow={vA_FanShuOff,vA_Fan_nominal,vA_FanMed,vA_FanMaxFlo}, P={P_FanShuOff,P_Fan_nominal,P_FanMed,P_FanMaxFlo})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Supply air fan";

  // AHU Mixing Box
  Buildings.Examples.VAVReheat.BaseClasses.MixingBox eco(
    redeclare package Medium = MediumA,
    mOut_flow_nominal=mA_AHU,
    dpOut_nominal=dpA_upStr_damOut,
    mRec_flow_nominal=mA_retMax,
    dpRec_nominal=dpA_dnStr_damRet,
    mExh_flow_nominal=mA_AHU,
    dpExh_nominal=dpA_dnStr_damExh,
    from_dp=false,
    damOut(dpDamOpe_nominal=dpA_damOut),
    damRet(dpDamOpe_nominal=dpA_damRet),
    damExh(dpDamOpe_nominal=dpA_damExh))
    "Mixing box";

  // Freeze protection
  Buildings.Controls.OBC.CDL.Logical.OnOffController freSta(bandwidth=1)
    "Freeze stat for heating coil";
//  parameter Modelica.SIunits.Temperature TFreSet=(40+459.67)*5/9 // Used to enable freeze stat functionality
  parameter Modelica.SIunits.Temperature TFreSet=(-20+459.67)*5/9
    "Mixed air temperature below which freeze stat is engaged"; // Used to disable freeze stat functionality
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant freStaTSetPoi(
    k=TFreSet)
    "Freeze stat set point for heating coil";
  parameter Modelica.SIunits.Temperature freProThrVal = (34+459.67)*5/9
    "Threshold zone temperature value to activate freeze protection mode";
  parameter Modelica.SIunits.Temperature freProEndVal = (45+459.67)*5/9
    "Threshold zone temperature value to finish the freeze protection mode";
  parameter Boolean use_TMix=false
    "Set to true if mixed air temperature measurement is enabled";

  // Zone sensors
  Modelica.Blocks.Routing.Multiplex2 DAT_multiplex2_1;
  Modelica.Blocks.Interfaces.RealOutput DAT[numZon]
    "Discharge air temperature [K]";

  Modelica.Blocks.Routing.Multiplex2 vA_zon_multiplex2_1;
  Modelica.Blocks.Interfaces.RealOutput vA_zon[numZon]
    "Terminals airflow [m3/s]";

  // AHU sensors
  Buildings.Fluid.Sensors.TemperatureTwoPort senSAT(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "AHU supply air temperature [K]";
  Buildings.Fluid.Sensors.TemperatureTwoPort senRAT(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "AHU return air temperature [K]";

  Buildings.Fluid.Sensors.VolumeFlowRate senVolFloSup(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "Sensor for volume flow rate [m3/s]";

  Buildings.Fluid.Sensors.VolumeFlowRate senVolFloOut(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "Sensor for volume flow rate [m3/s]";

  Buildings.Fluid.Sensors.TemperatureTwoPort TahuCoo_a2(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "CHW coil entering air temperature";
  Buildings.Fluid.Sensors.TemperatureTwoPort TahuCoo_b2(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "CHW coil leaving air temperature";
  Buildings.Fluid.Sensors.TemperatureTwoPort TahuCoo_a1(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_ahuCoo,
    allowFlowReversal=allowFlowReversal)
    "CHW coil entering water temperature";
  Buildings.Fluid.Sensors.TemperatureTwoPort TahuCoo_b1(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_ahuCoo,
    allowFlowReversal=allowFlowReversal)
    "CHW coil leaving water temperature";

  Buildings.Fluid.Sensors.TemperatureTwoPort TMix(
    redeclare package Medium = MediumA,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mA_AHUAct,
    allowFlowReversal=allowFlowReversal)
    "AHU HW coil entering air temperature";
//  Buildings.Controls.OBC.CDL.Continuous.MovingMean movAvg_TMix(
//    delta=deltaMovAvg)
//    "Used to prevent rapid engage/disengage of freeze protection when noise is added to MAT";

  Buildings.Fluid.Sensors.TemperatureTwoPort TahuHea_a2(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_ahuHea,
    allowFlowReversal=allowFlowReversal)
    "AHU HW coil entering water temperature";
  Buildings.Fluid.Sensors.TemperatureTwoPort TahuHea_b2(
    redeclare package Medium = MediumW,
    initType=Modelica.Blocks.Types.Init.InitialState,
    m_flow_nominal=mW_ahuHea,
    allowFlowReversal=allowFlowReversal)
    "AHU HW coil leaving water temperature";

  Buildings.Fluid.Sensors.RelativePressure dpUpStrFanSup(
    redeclare package Medium = MediumA)
    "Static pressure loss upstream supply fan";

  Buildings.Fluid.Sensors.RelativePressure dpFanSup(
    redeclare package Medium = MediumA)
    "Supply fan total static pressure raise";

  Buildings.Fluid.Sensors.RelativePressure dpRetDuc(
    redeclare package Medium = MediumA)
    "Static pressure loss for return duct";

  Buildings.Fluid.Sensors.RelativePressure dpDisSupFan(
    redeclare package Medium = MediumA)
    "Supply fan static discharge pressure";

  Buildings.Fluid.Sensors.TraceSubstances senCO2_amb(
    redeclare package Medium = MediumA)
    "Sensor outdoor";
  Buildings.Fluid.Sensors.Conversions.To_VolumeFraction volFraCO2_amb(
    MMMea=Modelica.Media.IdealGases.Common.SingleGasesData.CO2.MM)
    "CO2 volume fraction";

  // Noise
  Modelica.Blocks.Math.Add addNoise_406_yDam; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_406_yDam_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_406_yDam( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.01/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_406_yVal; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_406_yVal_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_406_yVal( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.05/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_222_yDam; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_222_yDam_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_222_yDam( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.01/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_222_yVal; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_222_yVal_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_222_yVal( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.05/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_gaiCooCoi_u; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_gaiCooCoi_u_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_gaiCooCoi_u( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.05/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_swiFreSta_u3; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_swiFreSta_u3_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_swiFreSta_u3( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.05/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_fanSup_y; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_fanSup_y_Lmt(uMin=0); // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_fanSup_y( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.01/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senSAT; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_senSAT( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senVolFloOut; // Noise Source
  MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks.Noise.NormalNoise_S normalNoise_senVolFloOut( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=(0.03/2)*senVolFloOut.V_flow); // Noise Source

//  Modelica.Blocks.Math.Add addNoise_TMix; // Noise Source
//  Modelica.Blocks.Noise.NormalNoise normalNoise_TMix( // Noise Source
//    startTime=15, // Noise Source
//    samplePeriod=30, // Noise Source
//    mu=0, // Noise Source
//    sigma=0.2/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_dpDisSupFan; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_dpDisSupFan( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=5/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_eco_yOut; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_eco_yOut_Lmt(uMin=0); // Noise Source
  MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks.Noise.NormalNoise_S normalNoise_eco_yOut( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.01/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_eco_yRet; // Noise Source
  Modelica.Blocks.Nonlinear.Limiter addNoise_eco_yRet_Lmt(uMin=0); // Noise Source
  MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks.Noise.NormalNoise_S normalNoise_eco_yRet( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.01/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senDAT_406; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_senDAT_406( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senDAT_222; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_senDAT_222( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  Modelica.Blocks.Math.Add addNoise_senVolFlo_406; // Noise Source
  MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks.Noise.NormalNoise_S normalNoise_senVolFlo_406( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=(0.03/2)*terUni_406.senVolFlo.V_flow); // Noise Source
  Modelica.Blocks.Math.Add addNoise_senVolFlo_222; // Noise Source

  MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks.Noise.NormalNoise_S normalNoise_senVolFlo_222( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=(0.03/2)*terUni_222.senVolFlo.V_flow); // Noise Source

  Modelica.Blocks.Math.Add addNoise_TOut; // Noise Source
  Modelica.Blocks.Noise.NormalNoise normalNoise_TOut( // Noise Source
    startTime=15, // Noise Source
    samplePeriod=30, // Noise Source
    mu=0, // Noise Source
    sigma=0.2/2); // Noise Source

  // Energy use calculation from LBNL Buildings.Examples.VAVReheat.BaseClasses.PartialOpenLoop
  Results res(
    final A=ATot,
    PFan=fanSup.P + 0,
    PHea=ahuHea.Q1_flow + terUni_406.HeaCoi.Q1_flow + terUni_222.HeaCoi.Q1_flow,
    PCooSen=ahuCoo.QSen2_flow,
    PCooLat=ahuCoo.QLat2_flow) "Results of the simulation";

protected
  model Results "Model to store the results of the simulation"
    parameter Modelica.SIunits.Area A "Floor area";
    input Modelica.SIunits.Power PFan "Fan energy";
    input Modelica.SIunits.Power PHea "Heating energy";
    input Modelica.SIunits.Power PCooSen "Sensible cooling energy";
    input Modelica.SIunits.Power PCooLat "Latent cooling energy";

    Real EFan(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Fan energy";
    Real EHea(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Heating energy";
    Real ECooSen(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Sensible cooling energy";
    Real ECooLat(
      unit="J/m2",
      start=0,
      nominal=1E5,
      fixed=true) "Latent cooling energy";
    Real ECoo(unit="J/m2") "Total cooling energy";
  equation

    A*der(EFan) = PFan;
    A*der(EHea) = PHea;
    A*der(ECooSen) = PCooSen;
    A*der(ECooLat) = PCooLat;
    ECoo = ECooSen + ECooLat;

  end Results;

equation

  // Weather data connections
  connect(weaDat.weaBus, weaBus);
  connect(weaBus,amb.weaBus);
  connect(weaBus, flo.weaBus);
  connect(CO2_amb.y,amb.C_in);

  // AHU componenet connections
  connect(amb.ports[1],senVolFloOut.port_a);
  connect(senVolFloOut.port_b,eco.port_Out);
  connect(eco.port_Sup,TMix.port_a);
  connect(TMix.port_b,dp_supDuc.port_a);
  connect(dp_supDuc.port_b,ahuHea.port_a1);
  connect(ahuHea.port_b1,TahuCoo_a2.port_a);
  connect(TahuCoo_a2.port_b,ahuCoo.port_a2);
  connect(ahuCoo.port_b2,TahuCoo_b2.port_a);
  connect(TahuCoo_b2.port_b,fanSup.port_a);
  connect(fanSup.port_b,senVolFloSup.port_a);
  connect(senVolFloSup.port_b,senSAT.port_a);
  connect(senSAT.port_b,splSup_406.port_1);

  connect(splSup_406.port_2,terUni_222.port_a);
  connect(terUni_222.port_b,flo.ports_222[1]);
  connect(flo.ports_222[2],splRet_406.port_2);

  connect(splSup_406.port_3,terUni_406.port_a);
  connect(terUni_406.port_b,flo.ports_406[1]);
  connect(flo.ports_406[2],splRet_406.port_3);

  connect(splRet_406.port_1,senRAT.port_a);
  connect(senRAT.port_b,dp_retDuc.port_a);
  connect(dp_retDuc.port_b,eco.port_Ret);
  connect(eco.port_Exh,amb.ports[2]);

  // AHU heating coil water source
  connect(gaiWatFlo_ahuHea.y,souWat_ahuHea.m_flow_in);
  connect(souWat_ahuHea.ports[1],TahuHea_a2.port_a);
  connect(TahuHea_a2.port_b,ahuHea.port_a2);
  connect(ahuHea.port_b2,TahuHea_b2.port_a);
  connect(TahuHea_b2.port_b,sinWat_ahuHea.ports[1]);

  // AHU cooling coil water source
  connect(gaiWatFlo_ahuCoo.y,souWat_ahuCoo.m_flow_in);
  connect(souWat_ahuCoo.ports[1],TahuCoo_a1.port_a);
  connect(TahuCoo_a1.port_b,ahuCoo.port_a1);
  connect(ahuCoo.port_b1,TahuCoo_b1.port_a);
  connect(TahuCoo_b1.port_b,sinWat_ahuCoo.ports[1]);

  // AHU sensors
  connect(fanSup.port_b, dpDisSupFan.port_a);
  connect(amb.ports[3], dpDisSupFan.port_b);
  connect(amb.ports[4],senCO2_amb.port);
  connect(senCO2_amb.C, volFraCO2_amb.m);

//  connect(ahuHea.port_b1, dpUpStrFanSup.port_a);
//  connect(ahuHea.port_a1, dpUpStrFanSup.port_b);
  connect(dp_supDuc.port_b, dpUpStrFanSup.port_a);
  connect(dp_supDuc.port_a, dpUpStrFanSup.port_b);
  connect(fanSup.port_b, dpFanSup.port_a);
  connect(fanSup.port_a, dpFanSup.port_b);
  connect(dp_retDuc.port_b, dpRetDuc.port_a);
  connect(dp_retDuc.port_a, dpRetDuc.port_b);

  // Terminal units sensors
/*  connect(terUni_406.senDAT.T,DAT_multiplex2_1.u1[1]);
  connect(terUni_222.senDAT.T,DAT_multiplex2_1.u2[1]); // Noise Source */
  connect(normalNoise_senDAT_406.y, addNoise_senDAT_406.u1); // Noise Source
  connect(terUni_406.senDAT.T, addNoise_senDAT_406.u2); // Noise Source
  connect(addNoise_senDAT_406.y, DAT_multiplex2_1.u1[1]); // Noise Source
  connect(normalNoise_senDAT_222.y, addNoise_senDAT_222.u1); // Noise Source
  connect(terUni_222.senDAT.T, addNoise_senDAT_222.u2); // Noise Source
  connect(addNoise_senDAT_222.y, DAT_multiplex2_1.u2[1]); // Noise Source

  connect(DAT_multiplex2_1.y,DAT);

/*  connect(terUni_406.senVolFlo.V_flow,vA_zon_multiplex2_1.u1[1]);
  connect(terUni_222.senVolFlo.V_flow,vA_zon_multiplex2_1.u2[1]); // Noise Source */
  connect(normalNoise_senVolFlo_406.y, addNoise_senVolFlo_406.u1); // Noise Source
  connect(terUni_406.senVolFlo.V_flow, addNoise_senVolFlo_406.u2); // Noise Source
  connect(addNoise_senVolFlo_406.y, vA_zon_multiplex2_1.u1[1]); // Noise Source
  connect(normalNoise_senVolFlo_222.y, addNoise_senVolFlo_222.u1); // Noise Source
  connect(terUni_222.senVolFlo.V_flow, addNoise_senVolFlo_222.u2); // Noise Source
  connect(addNoise_senVolFlo_222.y, vA_zon_multiplex2_1.u2[1]); // Noise Source

  connect(vA_zon_multiplex2_1.y,vA_zon);

  // Freeze protection
  connect(freStaTSetPoi.y, freSta.reference);
  connect(TMix.T,freSta.u); // Noise Source
//  connect(normalNoise_TMix.y, addNoise_TMix.u1); // Noise Source
//  connect(TMix.T, addNoise_TMix.u2); // Noise Source
//  connect(addNoise_TMix.y,movAvg_TMix.u); // Noise Source
//  connect(movAvg_TMix.y,freSta.u); // Noise Source

  // Switch that output one if operation mode is occupied and zero otherwise
  connect(One_s.y,swi_occ_temp.u1);
  connect(flo.isOcc.y,swi_occ_temp.u2);
  connect(Zer_s.y,swi_occ_temp.u3);

end PartialOpenLoop_SimulationCrashChallenge5;
