from pymodelica import compile_fmu
from pyfmi import load_fmu

fmu_name = compile_fmu("MultizoneVAV.UncertaintyModels.VAVReheat.Guideline36_SimulationCrashChallenge5", jvm_args='-Xmx4g', compiler_options={"generate_html_diagnostics":True})
model= load_fmu(fmu_name,log_level=7)
dayOfYear_start=24*(24*60*60)
hourOfDay_start=0*(60*60)
minuteOfHour_start=0*(60)

daySimRange=1*(24*60*60)
hourSimRange=0*(60*60)
minuteSimRange=0*(60)

sim_Start = dayOfYear_start+hourOfDay_start+minuteOfHour_start
SimulationRange = daySimRange+hourSimRange+minuteSimRange

seed=693426826
model.set("globalSeed.fixedSeed",seed)

res=model.simulate(start_time=sim_Start, final_time=sim_Start+SimulationRange)
