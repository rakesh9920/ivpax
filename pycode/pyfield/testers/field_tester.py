 
import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from pyfield.field import Field
 
f0 = 5e6
fs = 100e6

impulse_response = sp.sin(2*sp.pi*f0*np.arange(0, 1/f0 + 1/fs, 1/fs))
impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
impulse_response.shape = (1, np.size(impulse_response)) # force row vector
excitation = impulse_response.copy()

f2 = Field()
libf2 = f2.libf2

f2.field_init(0, diarypath="test.txt")
f2.set_field("fs", 100e6)
f2.set_field("c", 1500)

Th1 = f2.xdc_piston(0.01, 0.001)
f2.xdc_impulse(Th1, impulse_response)
f2.xdc_excitation(Th1, excitation)
f2.xdc_focus_times(Th1, np.zeros((1,1)), np.zeros((1,1)))

Th2 = f2.xdc_linear_array(128, 300e-6, 300e-6, 150e-6, 1, 1, 
    np.array([0, 0, 300]))
f2.xdc_impulse(Th2, impulse_response)
f2.xdc_excitation(Th2, excitation)
f2.xdc_focus_times(Th2, np.zeros((1,1)), np.zeros((1,128)))

Th3 = f2.xdc_2d_array(5, 5, 50e-6, 50e-6, 10e-6, 10e-6, np.ones((5,5)), 1, 1,
    np.array([0, 0, 300]))
f2.xdc_impulse(Th3, impulse_response)
f2.xdc_excitation(Th3, excitation)
f2.xdc_focus_times(Th3, np.zeros((1,1)), np.zeros((1,5*5)))

#rect = f2.xdc_get(Th1, "rect")

points = np.array([[0, 0, 0.05],[0, 0, 0.06]])
amplitudes = np.array([[1],[2]])
(scat1,t01) = f2.calc_scat(Th1, Th1, points, amplitudes)
(scat2, t02) = f2.calc_scat_multi(Th2, Th2, points, amplitudes)
(scat3, t03) = f2.calc_scat_multi(Th3, Th3, points, amplitudes)

f2.xdc_free(Th1)
f2.xdc_free(Th2)
f2.xdc_free(Th3)
f2.field_end()

pp.figure()
pp.plot(scat1)
pp.figure()
pp.plot(scat2)
pp.figure()
pp.plot(scat3)
pp.show()