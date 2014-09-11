

import matplotlib.pyplot as pp
import numpy as np
from scipy.stats import rayleigh

file_path = './data/bsc/custombsc_data.npz'    
    
if __name__ == '__main__':
    
    with np.load(file_path) as npzvars:
        
        freq = npzvars['freq']
        mean_cam = npzvars['mean_cam']
        root_bsc = npzvars['root_bsc']
        bsc_blood = npzvars['bsc_blood']
        cam_blood = npzvars['cam_blood']
        bsc_heart = npzvars['bsc_heart']
        cam_heart = npzvars['cam_heart']
    
    pp.rc('mathtext', fontset='cm', default='regular')
    pp.rc('axes', linewidth = 0.6)
    
    # spectrum plots for cam and bsc
    fig2 = pp.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
    ax2 = fig2.add_subplot(111)
    ax2.tick_params(labelsize=9)
    #ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.set_xlim(3.5, 11)
    
    c1, = pp.plot(freq/1e6, np.mean(cam_blood, axis=1), 'b-')
    b1, = pp.plot(bsc_blood[:,0]/1e6, bsc_blood[:,1], color='#fdb462', marker='v', 
        alpha=0.9, ls='none')
    
    c2, = pp.plot(freq/1e6, np.mean(cam_heart, axis=1), 'b-')
    b2, = pp.plot(bsc_heart[:,0]/1e6, bsc_heart[:,1], color='#fb8072', marker='o', 
        alpha=0.9, ls='none')
    
    #c3, = pp.plot(freq[freq1:freq2]/1e6, np.mean(cam3, axis=1), 'b-')
    ##e3, = pp.plot(freq[freq1:freq2]/1e6, error_upper3,'b:')
    ##pp.plot(freq[freq1:freq2]/1e6, error_lower3, 'b:')
    #b3, = pp.plot(bsc3[:,0]/1e6, bsc3[:,1], color='#80b1d3', marker='s', 
    #    alpha=0.9, ls='none')
    
    #ax2.legend((c1, e1, b1, b2, b3), ('CAM','95% CI',' Blood, Shung et. al.',
        #'Kidney, Wear et. al.','Liver, Wear et. al.'), loc='center left', 
        #frameon=False, fontsize=10)
    #ax2.legend((c1, b1, b2, b3), ('CAM', 'blood', 'kidney', 'liver'),
    #    frameon=False, fontsize=9, loc='center left')
    ax2.legend((c1, b1, b2), ('CAM', 'blood','heart'),
        frameon=False, fontsize=9, loc='best', numpoints=1)
    ax2.set_xlabel('Frequency ($MHz$)', fontsize=9)
    #ax2.set_ylabel('Backscattering \n Coefficient ($m^{-1}Sr^{-1}$)', fontsize=9)
    ax2.set_ylabel('BSC ($m^{-1}Sr^{-1}$)', fontsize=9)
    #ax2.set_ylabel(r'$\eta(f) \, (m^{-1}Sr^{-1})$', fontsize=9)
    
    # histogram for root bsc
    fig3 = pp.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
    ax3 = fig3.add_subplot(111)
    ax3.tick_params(labelsize=9)
    ax3.set_xlim(0, 4.0)
    
    _, _, patches = ax3.hist(root_bsc, bins=30, normed=True,
        facecolor='#fdb462')
    
    for p in patches:
        p.set_linewidth(0.4)
        p.set_edgecolor('black')
        
    ax3.plot(np.linspace(0, 4, 100), rayleigh.pdf(np.linspace(0, 4, 100)), 
        'k--', linewidth=0.8)
    
    ax3.set_xlabel(r'Normalized Root BSC $\mathit{[2\eta(f) / \bar{\eta}(f)]^{1/2}}$',
        fontsize=9) 
    ax3.set_ylabel('Probability density', fontsize=9)
    ax3.legend((r'Rayleigh pdf' '\n' r'$(\alpha = 1)$','CAM'), 
        fontsize=9, frameon=False, loc='upper right')
        
    fig2.show()
    fig3.show()
