# mlfmm / angle_error_analysis_plots.py

import numpy as np
import matplotlib.pyplot as pp
from scipy.optimize import curve_fit
from scipy.stats import linregress

file1 = './data/angle_error_vars_1mm_level2.npz'
file2 = './data/angle_error_vars_1mm_level3.npz'
file3 = './data/angle_error_vars_1mm_level3_2.npz'

with np.load(file1) as varz:
    
    freqs = varz['freqs']
    orders2 = varz['orders23']
    errors2 = varz['errors23']
    sugg_orders2 = varz['sugg_orders23']
    
with np.load(file2) as varz:
    
    orders4 = varz['orders45']
    errors4 = varz['errors45']
    sugg_orders4 = varz['sugg_orders45']

with np.load(file3) as varz:
    
    orders3 = varz['orders34']
    errors3 = varz['errors34']
    orders4_2 = varz['orders1']
    sugg_orders3 = varz['sugg_orders34']
    
def logf(x, a, b, c):
    
    return a + b*np.log(x + c)
    
if __name__ == '__main__':
    
    m3, y03, _, _, _ = linregress(freqs, orders3)
    m4, y04, _, _, _ = linregress(freqs, orders4)
    m4_2, y04_2, _, _, _ = linregress(freqs, orders4_2)

    sugg_angles4 = np.zeros_like(orders4_2)
    sugg_angles4[0] = orders4_2[0]
    temp = sugg_angles4[0]
    
    for x in xrange(1, len(sugg_angles4)):
        
        order = orders4_2[x]
        if order < temp:
            sugg_angles4[x] = temp
        else:
            sugg_angles4[x] = order
            temp = order
    
    fig1 = pp.figure()
    ax1 = fig1.add_subplot(111)
    ax1.plot(freqs/1e6, orders2,'r')
    ax1.plot(freqs/1e6, sugg_orders2,'r:')
    ax1.plot(freqs/1e6, orders3,'g')
    ax1.plot(freqs/1e6, sugg_orders3,'g:')
    ax1.plot(freqs/1e6, orders4_2,'b')
    ax1.plot(freqs/1e6, sugg_orders4,'b:')
    ax1.legend(('l=2 simulated','l=2 suggested','l=3 simulated','l=3 suggested',
        'l=4 simulated','l=4 suggested'), loc='best')
    ax1.set_xlabel('Frequency (MHz)')
    ax1.set_ylabel('Angle order no.')
    #pp.plot(freqs/1e6, np.round(m3*freqs + y03),':')
    #pp.plot(freqs/1e6, np.round(m4_2*freqs + y04_2),':')
    pp.show()
    
    fig2 = pp.figure()
    ax2 = fig2.add_subplot(111)
    ax2.plot(freqs/1e6, errors2,':')
    ax2.plot(freqs/1e6, errors3,':')
    ax2.plot(freqs/1e6, errors4,':')
    ax2.legend(('l=2 max error','l=3 max error', 'l=4 max error'), loc='best')
    ax2.set_xlabel('Frequency (MHz)')
    ax2.set_ylabel('Error (%)')
    pp.show()
    