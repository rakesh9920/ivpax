from mayavi import mlab
import numpy as np


with np.load('./data/simple_lumen_1d_vortical_flow.npz') as data:
    
    fdata_inst = data['fdata_inst']
    fdata_corrlag = data['fdata_corrlag']
    fdata_actual = data['fdata_actual']
    x = data['x']
    y = data['y']
    z = data['z']

    
if __name__ == '__main__':

    #v = fdata_actual.reshape((20, 20, 30, 3))
    actual = fdata_actual[2,...]
    
    flow = fdata_corrlag.reshape((20, 20, 30, 19))
    v = actual #(flow[...,0] - actual)
    
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
    #    np.zeros_like(y), v[...,0])
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
        #np.zeros_like(y), v)
    src = mlab.pipeline.vector_field(x, y, z, v[0,...], v[1,...], v[2,...])
    
    vec = mlab.pipeline.vectors(src, scale_factor = 1)
    vec.glyph.glyph.clamping = False
    vec.glyph.mask_points.maximum_number_of_points = 10000
    vec.glyph.mask_points.on_ratio = 20
    vec.glyph.mask_input_points = True
    
    mlab.outline()
    
    axes = mlab.axes()
    axes.axes.font_factor = 0.5
    axes.label_text_property.bold = False
    axes.title_text_property.bold = False
    
    mlab.colorbar(orientation='vertical', title='m/s')
    lut = mlab.colorbar(orientation='vertical', title='m/s')
    lut.data_range = np.array([0, 0.008])
    lut.use_default_range = False
    
    
        