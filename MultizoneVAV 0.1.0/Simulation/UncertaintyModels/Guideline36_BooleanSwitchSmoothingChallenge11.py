from pymodelica import compile_fmu
from pyfmi import load_fmu
import matplotlib.pyplot as P
import matplotlib.dates as md
import pandas as pd
import datetime
import matplotlib.ticker as mtick

conv_K_C=273.15
constantTemp=2.8

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

# Variables to save in the result file to reduce the file size
varLst_wBooSwiSmo = [\
'conVAV_222.damVal.hys7.y',
'conVAV_222.damVal.conTDisSet.y',
'conVAV_222.damVal.movAvg_TDisSet.y',
'conVAV_222.damVal.TRoo',
]

varLst_woBooSwiSmo = list(varLst_wBooSwiSmo)
varLst_woBooSwiSmo.remove('conVAV_222.damVal.movAvg_TDisSet.y')

dic_simCase={\
    'wBooSwiSmo':{\
        'varLst':varLst_wBooSwiSmo,
        #'label':'DAT$_{222,SP,Avg}$',
        'label':'DAT$_{222,SP}$',
        'linewidth':1.5,
        'title':'c',
        'footnote':'Stochastic (with Moving Average in the Boolean Switch)',
        'ax':2,
        },
    'woBooSwiSmo':{\
        'varLst':varLst_woBooSwiSmo,
        'label':'DAT$_{222,SP}$',
        'linewidth':1,
        'title':'b',
        'footnote':'Stochastic (Noise in Boolean Switch, i.e., without Moving Average)',
        'ax':1,
        },
    'deterministic':{\
        'varLst':varLst_woBooSwiSmo,
        'label':'DAT$_{222,SP}$',
        'linewidth':1,
        'title':'a',
        'footnote':'Deterministic (without Moving Average in Boolean Switch)',
        'ax':0,
        },
}

fmu_name = compile_fmu('MultizoneVAV.UncertaintyModels.VAVReheat.Guideline36', jvm_args='-Xmx4g', compiler_options={"generate_html_diagnostics":True})
model= load_fmu(fmu_name,log_level=7)
model.instantiate()

dayOfYear_start=35*(24*60*60)
hourOfDay_start=0*(60*60)
minuteOfHour_start=0*(60)

daySimRange=1*(24*60*60)
hourSimRange=0*(60*60)
minuteSimRange=0*(60)

sim_Start = dayOfYear_start+hourOfDay_start+minuteOfHour_start
SimulationRange = daySimRange+hourSimRange+minuteSimRange

# Showing figure
text_loc1=0.05
text_loc2=0.1
text_loc3=0.045
lgndLoc=3.56+0.5
fontsize=14.3

P.gcf().clear()
fig,axes=P.subplots(num=1,nrows=3,ncols=1,figsize=(7,5.5))
P.subplots_adjust(wspace=.04)

for simCase in dic_simCase.keys():

    model.reset()

    print(simCase)

    if simCase=='wBooSwiSmo':

        pass

    elif simCase=='woBooSwiSmo':

        # Disable the moving average used in the boolean switch
        model.set("conVAV_222.damVal.deltaMovAvg", 1e-5)

    elif simCase=='deterministic':

        # Disable the moving average used in the boolean switch
        model.set("conVAV_222.damVal.deltaMovAvg", 1e-5)

        # Disable stochastic signal, i.e., simulate deterministic control components
        for n in components[:]:
            if (n=='senTemRoo_406') or (n=='senTemRoo_222'):
                model.set("flo.normalNoise_"+n+".enableNoise", False)
                model.set("flo.normalNoise_"+n+".samplePeriod", SimulationRange)
            else:
                model.set("normalNoise_"+n+".enableNoise", False)
                model.set("normalNoise_"+n+".samplePeriod", SimulationRange)

    opts=model.simulate_options()

    opts['filter']=dic_simCase[simCase]['varLst']

    res=model.simulate(options=opts, start_time=sim_Start, final_time=sim_Start+SimulationRange)

    t=res['time']
    timestamps = pd.to_datetime(t, unit='s')

    hys7_y=res['conVAV_222.damVal.hys7.y']
    hys7_y_sr = pd.Series(hys7_y, index=timestamps, name='Boolean Switch')

    TDisSet_222=res['conVAV_222.damVal.conTDisSet.y']-conv_K_C
    TDisSet_222_sr = pd.Series(TDisSet_222, index=timestamps, name=dic_simCase[simCase]['label'])

    TRoo_222_wConsTemp=res['conVAV_222.damVal.TRoo']-conv_K_C+constantTemp
    TRoo_222_wConsTemp_sr = pd.Series(TRoo_222_wConsTemp, index=timestamps, name='T$_{222}$ + 2.8 [$^\circ$C]')

    if simCase=='wBooSwiSmo':
        TDisSet_movAvg_222=res['conVAV_222.damVal.movAvg_TDisSet.y']-conv_K_C
        TDisSet_movAvg_222_sr = pd.Series(TDisSet_movAvg_222, index=timestamps, name=dic_simCase[simCase]['label'])

        TDisSet_222_toPlot_sr=TDisSet_movAvg_222_sr
    elif simCase=='woBooSwiSmo' or simCase=='deterministic':
        TDisSet_222_toPlot_sr=TDisSet_222_sr

    ax1=axes[dic_simCase[simCase]['ax']]
    ax2=ax1.twinx()

    lns1=ax1.plot(TDisSet_222_toPlot_sr,color='r',linewidth=dic_simCase[simCase]['linewidth'])
    lns2=ax1.plot(TRoo_222_wConsTemp_sr,color='b',linewidth=1)
    lns3=ax2.plot(hys7_y_sr,color='k',linewidth=1)

    ax1.set_xlim([datetime.datetime(1970,2,5,7),datetime.datetime(1970,2,5,19)])
    ax1.set_ylim([10,30])
    ax2.set_ylim([0,3.75])
    ax1.set_ylabel('Temp. [$^\circ$C]')

    ax1.grid()
    ax1.title.set_text(dic_simCase[simCase]['title'])

    MjLocator=range(7,20)
    MjFormatter='%H'

    ax1.xaxis.set_major_locator(md.HourLocator(byhour=MjLocator))
    ax1.xaxis.set_major_formatter(md.DateFormatter(MjFormatter))

    if simCase=='woBooSwiSmo' or simCase=='deterministic':
        P.setp(ax1.get_xticklabels(which='both'),visible=False)
    elif simCase=='wBooSwiSmo':
        ax1.set_xlabel('Time [hr]')

        MiLocator=13
        MiFormatter='\n%b %d'
        ax1.xaxis.set_minor_locator(md.HourLocator(byhour=MiLocator))
        ax1.xaxis.set_minor_formatter(md.DateFormatter(MiFormatter))
        for text in ax1.get_xminorticklabels():
            text.set_fontsize(fontsize)

        lns=lns1+lns2+lns3
        labs=[l.get_label() for l in lns]
        lgnd=ax1.legend(lns,labs,loc='upper center', framealpha = 0.5, fontsize=fontsize,ncol=5, handletextpad=0.3,columnspacing=0.3, borderpad=0.15, labelspacing=0.12,bbox_to_anchor=(0.5,lgndLoc))
        for lgndObj in lgnd.legendHandles:
            lgndObj.set_linewidth(3)

    ax2.set_ylabel('False / True')

    for item in ([ax1.title,ax1.xaxis.label,ax1.yaxis.label]+ax1.get_xticklabels()+ax1.get_yticklabels()):
        item.set_fontsize(fontsize)
    for item in ([ax2.title,ax2.xaxis.label,ax2.yaxis.label]+ax2.get_xticklabels()+ax2.get_yticklabels()):
        item.set_fontsize(fontsize)
    for ax in [ax1,ax2]:
        P.setp(ax.get_yticklabels()[0],visible=False)
        P.setp(ax.get_yticklabels()[-1],visible=False)

    loc2=mtick.MultipleLocator(base=0.25)
    ax2.yaxis.set_major_locator(loc2)

    values=ax2.get_yticks().tolist()
    labels=ax2.get_yticks().tolist()

    for i in range(len(labels)):
        if (i==1) or (i ==5):
            labels[i]=str(int(ax2.get_yticks().tolist()[i]))
        else:
            labels[i]=''

    ax2.set_yticks(values)
    ax2.set_yticklabels(labels)

    ax2.tick_params(axis='y', which=u'both',length=0)

    P.text(text_loc1,text_loc2-text_loc3*dic_simCase[simCase]['ax'],dic_simCase[simCase]['title']+' '+dic_simCase[simCase]['footnote'],ha='left',transform=P.gcf().transFigure, fontsize=fontsize)

P.subplots_adjust(left=0.09, right=0.93, top=0.88, bottom=0.28)

P.show()
