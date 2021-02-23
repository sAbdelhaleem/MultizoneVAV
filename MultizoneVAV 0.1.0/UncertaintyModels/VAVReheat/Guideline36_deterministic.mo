within MultizoneVAV.UncertaintyModels.VAVReheat;
model Guideline36_deterministic // _99_07_benchmarkwoTMixNoise
  "Variable air volume flow system with terminal reheat and two thermal zones"
  extends MultizoneVAV.UncertaintyModels.VAVReheat.BaseClasses.PartialOpenLoop_deterministic;

  parameter Modelica.SIunits.Time samplePeriod=2*60
    "Sample period of component, set to the same value as the trim and respond that process yPreSetReq";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.Controller conVAV_406(
    vA_CooMax=vA_CooMaxAct_406,
    AFlo=flo.ARoo_406,
    vA_Min=vA_Min_406,
    vA_HeaMax=vA_HeaMax_406,
    have_CO2Sen=false,
    final samplePeriod=samplePeriod,
    have_occSen=false,
    THeaOn=THeaOn,
    DATMax=DATMax_406,
    kVal = 0.001*5,
    TiVal = 20*1/5,
    kDam=0.7,
    TiDam=20,
    kCoo=0.8,
    TiCoo=580,
    kHea=1,
    TiHea=500,
    TDisMin=TSupDes)
    "Controller for terminal unit 406";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.Controller conVAV_222(
    vA_CooMax=vA_CooMaxAct_222,
    AFlo=flo.ARoo_222,
    vA_Min=vA_Min_222,
    vA_HeaMax=vA_HeaMax_222,
    have_CO2Sen=false,
    final samplePeriod=samplePeriod,
    have_occSen=false,
    THeaOn=THeaOn,
    DATMax=DATMax_222,
    kVal = 0.001*5,
    TiVal = 20*1/5,
    kDam=0.7,
    TiDam=20,
    kCoo=0.8,
    TiCoo=580,
    kHea=1,
    TiHea=800,
    TDisMin=TSupDes)
    "Controller for terminal unit 222";

  parameter Modelica.SIunits.VolumeFlowRate minZonPriFlo[numZon]=
    {vA_CooMaxAct_406,vA_CooMaxAct_222}
    "Minimum expected zone primary flow rate";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.AHUs.MultiZone.Controller conAHU(
    numZon=numZon,
    maxSysPriFlo=vA_AHUAct,
    minZonPriFlo=minZonPriFlo,
    samplePeriod=samplePeriod,
    AFlo=AFlo,
    have_occSen=false,
    yFanMin=yFanMin,
    pMaxSet=pMaxSet,
    TOutMax=TOutMax,
    TOutMin=TOutMin,
    TSupMax=TSupMax,
    TSupMin=TSupMin,
    TSupDes=TSupDes,
    TFreSet=TFreSet,
    pMinSet=pMinSet,
    pIniSet=pIniSet,
    pTriAmo=pTriAmo,
    pResAmo=pResAmo,
    pDelTim=pDelTim,
    pNumIgnReq=pNumIgnReq,
    numIgnReqSupTem=numIgnReqSupTem,
    delTimSupTem=delTimSupTem,
    use_TMix=use_TMix,
    kMinOut=.011,
    TiMinOut=60,
//    TiMinOut=80,
    uHeaMax=uHeaMax,
    uCooMin=uCooMin,
//    kTSup=0.035,
//    TiTSup=450,
//    kTSup_isNotOcc=0.035,
//    TiTSup_isNotOcc=450,
    kTSup_ahuHea=0.045,
    TiTSup_ahuHea=450,
    kTSup_ahuCoo=0.04,
    TiTSup_ahuCoo=350,
    kTSup_ahuEco=0.025,
    TiTSup_ahuEco=450,
//    kFanSpe=0.6,
    kFanSpe=0.35,
//    TiFanSpe=11)
    TiFanSpe=60)
    "AHU controller";

  MultizoneVAV.UncertaintyModels.LibraryModifications.Buildings_S.Controls.OBC.ASHRAE.G36_PR1.TerminalUnits.ModeAndSetPoints TSetZon(
    numZon=numZon,
    THeaOn=THeaOn,
    TCooOn=TCooOn,
    THeaOff=THeaOff,
    TCooOff=TCooOff,
    // Adjustment to use MBL OperationMode model or MultizoneVAV OperationMode model. The latter is an excerpt of MBL OperationMode model
    freProThrVal=freProThrVal,
    freProEndVal=freProEndVal)
    "Zone temperature set points";

  Buildings.Controls.OBC.CDL.Integers.MultiSum PZonResReq(nin=numZon)
    "Number of zone pressure requests";

  // Adjustment to turn off freeze protection control of HW valve based on MAT if fan is off to prevent chattering.
  // Explanation: If AHU HW coil opens 100% MAT will rise above set-point,
  // freeze protection will turn off, a short while after MAT will fall again under set-point,
  // and freeze protection will turn on again causing chattering. Future work: This should be prevented from within freeze protection operation mode
  Buildings.Controls.OBC.CDL.Logical.And and_freSta
    "Freeze stat engaged only when fan is proven on and MAT is below set-point";

  Buildings.Controls.OBC.CDL.Logical.Switch swiFreSta
    "Switch for freeze stat";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntOcc(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.occupied)
    "Constant signal for occupied mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isOcc
    "Output true if operation mode is occupied";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntUn(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.unoccupied)
    "Constant signal for unoccupied mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isUnOcc
    "Output true if unoccupied";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntCooDow(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.coolDown)
    "Constant signal for coolDown mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isCooDow
    "Output true if coolDown";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntWarUp(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.warmUp)
    "Constant signal for warmUp mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isWarUp
    "Output true if warmUp";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntSetBac(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.setBack)
    "Constant signal for setBack mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isSetBac
    "Output true if setBack";

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conIntSetUp(
    final k=Buildings.Controls.OBC.ASHRAE.G36_PR1.Types.OperationModes.setUp)
    "Constant signal for setUp mode";
  Buildings.Controls.OBC.CDL.Integers.Equal isSetUp
    "Output true if setUp";

  Buildings.Controls.OBC.CDL.Logical.Not isNotOcc
    "Output true if in any operation mode but occupied";

  Buildings.Controls.OBC.CDL.Integers.MultiSum TZonResReq(nin=numZon)
    "Number of zone temperature requests";

/*
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_damOut
    "Outdoor air damper closed if in any operation mode but occupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_damRet
    "Return air damper open if in any operation mode but occupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_ahuCoo
    "AHU cooling coil closed if operation mode is unoccupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_ahuHea
    "AHU heating coil closed if operation mode is unoccupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_fanSup
    "AHU fan is set at a small number above zero if operation mode is unoccupied to prevent simulation failure, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_val406
    "Terminal unit 406 HW valve closed if operation mode is unoccupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_val222
    "Terminal unit 222 HW valve closed if operation mode is unoccupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_dam406
    "Terminal unit 406 damper closed if operation mode is unoccupied, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiMod_dam222
    "Terminal unit 222 damper closed if operation mode is unoccupied, else signal with noise is used";

  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_damOut
    "Outdoor air damper signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_damRet
    "Return air damper signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_ahuCoo
    "AHU cooling coil signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_ahuHea
    "AHU heating coil signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_fanSup
    "AHU fan signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_val406
    "Terminal unit 406 HW valve signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_val222
    "Terminal unit 222 HW valve signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_dam406
    "Terminal unit 406 damper signal without noise if signal equal zero or one, else signal with noise is used";
  Buildings.Controls.OBC.CDL.Logical.Switch swi_noNoiPos_dam222
    "Terminal unit 222 damper signal without noise if signal equal zero or one, else signal with noise is used";

  parameter Real uHighOne=0.99;
  parameter Real uLowOne=0.95;
  parameter Real uHighZer=0.05;
  parameter Real uLowZer=0.01;

  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_damOut(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Outdoor air damper signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_damRet(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Return air damper signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_ahuCoo(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if AHU cooling coil signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_ahuHea(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if AHU heating coil signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_fanSup(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if AHU fan signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_val406(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Terminal unit 406 HW valve signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_val222(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Terminal unit 222 HW valve signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_dam406(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Terminal unit 406 damper signal equal one";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isOne_dam222(
    uHigh=uHighOne,
    uLow=uLowOne)
    "Check if Terminal unit 222 damper signal equal one";

  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_damOut(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Outdoor air damper signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_damRet(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Return air damper signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_ahuCoo(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if AHU cooling coil signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_ahuHea(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if AHU heating coil signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_fanSup(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if AHU fan signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_val406(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Terminal unit 406 HW valve signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_val222(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Terminal unit 222 HW valve signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_dam406(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Terminal unit 406 damper signal is greater than zero";
  Buildings.Controls.OBC.CDL.Continuous.Hysteresis isNotZer_dam222(
    uHigh=uHighZer,
    uLow=uLowZer)
    "Check if Terminal unit 222 damper signal is greater than zero";

  Buildings.Controls.OBC.CDL.Logical.Not isZer_damOut
    "True if hysteresis of Outdoor air damper signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_damRet
    "True if hysteresis of Return air damper signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_ahuCoo
    "True if hysteresis of AHU cooling coil signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_ahuHea
    "True if hysteresis of AHU heating coil signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_val406
    "True if hysteresis of AHU fan signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_val222
    "True if hysteresis of Terminal unit 406 HW valve signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_fanSup
    "True if hysteresis of Terminal unit 222 HW valve signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_dam406
    "True if hysteresis of Terminal unit 406 damper signal equals zero";
  Buildings.Controls.OBC.CDL.Logical.Not isZer_dam222
    "True if hysteresis of Terminal unit 222 damper signal equals zero";

  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_damOut
    "True if hysteresis of Outdoor air damper signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_damRet
    "True if hysteresis of Return air damper signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_ahuCoo
    "True if hysteresis of AHU cooling coil signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_ahuHea
    "True if hysteresis of AHU heating coil signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_fanSup
    "True if hysteresis of AHU fan signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_val406
    "True if hysteresis of Terminal unit 406 HW valve signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_val222
    "True if hysteresis of Terminal unit 222 HW valve signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_dam406
    "True if hysteresis of Terminal unit 406 damper signal equals zero or one. Used to prevent adding noise to signal";
  Buildings.Controls.OBC.CDL.Logical.Or or_isZerIsOne_dam222
    "True if hysteresis of Terminal unit 222 damper signal equals zero or one. Used to prevent adding noise to signal";

  inner Modelica.Blocks.Noise.GlobalSeed globalSeed(enableNoise=true)
    "Definition of global seed via inner/outer"; // Noise Source
*/
equation
/*
  // Switch to prevent adding noise to signal when it equals zero or one
  connect(conAHU.yOutDamPos,isOne_damOut.u);
  connect(conAHU.yOutDamPos,isNotZer_damOut.u);
  connect(isNotZer_damOut.y,isZer_damOut.u);
  connect(isOne_damOut.y,or_isZerIsOne_damOut.u1);
  connect(isZer_damOut.y,or_isZerIsOne_damOut.u2);

  connect(conAHU.yRetDamPos,isOne_damRet.u);
  connect(conAHU.yRetDamPos,isNotZer_damRet.u);
  connect(isNotZer_damRet.y,isZer_damRet.u);
  connect(isOne_damRet.y,or_isZerIsOne_damRet.u1);
  connect(isZer_damRet.y,or_isZerIsOne_damRet.u2);

  connect(conAHU.yCoo,isOne_ahuCoo.u);
  connect(conAHU.yCoo,isNotZer_ahuCoo.u);
  connect(isNotZer_ahuCoo.y,isZer_ahuCoo.u);
  connect(isOne_ahuCoo.y,or_isZerIsOne_ahuCoo.u1);
  connect(isZer_ahuCoo.y,or_isZerIsOne_ahuCoo.u2);

  connect(conAHU.yHea,isOne_ahuHea.u);
  connect(conAHU.yHea,isNotZer_ahuHea.u);
  connect(isNotZer_ahuHea.y,isZer_ahuHea.u);
  connect(isOne_ahuHea.y,or_isZerIsOne_ahuHea.u1);
  connect(isZer_ahuHea.y,or_isZerIsOne_ahuHea.u2);

  connect(conAHU.ySupFanSpe,isOne_fanSup.u);
  connect(conAHU.ySupFanSpe,isNotZer_fanSup.u);
  connect(isNotZer_fanSup.y,isZer_fanSup.u);
  connect(isOne_fanSup.y,or_isZerIsOne_fanSup.u1);
  connect(isZer_fanSup.y,or_isZerIsOne_fanSup.u2);

  connect(conVAV_406.yVal,isOne_val406.u);
  connect(conVAV_406.yVal,isNotZer_val406.u);
  connect(isNotZer_val406.y,isZer_val406.u);
  connect(isOne_val406.y,or_isZerIsOne_val406.u1);
  connect(isZer_val406.y,or_isZerIsOne_val406.u2);

  connect(conVAV_222.yVal,isOne_val222.u);
  connect(conVAV_222.yVal,isNotZer_val222.u);
  connect(isNotZer_val222.y,isZer_val222.u);
  connect(isOne_val222.y,or_isZerIsOne_val222.u1);
  connect(isZer_val222.y,or_isZerIsOne_val222.u2);

  connect(conVAV_406.yDam,isOne_dam406.u);
  connect(conVAV_406.yDam,isNotZer_dam406.u);
  connect(isNotZer_dam406.y,isZer_dam406.u);
  connect(isOne_dam406.y,or_isZerIsOne_dam406.u1);
  connect(isZer_dam406.y,or_isZerIsOne_dam406.u2);

  connect(conVAV_222.yDam,isOne_dam222.u);
  connect(conVAV_222.yDam,isNotZer_dam222.u);
  connect(isNotZer_dam222.y,isZer_dam222.u);
  connect(isOne_dam222.y,or_isZerIsOne_dam222.u1);
  connect(isZer_dam222.y,or_isZerIsOne_dam222.u2);
*/

/*
  // Outdoor air damper
  connect(normalNoise_eco_yOut.y, addNoise_eco_yOut.u1); // Noise Source
  connect(conAHU.yOutDamPos, addNoise_eco_yOut.u2); // Noise Source
  connect(addNoise_eco_yOut.y, addNoise_eco_yOut_Lmt.u); // Noise Source

  connect(conAHU.yOutDamPos,swi_noNoiPos_damOut.u1);
  connect(or_isZerIsOne_damOut.y,swi_noNoiPos_damOut.u2);
  connect(addNoise_eco_yOut_Lmt.y,swi_noNoiPos_damOut.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_damOut.u1);
  connect(isNotOcc.y,swi_noNoiMod_damOut.u2);
  connect(swi_noNoiPos_damOut.y,swi_noNoiMod_damOut.u3);

  connect(swi_noNoiMod_damOut.y,eco.yOut); // Override
//  connect(ovrRid_ecoOut.y,eco.yOut); // Override
*/
  connect(conAHU.yOutDamPos,eco.yOut); // No Noise
/*
  // Return air damper
  connect(normalNoise_eco_yRet.y, addNoise_eco_yRet.u1); // Noise Source
  connect(conAHU.yRetDamPos, addNoise_eco_yRet.u2); // Noise Source
  connect(addNoise_eco_yRet.y, addNoise_eco_yRet_Lmt.u); // Noise Source

  connect(conAHU.yRetDamPos,swi_noNoiPos_damRet.u1);
  connect(or_isZerIsOne_damRet.y,swi_noNoiPos_damRet.u2);
  connect(addNoise_eco_yRet_Lmt.y,swi_noNoiPos_damRet.u3); // Noise Source

  connect(One_s.y,swi_noNoiMod_damRet.u1);
  connect(isNotOcc.y,swi_noNoiMod_damRet.u2);
  connect(swi_noNoiPos_damRet.y,swi_noNoiMod_damRet.u3);

  connect(swi_noNoiMod_damRet.y,eco.yRet); // Override
//  connect(ovrRid_ecoRet.y,eco.yRet); // Override
*/
  connect(conAHU.yRetDamPos,eco.yRet); // No Noise

  // Exhaust air damper
  connect(swi_occ_temp.y,eco.yExh); // Override
//  connect(ovrRid_ecoExh.y,eco.yExh); // Override

/*
  // AHU cooling coil
  connect(normalNoise_gaiCooCoi_u.y, addNoise_gaiCooCoi_u.u1); // Noise Source
  connect(conAHU.yCoo, addNoise_gaiCooCoi_u.u2); // Noise Source
  connect(addNoise_gaiCooCoi_u.y, addNoise_gaiCooCoi_u_Lmt.u); // Noise Source

  connect(conAHU.yCoo,swi_noNoiPos_ahuCoo.u1);
  connect(or_isZerIsOne_ahuCoo.y,swi_noNoiPos_ahuCoo.u2);
  connect(addNoise_gaiCooCoi_u_Lmt.y,swi_noNoiPos_ahuCoo.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_ahuCoo.u1);
  connect(isUnOcc.y,swi_noNoiMod_ahuCoo.u2);
  connect(swi_noNoiPos_ahuCoo.y,swi_noNoiMod_ahuCoo.u3);

  connect(swi_noNoiMod_ahuCoo.y, gaiWatFlo_ahuCoo.u); // Override
//  connect(ovrRid_ahuCoo.y, gaiWatFlo_ahuCoo.u); // Override
*/
  connect(conAHU.yCoo, gaiWatFlo_ahuCoo.u); // Override

  // AHU heating coil
  connect(freSta.y, and_freSta.u1);
  connect(conAHU.supFan.ySupFan,and_freSta.u2);
  connect(gaiWatFlo_ahuHea_freStaEng.y, swiFreSta.u1);
  connect(and_freSta.y,swiFreSta.u2);

/*
  connect(normalNoise_swiFreSta_u3.y, addNoise_swiFreSta_u3.u1); // Noise Source
  connect(conAHU.yHea, addNoise_swiFreSta_u3.u2); // Noise Source
  connect(addNoise_swiFreSta_u3.y, addNoise_swiFreSta_u3_Lmt.u); // Noise Source

  connect(conAHU.yHea,swi_noNoiPos_ahuHea.u1);
  connect(or_isZerIsOne_ahuHea.y,swi_noNoiPos_ahuHea.u2);
  connect(addNoise_swiFreSta_u3_Lmt.y,swi_noNoiPos_ahuHea.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_ahuHea.u1);
  connect(isUnOcc.y,swi_noNoiMod_ahuHea.u2);
  connect(swi_noNoiPos_ahuHea.y,swi_noNoiMod_ahuHea.u3);

  connect(swi_noNoiMod_ahuHea.y, swiFreSta.u3);
*/
  connect(conAHU.yHea, swiFreSta.u3);

  connect(swiFreSta.y,gaiWatFlo_ahuHea.u); // Override
//  connect(ovrRid_ahuHea.y,gaiWatFlo_ahuHea.u); // Override

/*
  // AHU supply fan
  connect(normalNoise_fanSup_y.y, addNoise_fanSup_y.u1); // Noise Source
  connect(conAHU.ySupFanSpe, addNoise_fanSup_y.u2); // Noise Source
  connect(addNoise_fanSup_y.y, addNoise_fanSup_y_Lmt.u); // Noise Source

  connect(conAHU.ySupFanSpe,swi_noNoiPos_fanSup.u1);
  connect(or_isZerIsOne_fanSup.y,swi_noNoiPos_fanSup.u2);
  connect(addNoise_fanSup_y_Lmt.y,swi_noNoiPos_fanSup.u3); // Noise Source

  connect(fanSpe_isUnOcc.y,swi_noNoiMod_fanSup.u1);
  connect(isUnOcc.y,swi_noNoiMod_fanSup.u2);
  connect(swi_noNoiPos_fanSup.y,swi_noNoiMod_fanSup.u3);

  connect(swi_noNoiMod_fanSup.y, fanSup.y); // Override
//  connect(ovrRid_fanSpe.y,fanSup.y); // Override
*/
  connect(conAHU.ySupFanSpe, fanSup.y); // Override

/*
  // Terminal unit 406 HW valve
  connect(normalNoise_406_yVal.y, addNoise_406_yVal.u1); // Noise Source
  connect(conVAV_406.yVal, addNoise_406_yVal.u2); // Noise Source
  connect(addNoise_406_yVal.y, addNoise_406_yVal_Lmt.u); // Noise Source

  connect(conVAV_406.yVal,swi_noNoiPos_val406.u1);
  connect(or_isZerIsOne_val406.y,swi_noNoiPos_val406.u2);
  connect(addNoise_406_yVal_Lmt.y,swi_noNoiPos_val406.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_val406.u1);
  connect(isUnOcc.y,swi_noNoiMod_val406.u2);
  connect(swi_noNoiPos_val406.y,swi_noNoiMod_val406.u3);

  connect(swi_noNoiMod_val406.y, terUni_406.yVal); // Override
//  connect(ovrRid_yVal_406.y, terUni_406.yVal); // Override
*/

  connect(conVAV_406.yVal, terUni_406.yVal); // Override
/*
  // Terminal unit 222 HW valve
  connect(normalNoise_222_yVal.y, addNoise_222_yVal.u1); // Noise Source
  connect(conVAV_222.yVal, addNoise_222_yVal.u2); // Noise Source
  connect(addNoise_222_yVal.y, addNoise_222_yVal_Lmt.u); // Noise Source

  connect(conVAV_222.yVal,swi_noNoiPos_val222.u1);
  connect(or_isZerIsOne_val222.y,swi_noNoiPos_val222.u2);
  connect(addNoise_222_yVal_Lmt.y,swi_noNoiPos_val222.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_val222.u1);
  connect(isUnOcc.y,swi_noNoiMod_val222.u2);
  connect(swi_noNoiPos_val222.y,swi_noNoiMod_val222.u3);

  connect(swi_noNoiMod_val222.y, terUni_222.yVal); // Override
//  connect(ovrRid_yVal_222.y, terUni_222.yVal); // Override
*/

  connect(conVAV_222.yVal, terUni_222.yVal); // Override

/*
  // Terminal unit 406 damper
  connect(normalNoise_406_yDam.y, addNoise_406_yDam.u1); // Noise Source
  connect(conVAV_406.yDam, addNoise_406_yDam.u2); // Noise Source
  connect(addNoise_406_yDam.y, addNoise_406_yDam_Lmt.u); // Noise Source

  connect(conVAV_406.yDam,swi_noNoiPos_dam406.u1);
  connect(or_isZerIsOne_dam406.y,swi_noNoiPos_dam406.u2);
  connect(addNoise_406_yDam_Lmt.y,swi_noNoiPos_dam406.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_dam406.u1);
  connect(isUnOcc.y,swi_noNoiMod_dam406.u2);
  connect(swi_noNoiPos_dam406.y,swi_noNoiMod_dam406.u3);

  connect(swi_noNoiMod_dam406.y, terUni_406.yVAV); // Override
//  connect(ovrRid_yVAV_406.y, terUni_406.yVAV); // Override
*/

  connect(conVAV_406.yDam, terUni_406.yVAV); // Override

/*
  // Terminal unit 222 damper
  connect(normalNoise_222_yDam.y, addNoise_222_yDam.u1); // Noise Source
  connect(conVAV_222.yDam, addNoise_222_yDam.u2); // Noise Source
  connect(addNoise_222_yDam.y, addNoise_222_yDam_Lmt.u); // Noise Source

  connect(conVAV_222.yDam,swi_noNoiPos_dam222.u1);
  connect(or_isZerIsOne_dam222.y,swi_noNoiPos_dam222.u2);
  connect(addNoise_222_yDam_Lmt.y,swi_noNoiPos_dam222.u3); // Noise Source

  connect(Zer_s.y,swi_noNoiMod_dam222.u1);
  connect(isUnOcc.y,swi_noNoiMod_dam222.u2);
  connect(swi_noNoiPos_dam222.y,swi_noNoiMod_dam222.u3);

  connect(swi_noNoiMod_dam222.y, terUni_222.yVAV); // Override
//  connect(ovrRid_yVAV_222.y, terUni_222.yVAV); // Override
*/

  connect(conVAV_222.yDam, terUni_222.yVAV); // Override

  // Operation modes
  connect(occSch.occupied,TSetZon.uOcc);
  connect(occSch.tNexOcc, TSetZon.tNexOcc);
  // Adjustment to use MBL OperationMode model or MultizoneVAV OperationMode model. The latter is an excerpt of MBL OperationMode model
  connect(flo.TRooAir,TSetZon.TZon);

  connect(conIntOcc.y, isOcc.u1);
  connect(TSetZon.yOpeMod, isOcc.u2);
  connect(isOcc.y, isNotOcc.u);

  connect(conIntUn.y, isUnOcc.u1);
  connect(TSetZon.yOpeMod, isUnOcc.u2);

  connect(conIntCooDow.y, isCooDow.u1);
  connect(TSetZon.yOpeMod, isCooDow.u2);

  connect(conIntWarUp.y, isWarUp.u1);
  connect(TSetZon.yOpeMod, isWarUp.u2);

  connect(conIntSetBac.y, isSetBac.u1);
  connect(TSetZon.yOpeMod, isSetBac.u2);

  connect(conIntSetUp.y, isSetUp.u1);
  connect(TSetZon.yOpeMod, isSetUp.u2);

  connect(TSetZon.yOpeMod,flo.uOpeMod);

  // Terminal unit controllers
  connect(TSetZon.yOpeMod,conVAV_406.uOpeMod);
  connect(TSetZon.yOpeMod,conVAV_222.uOpeMod);
  connect(flo.TRooAir[1],conVAV_406.TRoo);
  connect(flo.TRooAir[2],conVAV_222.TRoo);
  connect(TSetZon.THeaSet[1],conVAV_406.TRooHeaSet);
  connect(TSetZon.THeaSet[2],conVAV_222.TRooHeaSet);
  connect(TSetZon.TCooSet[1],conVAV_406.TRooCooSet);
  connect(TSetZon.TCooSet[2],conVAV_222.TRooCooSet);

  connect(flo.nOcc[1],conVAV_406.nOcc);
  connect(flo.nOcc[2],conVAV_222.nOcc);
  connect(flo.volFraCO2[1].V,conVAV_406.ppmCO2);
  connect(flo.volFraCO2[2].V,conVAV_222.ppmCO2);

  connect(vA_zon[1],conVAV_406.VDis);
  connect(vA_zon[2],conVAV_222.VDis);
  connect(DAT[1],conVAV_406.TDis);
  connect(DAT[2],conVAV_222.TDis);
  connect(senSAT.T,conVAV_406.TSupAHU);
  connect(senSAT.T,conVAV_222.TSupAHU); // Noise Source
/*
  connect(normalNoise_senSAT.y, addNoise_senSAT.u1); // Noise Source
  connect(senSAT.T, addNoise_senSAT.u2); // Noise Source
  connect(addNoise_senSAT.y, conVAV_406.TSupAHU); // Noise Source
  connect(addNoise_senSAT.y, conVAV_222.TSupAHU); // Noise Source
*/
  connect(occSch.tNexNonOcc,conVAV_406.tNexNonOcc);
  connect(occSch.tNexNonOcc,conVAV_222.tNexNonOcc);

  connect(conVAV_406.yZonPreResReq, PZonResReq.u[1]);
  connect(conVAV_222.yZonPreResReq, PZonResReq.u[2]);

  connect(conVAV_406.yZonTemResReq, TZonResReq.u[1]);
  connect(conVAV_222.yZonTemResReq, TZonResReq.u[2]);

  // AHU controller
  connect(flo.nOcc,conAHU.nOcc);

  connect(flo.TRooAir,conAHU.TZon);
  connect(DAT,conAHU.TDis);
  connect(vA_zon,conAHU.VBox_flow);
  connect(TSetZon.yOpeMod,conAHU.uOpeMod);
  connect(senVolFloOut.V_flow,conAHU.VOut_flow); // Noise Source
/*
  connect(normalNoise_senVolFloOut.y, addNoise_senVolFloOut.u1); // Noise Source
  connect(senVolFloOut.V_flow, addNoise_senVolFloOut.u2); // Noise Source
  connect(addNoise_senVolFloOut.y, conAHU.VOut_flow); // Noise Source
*/

  connect(dpDisSupFan.p_rel,conAHU.ducStaPre); // Noise Source
/*
  connect(normalNoise_dpDisSupFan.y, addNoise_dpDisSupFan.u1); // Noise Source
  connect(dpDisSupFan.p_rel, addNoise_dpDisSupFan.u2); // Noise Source
  connect(addNoise_dpDisSupFan.y, conAHU.ducStaPre); // Noise Source
*/

  connect(PZonResReq.y,conAHU.uZonPreResReq);
  connect(senRAT.T,conAHU.TOutCut);
  connect(weaBus.TDryBul,conAHU.TOut); // Noise Source
/*
  connect(normalNoise_TOut.y, addNoise_TOut.u1); // Noise Source
  connect(weaBus.TDryBul, addNoise_TOut.u2); // Noise Source
  connect(addNoise_TOut.y, conAHU.TOut); // Noise Source
*/

//  connect(ecoLockOut_s.y,conAHU.TOut); // Economizer lockout override

  connect(senSAT.T,conAHU.TSup); // Noise Source
/*  connect(addNoise_senSAT.y, conAHU.TSup); // Noise Source */

  connect(TSetZon.THeaSet[1],conAHU.THeaSet);
  connect(TSetZon.TCooSet[1],conAHU.TCooSet);
  connect(TMix.T,conAHU.TMix); // Noise Source
//  connect(addNoise_TMix.y, conAHU.TMix); // Noise Source

  connect(TZonResReq.y,conAHU.uZonTemResReq);

//  connect(isNotOcc.y,conAHU.isNotOcc);
//  connect(isOcc.y,conAHU.isOcc);
  connect(isCooDow.y,conAHU.isCooDow);
  connect(isWarUp.y,conAHU.isWarUp);
  connect(isSetBac.y,conAHU.isSetBac);
  connect(isSetUp.y,conAHU.isSetUp);

end Guideline36_deterministic;
