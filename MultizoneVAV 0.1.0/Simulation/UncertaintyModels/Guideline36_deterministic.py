from pymodelica import compile_fmu
from pyfmi import load_fmu
import matplotlib.pyplot as P
import matplotlib.dates as md
import pandas as pd
import numpy as N
import matplotlib.ticker as mtick

fmu_name = compile_fmu("MultizoneVAV.UncertaintyModels.VAVReheat.Guideline36_deterministic", jvm_args='-Xmx4g', compiler_options={"generate_html_diagnostics":True})
model= load_fmu(fmu_name,log_level=7)
dayOfYear_start=7*(24*60*60)
hourOfDay_start=0*(60*60)
minuteOfHour_start=0*(60)

daySimRange=0*(24*60*60)
hourSimRange=12*(60*60)
minuteSimRange=0*(60)

sim_Start = dayOfYear_start+hourOfDay_start+minuteOfHour_start
SimulationRange = daySimRange+hourSimRange+minuteSimRange

res=model.simulate(start_time=sim_Start, final_time=sim_Start+SimulationRange)

# Convert from K to C
conv_K_C=273.15

# Time
t=res['time']
timestamps = pd.to_datetime(t, unit='s')

# Physical zone air temperature for the two thermal zones without noise
T_406=res['flo.senTemRoo_406.T']-conv_K_C
T_222=res['flo.senTemRoo_222.T']-conv_K_C

T_406_sr = pd.Series(T_406, index=timestamps, name='T$_{406}$')
T_222_sr = pd.Series(T_222, index=timestamps, name='T$_{222}$')

# Zone air temperature set-points for the two thermal zones
T_222_heaSP=res['conVAV_222.TRooHeaSet']-conv_K_C
T_222_cooSP=res['conVAV_222.TRooCooSet']-conv_K_C

T_222_heaSP_sr = pd.Series(T_222_heaSP, index=timestamps, name='T$_{SP}$')
T_222_cooSP_sr = pd.Series(T_222_cooSP, index=timestamps)

## Zone air temperature with noise
#T_406_N=res['flo.addNoise_senTemRoo_406.y']-conv_K_C
#T_222_N=res['flo.addNoise_senTemRoo_222.y']-conv_K_C

#T_406_N_sr = pd.Series(T_406_N, index=timestamps, name='T$_{406, N}$')
#T_222_N_sr = pd.Series(T_222_N, index=timestamps, name='T$_{222, N}$')

# Mode of Operation
yOpeMod = res['TSetZon.yOpeMod']
yOpeMod_sr = pd.Series(yOpeMod, index=timestamps, name='Operating Mode')

fig,ax1=P.subplots(num=1,nrows=1,ncols=1,figsize=(9.5,6))
ax2 = ax1.twinx()

fontsize=14

lns1=ax1.plot(T_406_sr,linewidth=2.5,color='b',zorder=3)
lns2=ax1.plot(T_222_sr,linewidth=2.5,color='r',zorder=3)
#lns3=ax1.plot(T_406_N_sr,linewidth=1,color='b',zorder=2)
#lns4=ax1.plot(T_222_N_sr,linewidth=1,color='r',zorder=2)
lns3=ax1.plot(T_222_heaSP_sr,linewidth=1.5,color='c',zorder=1)
lns4=ax1.plot(T_222_cooSP_sr,linewidth=1.5,color='c',zorder=1)
lns5=ax2.plot(yOpeMod_sr,linewidth=1.5,color='y',zorder=1)
lns=lns1+lns2+lns3+lns5
labs=[l.get_label() for l in lns]

MjLocator=N.linspace(0,12,7)
MjFormatter='%H:%M'
MiLocator=6
MiFormatter='\n%b %d'

ax1.xaxis.set_major_locator(md.HourLocator(byhour=MjLocator))
ax1.xaxis.set_major_formatter(md.DateFormatter(MjFormatter))
ax1.xaxis.set_minor_locator(md.HourLocator(byhour=MiLocator))
ax1.xaxis.set_minor_formatter(md.DateFormatter(MiFormatter))

ax1.title.set_text('Zone air temperature')
lgnd=ax1.legend(lns,labs,loc='upper right',framealpha=0.5, fontsize=fontsize, ncol=2, handletextpad=0.1)
for lgndObj in lgnd.legendHandles:
    lgndObj.set_linewidth(2)

ax1.set_ylabel('Temperature [$^\circ$C]')
ax1.margins(y=0.05)
ax1.grid()

ax2.set_ylabel('Operating Mode')
loc1=mtick.MultipleLocator(base=1)
ax2.yaxis.set_major_locator(loc1)

ax2.set_ylim([-0.2,7.5])

for ax in [ax1,ax2]:
    for item in ([ax.title,ax.xaxis.label,ax.yaxis.label]+ax.get_xticklabels()+ax.get_yticklabels()):
        item.set_fontsize(fontsize)
ax1.tick_params(axis='x',which='both', labelsize=fontsize)

suptitle1='406/222: Thermal zones under study'
suptitle2='T$_{SP}$: Heating and cooling zone air temperature set-points'
suptitle3='T$_{406/222}$: Physical zone air temperature'
#suptitle4='T$_{406/222, N}$: Zone air temperature after adding the noise signal to sensor measurement'
suptitle5='Operating Mode: 1=Occupied, 2=Cooldown, 3=Setup, 4=Warmup, 5=Setback, 7=Unoccupied'

text_loc1=0.03
text_loc2=0.18
text_loc3=0.05

P.text(text_loc1,text_loc2-text_loc3*0,suptitle1,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
P.text(text_loc1,text_loc2-text_loc3*1,suptitle2,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
P.text(text_loc1,text_loc2-text_loc3*2,suptitle3,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
#P.text(text_loc1,text_loc2-text_loc3*3,suptitle4,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
P.text(text_loc1,text_loc2-text_loc3*3,suptitle5,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)

P.subplots_adjust(left=0.12, right=0.95, top=0.92, bottom=0.32)

P.show()
