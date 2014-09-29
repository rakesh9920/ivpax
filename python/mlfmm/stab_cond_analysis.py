# mlfmm / stab_cond_analysis.py

import numpy as np
import matplotlib.pyplot as pp

D0 = 0.007
C = 1


f = np.linspace(0, 40e6, 1000)
k = 2*np.pi*f/1540

stab_cond = np.zeros((5, f.size))
idx = 0
for l in xrange(2,7):
    
    v = np.sqrt(3)*D0/(2**l)*k
    stab_cond[idx,:] = 0.15*v/np.log(v + np.pi)
    idx += 1

fig = pp.figure(tight_layout=True)
ax = fig.add_subplot(111)
ax.plot(f/1e6, stab_cond.T)
ax.plot(f/1e6, np.ones_like(f),'k:')
ax.fill_between(f/1e6, 1, 0, alpha=0.1, facecolor='red', hatch='//', edgecolor='black')
ax.set_ylim(0, 2.5)
ax.legend(('l=2','l=3','l=4','l=5','l=6','cutoff'), loc='best')
ax.set_xlabel('Frequency (MHz)')
ax.set_ylabel('Stability Condition (> 1 is stable)')
ax.set_title('''Stability analysis of M2L translation for \n$D_0$ = 1mm and ~5% accuracy''')
pp.show()

