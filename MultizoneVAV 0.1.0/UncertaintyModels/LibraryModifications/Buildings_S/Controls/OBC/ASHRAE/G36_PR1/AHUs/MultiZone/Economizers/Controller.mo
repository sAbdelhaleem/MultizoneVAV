within MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Economizers;
model Controller "Multi zone VAV AHU economizer control sequence" // _99_01_benchmark

  parameter Modelica.SIunits.Time delta=5
    "Time horizon over which the outdoor air flow measurment is averaged";
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller";
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
  parameter Real kMinOut(final unit="1")=0.05
    "Gain of controller for minimum outdoor air";
  parameter Modelica.SIunits.Time TiMinOut=1200
    "Time constant of controller for minimum outdoor air intake";
  parameter Real uHeaMax=-0.25
    "Lower limit of controller input when outdoor damper opens for modulation control. Require -1 < uHeaMax < uCooMin < 1.";
  parameter Real uCooMin=+0.25
    "Upper limit of controller input when return damper is closed for modulation control. Require -1 < uHeaMax < uCooMin < 1.";
  parameter Real uRetDamMin(
    final min=-1,
    final max=1,
    final unit="1") = (uHeaMax + uCooMin)/2
    "Minimum loop signal for the RA damper to be fully open. Require -1 < uHeaMax < uOutDamMax <= uRetDamMin < uCooMin < 1.";
  Buildings.Controls.OBC.CDL.Continuous.MovingMean movAve(final delta=delta)
    "Moving average of outdoor air flow measurement, normalized by design minimum outdoor airflow rate";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VOut_flow_normalized(
    final unit="1")
    "Measured outdoor volumetric airflow rate, normalized by design minimum outdoor airflow rate";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput VOutMinSet_flow_normalized(
    final unit="1")
    "Effective minimum outdoor airflow setpoint, normalized by design minimum outdoor airflow rate";
  parameter Boolean use_G36FrePro=false
    "Set to true to use G36 freeze protection";
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uFreProSta if use_G36FrePro
    "Freeze protection status";
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uOpeMod
    "AHU operation mode status signal";
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uSupFan
    "Supply fan status";
  Buildings.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Economizers.Subsequences.Limits
    damLim(
    final retDamPhyPosMax=retDamPhyPosMax,
    final retDamPhyPosMin=retDamPhyPosMin,
    final outDamPhyPosMax=outDamPhyPosMax,
    final outDamPhyPosMin=outDamPhyPosMin,
    final k=kMinOut,
    final Ti=TiMinOut,
    final uRetDamMin=uRetDamMin,
    final controllerType=controllerType)
    "Multi zone VAV AHU economizer minimum outdoor air requirement damper limit sequence";

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
  Buildings.Controls.OBC.CDL.Interfaces.RealInput hOut(
    final unit="J/kg",
    final quantity="SpecificEnergy") if use_enthalpy
    "Outdoor air enthalpy";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput hOutCut(
    final unit="J/kg",
    final quantity="SpecificEnergy") if use_enthalpy;
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant freProSta(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.FreezeProtectionStages.stage0) if not use_G36FrePro
    "Freeze protection status is 0. Use if G36 freeze protection is not implemented";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TOutCut(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "OA temperature high limit cutoff. For differential dry bulb temeprature condition use return air temperature measurement";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TOut(
    final unit="K",
    final quantity="ThermodynamicTemperature") "Outdoor air temperature";
  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Economizers.Subsequences.Enable enaDis( // shiyab added
    final use_enthalpy=use_enthalpy,
    final delTOutHis=delTOutHis,
    final delEntHis=delEntHis,
    final retDamFulOpeTim=retDamFulOpeTim,
    final disDel=disDel)
    "Multi zone VAV AHU economizer enable/disable sequence";

  parameter Real uOutDamMax(
    final min=-1,
    final max=1,
    final unit="1") = (uHeaMax + uCooMin)/2
    "Maximum loop signal for the OA damper to be fully open. Require -1 < uHeaMax < uOutDamMax <= uRetDamMin < uCooMin < 1.";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uTSup(final unit="1")
    "Signal for supply air temperature control (T Sup Control Loop Signal in diagram)";
  Buildings.Controls.OBC.CDL.Continuous.Min outDamMaxFre
    "Maximum control signal for outdoor air damper due to freeze protection";
  Buildings.Controls.OBC.CDL.Continuous.Max retDamMinFre
    "Minimum position for return air damper due to freeze protection";
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant noTMix(k=0) if not use_TMix
    "Ignore max evaluation if there is no mixed air temperature sensor";
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant noTMix1(k=1) if not use_TMix
    "Ignore min evaluation if there is no mixed air temperature sensor";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yOutDamPos(
    final min=0,
    final max=1,
    final unit="1") "Outdoor air damper position";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yRetDamPos(
    final min=0,
    final max=1,
    final unit="1") "Return air damper position";
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
    "Measured mixed air temperature, used for freeze protection";
  Buildings.Controls.OBC.ASHRAE.G36_PR1.Generic.FreezeProtectionMixedAir freProTMix(
    final controllerType=controllerType,
    final TFreSet = TFreSet,
    final k=kFre,
    final Ti=TiFre) if use_TMix
    "Block that tracks TMix against a freeze protection setpoint";
  Buildings.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Economizers.Subsequences.Modulation
    mod(
    final uRetDamMin=uRetDamMin,
    final uMin=uHeaMax,
    final uMax=uCooMin,
    final uOutDamMax=uOutDamMax)
    "Multi zone VAV AHU economizer damper modulation sequence";



equation
  connect(VOut_flow_normalized, movAve.u);
  connect(movAve.y, damLim.VOut_flow_normalized);
  connect(VOutMinSet_flow_normalized, damLim.VOutMinSet_flow_normalized);
  connect(uFreProSta, damLim.uFreProSta);
  connect(uSupFan, damLim.uSupFan);
  connect(uOpeMod, damLim.uOpeMod);
  connect(freProSta.y, damLim.uFreProSta);

  connect(damLim.yOutDamPosMax, enaDis.uOutDamPosMax);
  connect(damLim.yOutDamPosMin, enaDis.uOutDamPosMin);
  connect(damLim.yRetDamPosMin, enaDis.uRetDamPosMin);
  connect(damLim.yRetDamPhyPosMax, enaDis.uRetDamPhyPosMax);
  connect(damLim.yRetDamPosMax, enaDis.uRetDamPosMax);
  connect(uFreProSta, enaDis.uFreProSta);
  connect(hOutCut, enaDis.hOutCut);
  connect(hOut, enaDis.hOut);
  connect(uSupFan, enaDis.uSupFan);
  connect(TOutCut, enaDis.TOutCut);
  connect(TOut, enaDis.TOut);
  connect(freProSta.y, enaDis.uFreProSta);

  connect(enaDis.yOutDamPosMax, mod.uOutDamPosMax);
  connect(enaDis.yRetDamPosMax, mod.uRetDamPosMax);
  connect(damLim.yOutDamPosMin, mod.uOutDamPosMin);
  connect(enaDis.yRetDamPosMin, mod.uRetDamPosMin);
  connect(uTSup, mod.uTSup);

  connect(TMix, freProTMix.TMix);
  connect(mod.yOutDamPos, outDamMaxFre.u1);
  connect(noTMix1.y,outDamMaxFre.u2);
  connect(freProTMix.yFreProInv, outDamMaxFre.u2);
  connect(outDamMaxFre.y, yOutDamPos);
  connect(noTMix.y,retDamMinFre.u1);
  connect(freProTMix.yFrePro, retDamMinFre.u1);
  connect(mod.yRetDamPos, retDamMinFre.u2);
  connect(retDamMinFre.y, yRetDamPos);




end Controller;
