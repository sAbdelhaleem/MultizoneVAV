from pymodelica import compile_fmu
from pyfmi import load_fmu
import matplotlib.pyplot as P
import matplotlib.dates as md
import pandas as pd
import matplotlib.ticker as mtick

fmu_name = compile_fmu("MultizoneVAV.UncertaintyModels.VAVReheat.Guideline36", jvm_args='-Xmx4g', compiler_options={"generate_html_diagnostics":True},compiler_log_level='error')
model= load_fmu(fmu_name,log_level=7)
dayOfYear_start=7*(24*60*60)
hourOfDay_start=7*(60*60)
minuteOfHour_start=0*(60)

daySimRange=0*(24*60*60)
hourSimRange=1*(60*60)
minuteSimRange=0*(60)

sim_Start = dayOfYear_start+hourOfDay_start+minuteOfHour_start
SimulationRange = daySimRange+hourSimRange+minuteSimRange

ComponentAccuracy_dic={'senTemRoo':{
                                    'sigma':{
                                                'zero':0,
                                                'low':1.0/2,
                                                'med':0.2/2}}}

SimCase_dic={
                0:{
                    'axes':0,
                    '406':'med',
                    '222':'med',
                    'proxyTitle':'a',
                    'title':'a: Zone air temperature sensors in both zone 406 and zone 222 are medium-accuracy'},
                1:{
                    'axes':1,
                    '406':'low',
                    '222':'zero',
                    'proxyTitle':'b',
                    'title':'b: Zone air temperature sensors in zone 406 and zone 222 are low-accuracy and zero-accuracy (deterministic) respectively'}}

fig,ax=P.subplots(num=1,nrows=1,ncols=2,figsize=(9.5*1.7,6))
P.subplots_adjust(wspace=0.1)

fontsize=14

model.instantiate()

for SimulationCase in range(len(SimCase_dic.keys())):

    ax1=ax[SimCase_dic[SimulationCase]['axes']]

    model.reset()

    model.set("flo.normalNoise_senTemRoo_406.sigma", ComponentAccuracy_dic['senTemRoo']['sigma'][SimCase_dic[SimulationCase]['406']])
    model.set("flo.normalNoise_senTemRoo_222.sigma", ComponentAccuracy_dic['senTemRoo']['sigma'][SimCase_dic[SimulationCase]['222']])

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

    # Zone air temperature with noise
    T_406_N=res['flo.addNoise_senTemRoo_406.y']-conv_K_C
    T_222_N=res['flo.addNoise_senTemRoo_222.y']-conv_K_C

    T_406_N_sr = pd.Series(T_406_N, index=timestamps, name='T$_{406, N}$')
    T_222_N_sr = pd.Series(T_222_N, index=timestamps, name='T$_{222, N}$')

    lns1=ax1.plot(T_406_sr,linewidth=2.5,color='b',linestyle=(0,(10,5)),zorder=3)
    lns2=ax1.plot(T_222_sr,linewidth=2.5,color='r',linestyle=(0,(10,5)),zorder=3)
    lns3=ax1.plot(T_406_N_sr,linewidth=1,color='b',zorder=2)
    lns4=ax1.plot(T_222_N_sr,linewidth=1,color='r',zorder=2)
    lns3=ax1.plot(T_222_heaSP_sr,linewidth=1.5,color='c',zorder=1)
    lns4=ax1.plot(T_222_cooSP_sr,linewidth=1.5,color='c',zorder=1)

    MjLocator=[0,15,30,45]
    MjFormatter='%H:%M'
    MiLocator=30
    MiFormatter='\n%b %d'

    ax1.xaxis.set_major_locator(md.MinuteLocator(byminute=MjLocator))
    ax1.xaxis.set_major_formatter(md.DateFormatter(MjFormatter))
    ax1.xaxis.set_minor_locator(md.MinuteLocator(byminute=MiLocator))
    ax1.xaxis.set_minor_formatter(md.DateFormatter(MiFormatter))

    ax1.title.set_text(SimCase_dic[SimulationCase]['proxyTitle'])

    if SimulationCase==1:
        ax1.set_yticklabels([])
        lgnd=ax1.legend(loc='upper left',framealpha=0.5, fontsize=fontsize, bbox_to_anchor=(1.03,0.82))
        for lgndObj in lgnd.legendHandles:
            lgndObj.set_linewidth(2)
    else:
        ax1.set_ylabel('Zone air temperature [$^\circ$C]')

    ax1.set_ylim([18.1,23])
    ax1.grid()

    for item in ([ax1.title,ax1.xaxis.label,ax1.yaxis.label]+ax1.get_xticklabels()+ax1.get_yticklabels()):
        item.set_fontsize(fontsize)
    ax1.tick_params(axis='x',which='both', labelsize=fontsize)

    loc1=mtick.MultipleLocator(base=0.5)
    ax1.yaxis.set_major_locator(loc1)

    text_loc1=0.05
    text_loc2=0.28
    text_loc3=0.05

    suptitle=SimCase_dic[SimulationCase]['title']
    P.text(text_loc1,text_loc2-text_loc3*(0+SimulationCase),suptitle,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)

    if SimulationCase==len(SimCase_dic.keys())-1:

        suptitle1='406/222: Thermal zones under study'
        suptitle2='T$_{SP}$: Heating and cooling zone air temperature set-points'
        suptitle3='T$_{406/222}$: Physical zone air temperature before adding noise signal to sensor measurement'
        suptitle4='T$_{406/222, N}$: Zone air temperature after adding the noise signal to sensor measurement'

        P.text(text_loc1,text_loc2-text_loc3*(0+len(SimCase_dic.keys())),suptitle1,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
        P.text(text_loc1,text_loc2-text_loc3*(1+len(SimCase_dic.keys())),suptitle2,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
        P.text(text_loc1,text_loc2-text_loc3*(2+len(SimCase_dic.keys())),suptitle3,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)
        P.text(text_loc1,text_loc2-text_loc3*(3+len(SimCase_dic.keys())),suptitle4,ha='left',transform=P.gcf().transFigure, fontsize=fontsize)

P.subplots_adjust(left=0.06, right=0.9, top=0.92, bottom=0.42)

P.show()
