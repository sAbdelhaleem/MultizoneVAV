within MultizoneVAV.UncertaintyModels.LibraryModifications.Modelica_S.Blocks;
package Noise "Library of noise blocks" // _99_01_benchmark
  extends Modelica.Icons.Package;

  block NormalNoise_S
    import distribution = Modelica.Math.Distributions.Normal.quantile;
    extends Modelica.Blocks.Interfaces.PartialNoise;
    parameter Real mu=0;
    Real sigma(start=1); // shiyab adjusted
  initial equation
     r = distribution(r_raw, mu, sigma);
  equation
    when generateNoise and sample(startTime, samplePeriod) then
      r = distribution(r_raw, mu, sigma);
    end when;
  end NormalNoise_S;

end Noise;
