from mayavi import mlab
import numpy as np


with np.load('./data/diagonal_lumen_flow.npz') as data:
    
    #fdata_inst = data['fdata_inst']
    fdata_corrlag = data['fdata_corrlag']
    fdata_actual = data['fdata_actual']
    x = data['x']
    y = data['y']
    z = data['z']

if __name__ == '__main__':

    
    #v = fdata_actual.reshape((20, 20, 30, 3))
    actual = fdata_actual[...,0]
    
    flow = fdata_corrlag[...,0]
    error = flow - actual
    
    v = error
    
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
    #    np.zeros_like(y), v[...,0])
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
        #np.zeros_like(y), v)
    src = mlab.pipeline.vector_field(x, y, z, v[...,0], 
        v[...,1], v[...,2])
    #src = mlab.pipeline.vector_field(x, y, z, v[0,...], v[1,...], v[2,...])
    
    vec = mlab.pipeline.vectors(src, scale_factor = 0.15)
    vec.glyph.glyph.clamping = False
    vec.glyph.mask_points.maximum_number_of_points = 10000
    vec.glyph.mask_points.on_ratio = 10
    vec.glyph.mask_input_points = True
    
    mlab.outline()
    
    axes = mlab.axes()
    axes.axes.font_factor = 0.5
    axes.label_text_property.bold = False
    axes.title_text_property.bold = False
    
    mlab.colorbar(orientation='vertical', title='m/s')
    lut = mlab.colorbar(orientation='vertical', title='m/s')
    lut.data_range = np.array([0.00, 0.017])
    lut.use_default_range = False
    
    
        