from mayavi import mlab
import numpy as np
from mayavi.api import Engine
import h5py

#with np.load('./data/xyz_flow_data.npz') as data:
#    
#    #fdata_inst = data['fdata_inst']
#    fdata_corrlag = data['fdata_corrlag']
#    fdata_actual = data['fdata_actual']
#    x = data['x']
#    y = data['y']
#    z = data['z']

with h5py.File('./data/simple lumen flow/vortical_lumen_data.hdf5','r') as root:
    
    fdata_corrlag = root['flowdata/fluid2_3d'].reshape((20,20,30,3,-1))
    view = root['view/view0'].reshape((20,20,30, 3))
    x = view[...,0]
    y = view[...,1]
    z = view[...,2]
    
if __name__ == '__main__':

    
    #v = fdata_actual.reshape((20, 20, 30, 3))
    #actual = fdata_actual[...,0]
    
    flow = fdata_corrlag[...,0]
    #flow = fdata_corrlag[...,0]
    #error = flow - actual
    
    v = flow
    
    mlab.figure(size=(600,600))
    
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
    #    np.zeros_like(y), v[...,0])
    #src = mlab.pipeline.vector_field(x, y, z, np.zeros_like(x), 
        #np.zeros_like(y), v)
    src = mlab.pipeline.vector_field(x, y, z, v[...,0], 
        v[...,1], v[...,2])
    #src = mlab.pipeline.vector_field(x, y, z, v[0,...], v[1,...], v[2,...])
    
    vec = mlab.pipeline.vectors(src, scale_factor = 0.2)
    vec.glyph.glyph.clamping = False
    vec.glyph.mask_points.maximum_number_of_points = 10000
    vec.glyph.mask_points.on_ratio = 3
    vec.glyph.mask_input_points = True
    vec.glyph.glyph_source.glyph_position = 'center'
    vec.glyph.mask_points.random_mode = False
    
    outline = mlab.outline()
    axes = mlab.axes()
    engine = mlab.get_engine()
    
    axes.axes.font_factor = 1.5
    axes.label_text_property.bold = False
    axes.title_text_property.bold = False
    axes.property.color = (0.0, 0.0, 0.0)
    axes.title_text_property.italic = False
    axes.label_text_property.italic = False
    axes.label_text_property.color = (0.0, 0.0, 0.0)
    axes.property.color = (1.0, 1.0, 1.0)
    axes.property.display_location = 'background'
    axes.axes.x_label = 'x (cm)'
    axes.axes.y_label = 'y (cm)'
    axes.axes.z_label = 'z (cm)'
    axes.axes.bounds = np.array([-0.01 ,  0.01 , -0.01,  0.01,  0.008,  0.042])
    axes.title_text_property.color = (0.0, 0.0, 0.0)
    axes.axes.label_format = '%-#6.1g'
    axes.axes.corner_offset = 0.05

    mlab.colorbar(orientation='vertical', title='m/s')
    lut = mlab.colorbar(orientation='vertical', title='m/s')
    lut.data_range = np.array([0.01, 0.018])
    lut.use_default_range = False
    lut.number_of_labels = 6
    lut.title_text_property.italic = False
    lut.title_text_property.shadow_offset = np.array([ 1, -1])
    lut.title_text_property.bold = False  
    lut.label_text_property.color = (0.0, 0.0, 0.0)
    lut.title_text_property.color = (0.0, 0.0, 0.0)
    lut.scalar_bar.label_format = '%-#6.2g'
    lut.label_text_property.italic = False
    lut.label_text_property.bold = False
    
    outline.bounds = np.array([-0.01 ,  0.01 , -0.01 ,  0.01 ,  0.008,  0.042])
    outline.outline_mode = 'cornered'
    outline.actor.property.color = (0.0, 0.0, 0.0)

    scene = mlab.gcf()#engine.scenes[0]
    scene.scene.background = (1.0, 1.0, 1.0)

    scene.scene.isometric_view()
    scene.scene.camera.position = [0.052469634106406982, 0.052469634106406982, 
        0.077469634106406976]
    scene.scene.camera.focal_point = [0.0, 0.0, 0.025000000000000001]
    scene.scene.camera.view_angle = 30.0
    scene.scene.camera.view_up = [0.0, 0.0, 1.0]
    scene.scene.camera.clipping_range = [0.045163117150733172, 
        0.14864750758482098]
    scene.scene.camera.compute_view_plane_normal()
    scene.scene.render()
    scene.scene.camera.position = [0.05750634694271739, 0.047861273997870483, 
        0.0770412813786331]
    scene.scene.camera.focal_point = [0.0050367128363103478, 
        -0.0046083601085364226, 0.024571647272226087]
    scene.scene.camera.view_angle = 30.0
    scene.scene.camera.view_up = [0.0, 0.0, 1.0]
    scene.scene.camera.clipping_range = [0.045163117150733172, 
        0.14864750758482098]
    scene.scene.camera.compute_view_plane_normal()
    scene.scene.render()
    lut.scalar_bar_representation.maximum_size = np.array([100000, 100000])
    lut.scalar_bar_representation.minimum_size = np.array([1, 1])
    lut.scalar_bar_representation.position2 = np.array([ 0.11836394,  
        0.84316547])
    lut.scalar_bar_representation.moving = 1
    lut.scalar_bar_representation.position = np.array([ 0.02669449,  
        0.10143885])
    lut.scalar_bar_representation.maximum_size = np.array([100000, 100000])
    

        