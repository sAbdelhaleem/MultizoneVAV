within MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone;
block Controller "Multizone AHU controller that composes subsequences for controlling fan speed, dampers, and supply air temperature" // _99_01_benchmark

  parameter Real kTSup_ahuHea(final unit="1/K")=0.05;
  parameter Modelica.SIunits.Time TiTSup_ahuHea=600;
  parameter Real kTSup_ahuCoo(final unit="1/K")=0.05;
  parameter Modelica.SIunits.Time TiTSup_ahuCoo=600;
  parameter Real kTSup_ahuEco(final unit="1/K")=0.05;
  parameter Modelica.SIunits.Time TiTSup_ahuEco=600;

  constant Real conv_cfm_m3s=1./(35.3147*60);
  constant Real conv_ft_m=0.3048;
  constant Real conv_ft_Pa=2988.98;
  parameter Integer numZon(min=2) "Total number of served VAV boxes";
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TOut(
    final unit="K",
    final quantity="ThermodynamicTemperature") "Outdoor air temperature";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSup(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "Measured supply air temperature";

  parameter Modelica.SIunits.PressureDifference pIniSet(displayUnit="Pa") = 0.24/12*conv_ft_Pa
    "Initial setpoint";
  parameter Modelica.SIunits.PressureDifference pMinSet(displayUnit="Pa") = 0.1/12*conv_ft_Pa
    "Minimum setpoint";
  parameter Modelica.SIunits.PressureDifference pMaxSet(displayUnit="Pa") = 1.6/12*conv_ft_Pa
    "Maximum setpoint";
  parameter Modelica.SIunits.Time pDelTim = 600
   "Delay time after which trim and respond is activated";
  parameter Modelica.SIunits.Time samplePeriod = 120
    "Sample period to calculate static pressure system requests";
  parameter Integer pNumIgnReq = 2
    "Number of ignored requests";
  parameter Modelica.SIunits.PressureDifference pTriAmo(displayUnit="Pa") = -0.05/12*conv_ft_Pa
    "Trim amount";
  parameter Modelica.SIunits.PressureDifference pResAmo(displayUnit="Pa") = 0.06/12*conv_ft_Pa
    "Respond amount (must be opposite in to triAmo)";
  parameter Modelica.SIunits.PressureDifference pMaxRes(displayUnit="Pa") = 0.13/12*conv_ft_Pa
    "Maximum response per time interval (same sign as resAmo)";
  parameter Real yFanMax=1 "Maximum allowed fan speed";
  parameter Real yFanMin=0.1 "Lowest allowed fan speed if fan is on";
  parameter Real kFanSpe(final unit="1")=0.1
    "Gain of fan fan speed controller, normalized using pMaxSet";
  parameter Modelica.SIunits.Time TiFanSpe=60
    "Time constant of integrator block for fan speed";
  parameter Boolean have_perZonRehBox=true
    "Check if there is any VAV-reheat boxes on perimeter zones";
  parameter Boolean have_duaDucBox=false
    "Check if the AHU serves dual duct boxes";
  parameter Boolean have_airFloMeaSta=false
    "Check if the AHU has AFMS (Airflow measurement station)";
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uOpeMod
    "AHU operation mode status signal";
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uZonPreResReq
    "Zone static pressure reset requests";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput ducStaPre(
    final unit="Pa",
    displayUnit="Pa")
    "Measured duct static pressure";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VBox_flow[numZon](
    each final unit="m3/s",
    each quantity="VolumeFlowRate",
    min=0)
    "Primary airflow rate to the ventilation zone from the air handler, including outdoor air and recirculated air";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput ySupFanSpe(
    final min=0,
    final max=1,
    final unit="1") "Supply fan speed";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.SetPoints.VAVSupplyFan
    supFan(
    final numZon=numZon,
    final samplePeriod=samplePeriod,
    final have_perZonRehBox=have_perZonRehBox,
    final have_duaDucBox=have_duaDucBox,
    final have_airFloMeaSta=have_airFloMeaSta,
    final iniSet=pIniSet,
    final minSet=pMinSet,
    final maxSet=pMaxSet,
    final delTim=pDelTim,
    final numIgnReq=pNumIgnReq,
    final triAmo=pTriAmo,
    final resAmo=pResAmo,
    final maxRes=pMaxRes,
    final controllerType=controllerType,
    final k=kFanSpe,
    final Ti=TiFanSpe,
    final yFanMax=yFanMax,
    final yFanMin=yFanMin)
    "Supply fan controller";

  parameter Modelica.SIunits.Temperature TSupMin
    "Lowest cooling supply air temperature setpoint";
  parameter Modelica.SIunits.Temperature TSupMax
    "Highest cooling supply air temperature setpoint. It is typically 18 degC (65 degF) in mild and dry climates, 16 degC (60 degF) or lower in humid climates";
  parameter Modelica.SIunits.Temperature TSupDes
    "Nominal supply air temperature setpoint";
  parameter Modelica.SIunits.Temperature TOutMin
    "Lower value of the outdoor air temperature reset range. Typically value is 16 degC (60 degF)";
  parameter Modelica.SIunits.Temperature TOutMax
    "Higher value of the outdoor air temperature reset range. Typically value is 21 degC (70 degF)";

  parameter Modelica.SIunits.Temperature iniSetSupTem=supTemSetPoi.maxSet
    "Initial setpoint for supply temperature control";
  parameter Modelica.SIunits.Temperature maxSetSupTem=supTemSetPoi.TSupMax
    "Maximum setpoint for supply temperature control";
  parameter Modelica.SIunits.Temperature minSetSupTem=supTemSetPoi.TSupDes
    "Minimum setpoint for supply temperature control" ;
  parameter Modelica.SIunits.Time delTimSupTem=600
    "Delay timer for supply temperature control";
  parameter Integer numIgnReqSupTem=2
    "Number of ignorable requests for supply temperature control";
  parameter Modelica.SIunits.TemperatureDifference triAmoSupTem=0.1
    "Trim amount for supply temperature control";
  parameter Modelica.SIunits.TemperatureDifference resAmoSupTem=-0.2
    "Response amount for supply temperature control";
  parameter Modelica.SIunits.TemperatureDifference maxResSupTem=-0.6
    "Maximum response per time interval for supply temperature control";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaSet(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "Zone air temperature heating setpoint";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TCooSet(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "Zone air temperature cooling setpoint";
  Buildings.Controls.OBC.CDL.Continuous.Average TZonSetPoiAve
    "Average of all zone set points";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.SetPoints.VAVSupplyTemperature
    supTemSetPoi(
    final samplePeriod=samplePeriod,
    final TSupMin=TSupMin,
    final TSupMax=TSupMax,
    final TSupDes=TSupDes,
    final TOutMin=TOutMin,
    final TOutMax=TOutMax,
    final iniSet=iniSetSupTem,
    final maxSet=maxSetSupTem,
    final minSet=minSetSupTem,
    final delTim=delTimSupTem,
    final numIgnReq=numIgnReqSupTem,
    final triAmo=triAmoSupTem,
    final resAmo=resAmoSupTem,
    final maxRes=maxResSupTem) "Setpoint for supply temperature";

//  parameter Real kTSup(final unit="1/K")=0.05
//    "Gain of controller for supply air temperature signal";
//  parameter Modelica.SIunits.Time TiTSup=600
//    "Time constant of integrator block for supply temperature control signal";
//  parameter Real kTSup_isNotOcc(final unit="1/K")=0.05; // shiyab added 190327
//  parameter Modelica.SIunits.Time TiTSup_isNotOcc=600; // shiyab added 190327

  parameter Real uHeaMax(min=-0.9)=-0.25
    "Upper limit of controller signal when heating coil is off. Require -1 < uHeaMax < uCooMin < 1.";
  parameter Real uCooMin(max=0.9)=0.25
    "Lower limit of controller signal when cooling coil is off. Require -1 < uHeaMax < uCooMin < 1.";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yHea(
    final min=0,
    final max=1,
    final unit="1")
    "Control signal for heating";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yCoo(
    final min=0,
    final max=1,
    final unit="1") "Control signal for cooling";

//  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isNotOcc; // shiyab added 190324
//  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isOcc; // shiyab added 190324
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isCooDow; // shiyab added 190324
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isWarUp; // shiyab added 190324
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isSetBac; // shiyab added 190324
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isSetUp; // shiyab added 190324

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.SetPoints.VAVSupplySignals val(
    final controllerType=controllerType,
//    final kTSup=kTSup,
//    final TiTSup=TiTSup,
//    final kTSup_isNotOcc=kTSup_isNotOcc,
//    final TiTSup_isNotOcc=TiTSup_isNotOcc,
    final kTSup_ahuHea=kTSup_ahuHea,
    final TiTSup_ahuHea=TiTSup_ahuHea,
    final kTSup_ahuCoo=kTSup_ahuCoo,
    final TiTSup_ahuCoo=TiTSup_ahuCoo,
    final kTSup_ahuEco=kTSup_ahuEco,
    final TiTSup_ahuEco=TiTSup_ahuEco,
    final uHeaMax=uHeaMax,
    final uCooMin=uCooMin) "AHU coil valve control";


  parameter Modelica.SIunits.Area AFlo[numZon]
    "Floor area of each zone";
  parameter Modelica.SIunits.VolumeFlowRate maxSysPriFlo
    "Maximum expected system primary airflow at design stage";
  parameter Modelica.SIunits.VolumeFlowRate minZonPriFlo[numZon]
    "Minimum expected zone primary flow rate";
  parameter Boolean have_occSen=false
    "Set to true if zones have occupancy sensor";

  parameter Real outAirPerAre[numZon](each final unit = "m3/(s.m2)")=
     fill(0.06*conv_cfm_m3s/conv_ft_m^2, outAirSetPoi.numZon)
    "Outdoor air rate per unit area"; // shiyab removed
  parameter Modelica.SIunits.VolumeFlowRate outAirPerPer[numZon]=
    fill(5*conv_cfm_m3s, outAirSetPoi.numZon)
    "Outdoor air rate per person";
  parameter Real occDen[numZon](each final unit="1/m2")=
     {0.06744305,0.054623295}
    "Default number of person in unit area";
  parameter Real zonDisEffHea[numZon]=
     fill(0.8, outAirSetPoi.numZon)
    "Zone air distribution effectiveness during heating";
  parameter Real zonDisEffCoo[numZon]=
     fill(1.0, outAirSetPoi.numZon)
    "Zone air distribution effectiveness during cooling";
  parameter Real desZonDisEff[numZon]=fill(1.0, outAirSetPoi.numZon)
    "Design zone air distribution effectiveness";
  parameter Real desZonPop[numZon]={
    outAirSetPoi.occDen[i]*outAirSetPoi.AFlo[i]
    for i in 1:outAirSetPoi.numZon}
    "Design zone population during peak occupancy";
  parameter Real peaSysPop=1.2*sum(
    {outAirSetPoi.occDen[iZon]*outAirSetPoi.AFlo[iZon]
    for iZon in 1:outAirSetPoi.numZon})
    "Peak system population";
  parameter Boolean have_winSen=false
    "Set to true if zones have window status sensor";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput nOcc[numZon] if have_occSen
    "Number of occupants";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TZon[numZon](
    each final unit="K",
    each final quantity="ThermodynamicTemperature")
    "Measured zone air temperature";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDis[numZon](
    each final unit="K",
    each final quantity="ThermodynamicTemperature")
    "Discharge air temperature";
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uWin[numZon] if have_winSen
    "Window status, true if open, false if closed";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.SetPoints.OutsideAirFlow
    outAirSetPoi(
    final AFlo=AFlo,
    final maxSysPriFlo=maxSysPriFlo,
    final minZonPriFlo=minZonPriFlo,
    final numZon=numZon,
    final have_occSen=have_occSen,
    final outAirPerAre=outAirPerAre,
    final outAirPerPer=outAirPerPer,
    final occDen=occDen,
    final zonDisEffHea=zonDisEffHea,
    final zonDisEffCoo=zonDisEffCoo,
    final desZonDisEff=desZonDisEff,
    final desZonPop=desZonPop,
    final peaSysPop=peaSysPop,
    final have_winSen=have_winSen)
    "Controller for minimum outdoor airflow rate";

  parameter Boolean use_enthalpy=false
    "Set to true if enthalpy measurement is used in addition to temperature measurement";
  parameter Modelica.SIunits.TemperatureDifference delTOutHis=1
    "Delta between the temperature hysteresis high and low limit";
  parameter Modelica.SIunits.SpecificEnergy delEntHis=1000
    "Delta between the enthalpy hysteresis high and low limits";
  parameter Modelica.SIunits.Time retDamFulOpeTim=180
    "Time period to keep RA damper fully open before releasing it for minimum outdoor airflow control at disable to avoid pressure fluctuations";
  parameter Modelica.SIunits.Time disDel=15
    "Short time delay before closing the OA damper at disable to avoid pressure fluctuations";
  parameter Real kMinOut(final unit="1")=0.05
    "Gain of controller for minimum outdoor air";
  parameter Modelica.SIunits.Time TiMinOut=1200
    "Time constant of controller for minimum outdoor air intake";
  parameter Real retDamPhyPosMax(
    final min=0,
    final max=1,
    final unit="1") = 1
    "Physically fixed maximum position of the return air damper";
  parameter Real retDamPhyPosMin(
    final min=0,
    final max=1,
    final unit="1") = 0
    "Physically fixed minimum position of the return air damper";
  parameter Real outDamPhyPosMax(
    final min=0,
    final max=1,
    final unit="1") = 1
    "Physically fixed maximum position of the outdoor air damper";
  parameter Real outDamPhyPosMin(
    final min=0,
    final max=1,
    final unit="1") = 0
    "Physically fixed minimum position of the outdoor air damper";
  parameter Modelica.SIunits.Time delta=5
    "Time horizon over which the outdoor air flow measurment is averaged";
  parameter Boolean use_G36FrePro=false
    "Set to true to use G36 freeze protection";
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uFreProSta if
      use_G36FrePro
   "Freeze protection status, used if use_G36FrePro=true";
  Buildings.Controls.OBC.CDL.Continuous.Division VOut_flow_normalized(
    u1(final unit="m3/s"),
    u2(final unit="m3/s"),
    y(final unit="1"))
    "Normalization of outdoor air flow intake by design minimum outdoor air intake";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VOut_flow(
    final unit="m3/s",
    final quantity="VolumeFlowRate")
    "Measured outdoor volumetric airflow rate";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TOutCut(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "OA temperature high limit cutoff. For differential dry bulb temeprature condition use return air temperature measurement";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput hOut(
    final unit="J/kg",
    final quantity="SpecificEnergy") if use_enthalpy "Outdoor air enthalpy";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput hOutCut(
    final unit="J/kg",
    final quantity="SpecificEnergy") if use_enthalpy
    "OA enthalpy high limit cutoff. For differential enthalpy use return air enthalpy measurement";
  parameter Modelica.SIunits.Temperature TFreSet = 279.15
    "Lower limit for mixed air temperature for freeze protection, used if use_TMix=true";
  parameter Real kFre(final unit="1/K") = 0.1
    "Gain for mixed air temperature tracking for freeze protection, used if use_TMix=true";
  parameter Modelica.SIunits.Time TiFre(max=TiMinOut)=120
    "Time constant of controller for mixed air temperature tracking for freeze protection. Require TiFre < TiMinOut";
  parameter Boolean use_TMix=true
    "Set to true if mixed air temperature measurement is enabled";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMix(
    final unit="K",
    final quantity = "ThermodynamicTemperature") if use_TMix
    "Measured mixed air temperature, used for freeze protection if use_TMix=true";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yRetDamPos(
    final min=0,
    final max=1,
    final unit="1") "Return air damper position";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yOutDamPos(
    final min=0,
    final max=1,
    final unit="1") "Outdoor air damper position";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Economizers.Controller eco(
    final use_enthalpy=use_enthalpy,
    final delTOutHis=delTOutHis,
    final delEntHis=delEntHis,
    final retDamFulOpeTim=retDamFulOpeTim,
    final disDel=disDel,
    final controllerType=controllerType,
    final kMinOut=kMinOut,
    final TiMinOut=TiMinOut,
    final retDamPhyPosMax=retDamPhyPosMax,
    final retDamPhyPosMin=retDamPhyPosMin,
    final outDamPhyPosMax=outDamPhyPosMax,
    final outDamPhyPosMin=outDamPhyPosMin,
    final uHeaMax=uHeaMax,
    final uCooMin=uCooMin,
    final uOutDamMax=(uHeaMax + uCooMin)/2,
    final uRetDamMin=(uHeaMax + uCooMin)/2,
    final TFreSet=TFreSet,
    final controllerType=controllerType,
    final kFre=kFre,
    final TiFre=TiFre,
    final delta=delta,
    final use_TMix=use_TMix,
    final use_G36FrePro=use_G36FrePro) "Economizer controller";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uZonTemResReq
    "Zone cooling supply air temperature reset request";

equation
  connect(uOpeMod,supFan.uOpeMod);
  connect(uZonPreResReq,supFan.uZonPreResReq);
  connect(ducStaPre,supFan.ducStaPre);
  connect(VBox_flow,supFan.VBox_flow);
  connect(supFan.ySupFanSpe, ySupFanSpe);

  connect(THeaSet, TZonSetPoiAve.u1);
  connect(TCooSet,TZonSetPoiAve.u2);
  connect(TZonSetPoiAve.y,supTemSetPoi.TSetZones);
  connect(TOut,supTemSetPoi.TOut);
  connect(supFan.ySupFan,supTemSetPoi.uSupFan);
  connect(uOpeMod,supTemSetPoi.uOpeMod);

  connect(supTemSetPoi.TSetSup, val.TSetSup);
  connect(TSup, val.TSup);
  connect(supFan.ySupFan, val.uSupFan);
  connect(val.yHea, yHea);
  connect(val.yCoo, yCoo);

  connect(nOcc,outAirSetPoi.nOcc);
  connect(TZon,outAirSetPoi.TZon);
  connect(TDis,outAirSetPoi.TDis);
  connect(VBox_flow,outAirSetPoi.VBox_flow);
  connect(uWin,outAirSetPoi.uWin);
  connect(uOpeMod,outAirSetPoi.uOpeMod);
  connect(supFan.ySupFan, outAirSetPoi.uSupFan);

  connect(supFan.ySupFan,eco.uSupFan);
  connect(val.uTSup, eco.uTSup);
  connect(VOut_flow,VOut_flow_normalized.u1);
  connect(outAirSetPoi.VDesOutMin_flow_nominal, VOut_flow_normalized.u2);
  connect(VOut_flow_normalized.y,eco.VOut_flow_normalized);
  connect(outAirSetPoi.VOutMinSet_flow_normalized,eco.VOutMinSet_flow_normalized);
  connect(uOpeMod,eco.uOpeMod);
  connect(uFreProSta,eco.uFreProSta);
  connect(TOutCut,eco.TOutCut);
  connect(TOut, eco.TOut);
  connect(TMix,eco.TMix);
  connect(hOut,eco.hOut);
  connect(hOutCut,eco.hOutCut);
  connect(eco.yRetDamPos, yRetDamPos);
  connect(eco.yOutDamPos, yOutDamPos);

  connect(uZonTemResReq,supTemSetPoi.uZonTemResReq);

//  connect(isNotOcc,val.isNotOcc); // shiyab added 190327
//  connect(isOcc,val.isOcc); // shiyab added 190327
  connect(isCooDow,val.isCooDow); // shiyab added 190327
  connect(isWarUp,val.isWarUp); // shiyab added 190327
  connect(isSetBac,val.isSetBac); // shiyab added 190327
  connect(isSetUp,val.isSetUp); // shiyab added 190327

end Controller;
