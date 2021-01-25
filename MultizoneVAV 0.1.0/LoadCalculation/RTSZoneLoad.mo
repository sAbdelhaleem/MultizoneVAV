within MultizoneVAV.LoadCalculation;
model RTSZoneLoad "Zone load calculated using Radiant Time Series Method" // _99_01_benchmark

  parameter Modelica.SIunits.Area ARoo
    "Room area [m2]";

  parameter Modelica.SIunits.Area AWinNE
    "North east window area [m2]";
  parameter Modelica.SIunits.Area AWinNW
    "North west window area [m2]";
  parameter Modelica.SIunits.Area AWinSE
    "South east window area [m2]";
  parameter Modelica.SIunits.Area AWinSW
    "South west window area [m2]";

  parameter Modelica.SIunits.HeatFlowRate senIHGPeo_flow=75
    "Sensible heat gains per person [W/per], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  parameter Modelica.SIunits.HeatFlowRate latIHGPeo_flow=55
    "Latent heat gains per person [W/per], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  parameter Modelica.SIunits.DensityOfHeatFlowRate IHGEqu_flow=7.79
    "Equipment load factor [W/m2], (ASHRAE Fundamentals Handbook 2017, Table 11 Ch18, 100% desktop medium)";
  parameter Modelica.SIunits.DensityOfHeatFlowRate IHGLit_flow
    "Lighting load factor [W/m2], (ASHRAE Fundamentals Handbook 2017, Table 2 Ch18, Office enclosed)";

  parameter Real radFraOcc=0.6 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Occupants typical office conditions";
  parameter Real conFraOcc=0.4 "convective factor, ASHRAE Fundamentals Ch18, table 14 Occupants typical office conditions";
  parameter Real radFraEqu=0.3 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Office without fan";
  parameter Real conFraEqu=0.7 "convective factor, ASHRAE Fundamentals Ch18, table 14 Office without fan";
  parameter Real radFraLit=0.6 "radiative factor, ASHRAE Fundamentals Ch18, table 3 fluorescent without lens, space fraction=1";
  parameter Real conFraLit=0.4 "convective factor, ASHRAE Fundamentals Ch18, table 3 Office without fan";
  parameter Real radFraWal=0.46 "radiative factor, ASHRAE Fundamentals Ch18, table 14 Through walls and floors, through windows (SHGC<0.5)";
  parameter Real conFraWal=0.54 "convective factor, ASHRAE Fundamentals Ch18, table 14 Through walls and floors, through windows (SHGC<0.5)";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput occSch_occupied
    "On/off signal for equipment and lighting heat gains";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput isOcc // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    "Output true if unoccupied";

  Modelica.Blocks.Sources.Constant One_s(final k=1) // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    "Constant one";
  Modelica.Blocks.Sources.Constant Zer_s(final k=0) // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    "Constant zero";

  Buildings.Controls.OBC.CDL.Logical.Switch swi_occ_temp // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
    "Switch that output one if operation mode is occupied and zero otherwise";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput nOcc
    "Number of occupants in zone, schedule that resembles the existance of an occupancy sensor";

  Buildings.Controls.OBC.CDL.Continuous.Gain norSolGaiNE(k=AWinNE)
    "Hourly solar heat gain [W/m^2] for north east window";
  Buildings.Controls.OBC.CDL.Continuous.Gain norSolGaiNW(k=AWinNW)
    "Hourly solar heat gain [W/m^2] for north west window";
  Buildings.Controls.OBC.CDL.Continuous.Gain norSolGaiSE(k=AWinSE)
    "Hourly solar heat gain [W/m^2] for south east window";
  Buildings.Controls.OBC.CDL.Continuous.Gain norSolGaiSW(k=AWinSW)
    "Hourly solar heat gain [W/m^2] for south west window";

  Modelica.Blocks.Math.Gain gai_radSenIHGPeo_flow(k=senIHGPeo_flow*radFraOcc)
    "Sensible heat gains per person [W], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  Modelica.Blocks.Math.Gain gai_radIHGEqu_flow(k=IHGEqu_flow*ARoo*radFraEqu)
    "Internal heat gain from equipment [W])";
  Modelica.Blocks.Math.Gain gai_radIHGLit_flow(k=IHGLit_flow*ARoo*radFraLit)
    "Internal heat gain from equipment [W])";

  Buildings.Controls.OBC.CDL.Continuous.MultiSum nonSolRadIHG(final nin=2)
    "Non-Solar radiative heat gain, people and equipment";
  Buildings.Controls.OBC.CDL.Continuous.MultiSum solRadIHG(nin=5)
    "Solar radiative heat gain, lighting and solar";

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

  MultizoneVAV.LoadCalculation.RadiantTimeSeries nonSolCooLoa(timFac=nonSolRTF)
    "Thermal storage effect using Radiant Time Series for non-solar heat gains";
  MultizoneVAV.LoadCalculation.RadiantTimeSeries solCooLoa(timFac=solRTF)
    "Thermal storage effect using Radiant Time Series for solar heat gains";
  MultizoneVAV.LoadCalculation.RadiantTimeSeries condCooLoa(timFac=CTF)
    "Thermal storage effect using Radiant Time Series for thermal conduction";

  parameter Real deltaMovAvg=1*60*60 // Could e removed but would result in step effect in trend plots, e.g. zone air temperature
    "Used to smooth step effect that results from Radiant Time Series calculation";

  Buildings.Controls.OBC.CDL.Continuous.MovingMean movAvg_condCooLoa(delta=deltaMovAvg) // Could e removed but would result in step effect in trend plots, e.g. zone air temperature
    "Used to smooth step effect that results from Radiant Time Series calculation";
  Buildings.Controls.OBC.CDL.Continuous.MovingMean movAvg_solCooLoa(delta=deltaMovAvg) // Could e removed but would result in step effect in trend plots, e.g. zone air temperature
    "Used to smooth step effect that results from Radiant Time Series calculation";
  Buildings.Controls.OBC.CDL.Continuous.MovingMean movAvg_nonSolCooLoa(delta=deltaMovAvg) // Could e removed but would result in step effect in trend plots, e.g. zone air temperature
    "Used to smooth step effect that results from Radiant Time Series calculation";

  Modelica.Blocks.Math.Gain gai_conSenIHGPeo_flow(k=senIHGPeo_flow*conFraOcc)
    "Sensible heat gains per person [W], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  Modelica.Blocks.Math.Gain gai_latIHGPeo_flow(k=latIHGPeo_flow)
    "Sensible heat gains per person [W], (ASHRAE Fundamentals Handbook 2017 Ch18, Table 1, Moderately active office work)";
  Modelica.Blocks.Math.Gain gai_conIHGEqu_flow(k=IHGEqu_flow*ARoo*conFraEqu)
    "Internal heat gain from equipment [W])";
  Modelica.Blocks.Math.Gain gai_conIHGLit_flow(k=IHGLit_flow*ARoo*conFraLit)
    "Internal heat gain from equipment [W])";

  Buildings.Controls.OBC.CDL.Continuous.MultiSum insIHG(final nin=4)
    "instantaneous heat gain";

  Buildings.Controls.OBC.CDL.Continuous.MultiSum IHG(final nin=3)
    "Internal heat gains including solar";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TRoo(
    final quantity="ThermodynamicTemperature",
    final unit = "K",
    displayUnit = "degC",
    min=0)
    "Measured room temperature";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TOut(
    final unit="K",
    final quantity="ThermodynamicTemperature")
    "Outdoor air temperature";

  Buildings.Controls.OBC.CDL.Continuous.Add add_deltaT(k2=-1)
    "Difference between zone air temperature and ambient temperature [K]";

  parameter Modelica.SIunits.ThermalConductance UA
    "Thermal conductance of zone envelope with the ambient air [W/K].
    Heat flow into zone is positive and out is negative";

  Modelica.Blocks.Math.Gain gaiCond(k=UA)
    "Thermal conductance of zone envelope with the ambient air [W].
    Heat flow into zone is positive and out is negative";

  Buildings.Controls.OBC.CDL.Continuous.Limiter lim_Qcond_inflow(uMin=0,uMax=Modelica.Constants.inf)
    "Positive heat flow into the zone as a result of thermal conduction through zone envelope";

  Buildings.Controls.OBC.CDL.Continuous.Limiter lim_Qcond_outflow(uMin=-Modelica.Constants.inf,uMax=0)
    "Negative heat flow out of zone as a result of thermal conduction through zone envelope";


  Modelica.Blocks.Math.Gain gai_radIHGWal_flow(k=radFraWal)
    "Heat transfer through zone envelope subject to Radiant Time Series";
  Modelica.Blocks.Math.Gain gai_conIHGWal_flow(k=conFraWal)
    "Instantanuous heat transfer through zone envelope";

  Buildings.Controls.OBC.CDL.Continuous.MultiSum cond(final nin=3)
    "Conduction heat transfer through zone envelope";

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow cond_Q_flow
    "Conduction heat transfer through zone envelope";

  Buildings.HeatTransfer.Sources.PrescribedHeatFlow IHG_Q_flow
    "Internal heat gains including solar";

equation

  connect(One_s.y,swi_occ_temp.u1); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(isOcc,swi_occ_temp.u2); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(Zer_s.y,swi_occ_temp.u3); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted

//  connect(swi_occ_temp.y,gai_radIHGEqu_flow.u); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
//  connect(swi_occ_temp.y,gai_radIHGLit_flow.u); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(occSch_occupied,gai_radIHGEqu_flow.u);
  connect(occSch_occupied,gai_radIHGLit_flow.u);

  connect(gai_radIHGLit_flow.y,solRadIHG.u[1]);
  connect(norSolGaiNE.y,solRadIHG.u[2]);
  connect(norSolGaiNW.y,solRadIHG.u[3]);
  connect(norSolGaiSE.y,solRadIHG.u[4]);
  connect(norSolGaiSW.y,solRadIHG.u[5]);

  connect(solRadIHG.y,solCooLoa.HeaGaiPro);
  connect(solCooLoa.cooLoaPro,movAvg_solCooLoa.u);
  connect(movAvg_solCooLoa.y,IHG.u[3]);

  connect(nOcc,gai_radSenIHGPeo_flow.u);
  connect(gai_radSenIHGPeo_flow.y,nonSolRadIHG.u[1]);
  connect(gai_radIHGEqu_flow.y,nonSolRadIHG.u[2]);

  connect(nonSolRadIHG.y,nonSolCooLoa.HeaGaiPro);
  connect(nonSolCooLoa.cooLoaPro,movAvg_nonSolCooLoa.u);
  connect(movAvg_nonSolCooLoa.y,IHG.u[2]);

  connect(nOcc,gai_conSenIHGPeo_flow.u);
  connect(nOcc,gai_latIHGPeo_flow.u);
//  connect(swi_occ_temp.y,gai_conIHGEqu_flow.u); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
//  connect(swi_occ_temp.y,gai_conIHGLit_flow.u); // Functionality replaced by occSch_occupied. Either this or occSch_occupied can be deleted
  connect(occSch_occupied,gai_conIHGEqu_flow.u);
  connect(occSch_occupied,gai_conIHGLit_flow.u);

  connect(gai_latIHGPeo_flow.y,insIHG.u[1]);
  connect(gai_conSenIHGPeo_flow.y,insIHG.u[2]);
  connect(gai_conIHGEqu_flow.y,insIHG.u[3]);
  connect(gai_conIHGLit_flow.y,insIHG.u[4]);
  connect(insIHG.y,IHG.u[1]);

  connect(TOut,add_deltaT.u1);
  connect(TRoo,add_deltaT.u2);
  connect(add_deltaT.y,gaiCond.u);

  connect(gaiCond.y,lim_Qcond_inflow.u);
  connect(gaiCond.y,lim_Qcond_outflow.u);
  connect(lim_Qcond_inflow.y,gai_radIHGWal_flow.u);
  connect(lim_Qcond_inflow.y,gai_conIHGWal_flow.u);
  connect(lim_Qcond_outflow.y,cond.u[2]);
  connect(gai_conIHGWal_flow.y,cond.u[3]);

  connect(gai_radIHGWal_flow.y,condCooLoa.HeaGaiPro);
  connect(condCooLoa.cooLoaPro,movAvg_condCooLoa.u);
  connect(movAvg_condCooLoa.y,cond.u[1]);

  connect(cond.y,cond_Q_flow.Q_flow);
  connect(IHG.y,IHG_Q_flow.Q_flow);

end RTSZoneLoad;
