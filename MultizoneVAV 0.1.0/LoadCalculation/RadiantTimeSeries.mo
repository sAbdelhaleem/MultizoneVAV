within MultizoneVAV.LoadCalculation;
model RadiantTimeSeries "Radiant Time Series Method to calculate zone thermal storage effect" // _99_01_benchmark

  parameter Real timFac[24];

  parameter Modelica.SIunits.Time timeStep=1*60*60;

  Buildings.Controls.OBC.CDL.Interfaces.RealInput HeaGaiPro
    "Heat gain profile (24 hours)";

  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr1_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr2_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr3_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr4_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr5_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr6_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr7_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr8_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr9_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr10_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr11_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr12_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr13_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr14_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr15_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr16_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr17_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr18_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr19_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr20_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr21_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr22_befCurHr(samplePeriod=timeStep);
  Buildings.Controls.OBC.CDL.Discrete.UnitDelay Hr23_befCurHr(samplePeriod=timeStep);

  Buildings.Controls.OBC.CDL.Continuous.MultiSum sumCooLoaPro(k=timFac, nin=24);

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput cooLoaPro
    "Radiative cooling load profile (24 hours)";

equation

  connect(HeaGaiPro,Hr1_befCurHr.u);
  connect(Hr1_befCurHr.y,Hr2_befCurHr.u);
  connect(Hr2_befCurHr.y,Hr3_befCurHr.u);
  connect(Hr3_befCurHr.y,Hr4_befCurHr.u);
  connect(Hr4_befCurHr.y,Hr5_befCurHr.u);
  connect(Hr5_befCurHr.y,Hr6_befCurHr.u);
  connect(Hr6_befCurHr.y,Hr7_befCurHr.u);
  connect(Hr7_befCurHr.y,Hr8_befCurHr.u);
  connect(Hr8_befCurHr.y,Hr9_befCurHr.u);
  connect(Hr9_befCurHr.y,Hr10_befCurHr.u);
  connect(Hr10_befCurHr.y,Hr11_befCurHr.u);
  connect(Hr11_befCurHr.y,Hr12_befCurHr.u);
  connect(Hr12_befCurHr.y,Hr13_befCurHr.u);
  connect(Hr13_befCurHr.y,Hr14_befCurHr.u);
  connect(Hr14_befCurHr.y,Hr15_befCurHr.u);
  connect(Hr15_befCurHr.y,Hr16_befCurHr.u);
  connect(Hr16_befCurHr.y,Hr17_befCurHr.u);
  connect(Hr17_befCurHr.y,Hr18_befCurHr.u);
  connect(Hr18_befCurHr.y,Hr19_befCurHr.u);
  connect(Hr19_befCurHr.y,Hr20_befCurHr.u);
  connect(Hr20_befCurHr.y,Hr21_befCurHr.u);
  connect(Hr21_befCurHr.y,Hr22_befCurHr.u);
  connect(Hr22_befCurHr.y,Hr23_befCurHr.u);

  connect(HeaGaiPro,sumCooLoaPro.u[1]);
  connect(Hr1_befCurHr.y,sumCooLoaPro.u[2]);
  connect(Hr2_befCurHr.y,sumCooLoaPro.u[3]);
  connect(Hr3_befCurHr.y,sumCooLoaPro.u[4]);
  connect(Hr4_befCurHr.y,sumCooLoaPro.u[5]);
  connect(Hr5_befCurHr.y,sumCooLoaPro.u[6]);
  connect(Hr6_befCurHr.y,sumCooLoaPro.u[7]);
  connect(Hr7_befCurHr.y,sumCooLoaPro.u[8]);
  connect(Hr8_befCurHr.y,sumCooLoaPro.u[9]);
  connect(Hr9_befCurHr.y,sumCooLoaPro.u[10]);
  connect(Hr10_befCurHr.y,sumCooLoaPro.u[11]);
  connect(Hr11_befCurHr.y,sumCooLoaPro.u[12]);
  connect(Hr12_befCurHr.y,sumCooLoaPro.u[13]);
  connect(Hr13_befCurHr.y,sumCooLoaPro.u[14]);
  connect(Hr14_befCurHr.y,sumCooLoaPro.u[15]);
  connect(Hr15_befCurHr.y,sumCooLoaPro.u[16]);
  connect(Hr16_befCurHr.y,sumCooLoaPro.u[17]);
  connect(Hr17_befCurHr.y,sumCooLoaPro.u[18]);
  connect(Hr18_befCurHr.y,sumCooLoaPro.u[19]);
  connect(Hr19_befCurHr.y,sumCooLoaPro.u[20]);
  connect(Hr20_befCurHr.y,sumCooLoaPro.u[21]);
  connect(Hr21_befCurHr.y,sumCooLoaPro.u[22]);
  connect(Hr22_befCurHr.y,sumCooLoaPro.u[23]);
  connect(Hr23_befCurHr.y,sumCooLoaPro.u[24]);

  connect(sumCooLoaPro.y,cooLoaPro);

end RadiantTimeSeries;
