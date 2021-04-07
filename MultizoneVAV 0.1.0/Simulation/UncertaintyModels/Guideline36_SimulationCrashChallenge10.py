from pymodelica import compile_fmu
from pyfmi import load_fmu

# Control components simulated with stochastic signal
components = [\
'senTemRoo_406', 'senTemRoo_222',
'senDAT_406', 'senDAT_222',
'senVolFlo_406', 'senVolFlo_222',
'406_yDam', '222_yDam',
'406_yVal', '222_yVal',
'senSAT', 'TOut',
'senVolFloOut',
'dpDisSupFan',
'fanSup_y',
'eco_yOut', 'eco_yRet',
'swiFreSta_u3', 'gaiCooCoi_u']

fmu_name = compile_fmu("MultizoneVAV.UncertaintyModels.VAVReheat.Guideline36", jvm_args='-Xmx4g', compiler_options={"generate_html_diagnostics":True},compiler_log_level='error')
model= load_fmu(fmu_name,log_level=7)
dayOfYear_start=230*(24*60*60)
hourOfDay_start=0*(60*60)
minuteOfHour_start=0*(60)

daySimRange=2*(24*60*60)
hourSimRange=0*(60*60)
minuteSimRange=0*(60)

sim_Start = dayOfYear_start+hourOfDay_start+minuteOfHour_start
SimulationRange = daySimRange+hourSimRange+minuteSimRange

seed=890132903
model.set("globalSeed.fixedSeed",seed)

# Aligning stochastic signal at the top of the minute
for n in components[:]:
    if (n=='senTemRoo_406') or (n=='senTemRoo_222'):
        model.set("flo.normalNoise_"+n+".startTime", 0)
    else:
        model.set("normalNoise_"+n+".startTime", 0)

res=model.simulate(start_time=sim_Start, final_time=sim_Start+SimulationRange)
