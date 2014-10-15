# mlfmm / operators.py

import numpy as np
import matplotlib.pyplot as plt
import weakref
from mlfmm.fasttransforms import *
from mlfmm.quadtree2 import QuadTree

class CachedOperator:
    '''
    '''
    def __init__(self):
        
        self.params = dict.fromkeys(['wave_number', 'density', 'sound_speed', 
            'node_area', 'nodes', 'origin', 'box_dims', 'min_level', 
            'max_level'])
        self.quadtree = None
        #self.translators = dict()
        self.shifters = dict()
        self.leveldata = dict()
    
    def setup(self, verbose=True):
        '''
        Initialize operator and setup quadrature rules for each level.
        '''
        prms = self.params
        k = prms['wave_number']
        nodes = prms['nodes']
        origin = prms['origin']
        box_dims = prms['box_dims']
        min_level = prms['min_level']
        max_level = prms['max_level']
        
        leveldata = self.leveldata
        
        # create and initialize quadtree
        qt = QuadTree(nodes, origin, box_dims)
        qt.setup(min_level, max_level)
        self.quadtree = qt
        
        # compute far-field angles for each level
        for l, lvl in qt.levels.iteritems():
            
            D = np.max(box_dims/(2**l))
            v = np.sqrt(3)*D*k
            C = 2/1.6
        
            order = np.int(np.ceil(v + C*np.log(v + np.pi)))
            stab_cond = 0.15*v/np.log(v + np.pi)
            
            #kdir, weights, thetaweights, phiweights = legquadrule(order)
            kdir, weights, thetaweights, phiweights = fftquadrule(order)
            kcoord = dir2coord(kdir)
            
            leveldata[l] = dict()
            leveldata[l]['kdir'] = kdir
            leveldata[l]['kcoord'] = kcoord
            leveldata[l]['weights'] = weights
            leveldata[l]['thetaweights'] = thetaweights
            leveldata[l]['phiweights'] = phiweights
            leveldata[l]['order'] = order
            leveldata[l]['stability_condition_no'] = stab_cond
            leveldata[l]['stable'] = stab_cond > C
            leveldata[l]['group_dims'] = box_dims/(2**l)
            
            if verbose:
                print ('Level %d, order %d, stability number %s, stable? %s' % 
                    (l, order, stab_cond, stab_cond > C))
    
    def precompute(self):
        '''
        Precompute translators and shifters.
        '''
        qt = self.quadtree
        #translators = self.translators
        shifters = self.shifters
        leveldata = self.leveldata
        prms = self.params
        k = prms['wave_number']
        
        # precompute translators operators for each level
        for l, lvl in qt.levels.iteritems(): 
            
            translators = dict()
            
            kcoord = leveldata[l]['kcoord']
            kcoordT = np.transpose(kcoord, (0, 2, 1))
            order = leveldata[l]['order']
            
            for group in lvl.itervalues():
                
                group.translators = []
                
                for neighbor in group.ntnn:
                    
                    r = group.center - neighbor().center
                    rmag = mag(r)
                    rhat = r/rmag
                    cos_angle = rhat.dot(kcoordT)
                    
                    trans = np.zeros_like(kcoord[:,:,0], dtype='complex')
                    
                    for theta in xrange(kcoord.shape[0]):
                        for phi in xrange(kcoord.shape[1]):
                            
                            ca = cos_angle[theta, phi]
                            
                            key = (round(float(rmag), 5), round(float(ca), 5))
                            if key in translators:
                                
                                value = translators[key]
                                
                            else:
                                
                                value = m2lop(rmag, ca, k, order + 1)
                                translators[key] = value
                            
                            trans[theta, phi] = value
                    
                    group.translators.append(trans)
            
            del translators 
                                
        # precompute shifters for each level
        for l, lvl in qt.levels.iteritems():
            
            kcoord = leveldata[l]['kcoord']
            kcoordT = np.transpose(kcoord, (0, 2, 1))
            
            group_dims = leveldata[l]['group_dims']
            r = mag(group_dims)/2
            
            # define direction unit vectors for the four quadrants
            rhat_ul = np.array([1, -1, 0])/np.sqrt(2) # upper left group
            rhat_ur = np.array([-1, -1, 0])/np.sqrt(2) # upper right group
            rhat_ll = np.array([1, 1, 0])/np.sqrt(2) # lower left group
            rhat_lr = np.array([-1, 1, 0])/np.sqrt(2) # lower right group
            
            # calculate shifters from magnitude and angle
            shift_ul = m2m(r, rhat_ul.dot(kcoordT), k)
            shift_ur = m2m(r, rhat_ur.dot(kcoordT), k)
            shift_ll = m2m(r, rhat_ll.dot(kcoordT), k)
            shift_lr = m2m(r, rhat_lr.dot(kcoordT), k)
            
            shifters[l] = dict()
            shifters[l][(0,0)] = shift_ll
            shifters[l][(1,0)] = shift_lr
            shifters[l][(0,1)] = shift_ul
            shifters[l][(1,1)] = shift_ur   
        
    def apply(self, u):
        '''
        Apply operator to input velocity vector to approximate the matrix-vector
        product.
        '''
        qt = self.quadtree
        prms = self.params
        leveldata = self.leveldata
        
        rho = prms['density']
        c = prms['sound_speed']
        k = prms['wave_number']
        s_n = prms['node_area']
        max_level = prms['max_level']
        min_level = prms['min_level']
        
        # calculate node source strength from velocity
        q = 1j*rho*c*k*s_n*u
        
        # calculate far-field coefficients for each group in max level
        maxl = qt.levels[max_level]
        
        kcoord = leveldata[max_level]['kcoord']
        weights = leveldata[max_level]['weights']
        
        for group in maxl.itervalues():
            
            sources = np.array(group.nodes.values())
            strengths = q[group.nodes.keys()]
            center = group.center
            
            group.coeffs = ffcoeff(strengths, sources, center, k, kcoord)
        
        # calculate local coefficients for group's non-touching nearest 
        # neighbors using far-to-local translators
        for group in maxl.itervalues():
            
            sum_coeffs = np.zeros_like(group.coeffs, dtype='complex')
            
            for n in xrange(len(group.ntnn)):
                
                neighbor = group.ntnn[n]
                sum_coeffs += group.translators[n]*(neighbor().coeffs)
            
            group.ntnn_coeffs = sum_coeffs
            
        # uptree pass
        self.uptree()
        
        # downwtree pass
        self.downtree()
        
        # calculate the total field at each node
        pressure = np.zeros_like(u, dtype='complex')
        
        # first, add pressure at each node due to far sources using fmm
        for group in maxl.itervalues():
            
            sources = np.array(group.nodes.values())
            center = group.center
            coeffs = group.aggr_coeffs
            
            pres = nfeval(coeffs, sources, center, weights, k, kcoord, rho, c)
            
            pressure[group.nodes.keys()] = pres
        
        # second, add pressure from neighboring groups using direct evaluation
        for group in maxl.itervalues():
            
            # create dictionary containing all node_ids and nodes from 
            # neighboring groups
            neighbor_nodes = dict()
            
            for neighbor in group.neighbors:
                neighbor_nodes.update(neighbor().nodes)
            
            # find their source strengths and evaluate the summed pressure 
            # contribution at each node in the group
            sources = np.array(neighbor_nodes.values())
            strengths = q[neighbor_nodes.keys()]
            fieldpos = np.array(group.nodes.values())
            
            pres = directeval(strengths, sources, fieldpos, k, rho, c)
            pressure[group.nodes.keys()] += pres
        
        # third, add pressure from nodes in the group using direct evaluation
        for group in maxl.itervalues():
            for node_id, node in group.nodes.iteritems():
                
                other_nodes = dict((key, val) for (key, val) in 
                    group.nodes.iteritems() if key != node_id)
                
                strengths = q[other_nodes.keys()]
                sources = np.array(other_nodes.values())
            
                pres = directeval(strengths, sources, node, k, rho, c)
                pressure[node_id] += pres[0]

        return pressure
        
    def uptree(self):
        '''
        '''
        qt = self.quadtree
        prms = self.params
        leveldata = self.leveldata
        shifters = self.shifters
        
        max_level = prms['max_level']
        min_level = prms['min_level']
        
        if max_level == min_level:
            return
            
        # shift-interpolate-sum far-field coefficients for each group in a level
        for l in xrange(max_level - 1, min_level - 1, -1):
            
            lvl = qt.levels[l]
            
            kdir = leveldata[l + 1]['kdir']
            phiweights = leveldata[l + 1]['phiweights']
            newkdir = leveldata[l]['kdir']
            
            for group in lvl.itervalues():
                
                sum_coeffs = np.zeros_like(newkdir[:,:,0], dtype='complex')
                
                for key, child in group.children.iteritems():
                    
                    #sum_coeffs += leginterpolate(shifters[l + 1][key]*
                        #(child().coeffs), phiweights, kdir, newkdir)
                    sum_coeffs += fftinterpolate(shifters[l + 1][key]*
                        (child().coeffs), kdir, newkdir)
                        
                group.coeffs = sum_coeffs
        
            # far to local translation for each group in a level
            for group in lvl.itervalues():
                
                sum_coeffs = np.zeros_like(group.coeffs, dtype='complex')
                
                for n in xrange(len(group.ntnn)):
                    
                    neighbor = group.ntnn[n]
                    sum_coeffs += group.translators[n]*(neighbor().coeffs)
                
                group.ntnn_coeffs = sum_coeffs
    
    def downtree(self):
        '''
        '''
        # grab necessary parameters and instance objects
        qt = self.quadtree
        prms = self.params
        leveldata = self.leveldata
        shifters = self.shifters
        
        max_level = prms['max_level']
        min_level = prms['min_level']
        
        # filter-shift ntnn coefficients for each group, passing coefficients 
        # to their children groups for aggregation
        
        # handle case of single level tree
        #if max_level == min_level:
        #    
        #    for group in qt.levels[max_level].itervalues():
        #        group.aggr_coeffs = group.ntnn_coeffs
                
        # seed top level aggregate coefficients with ntnn coefficients
        for group in qt.levels[min_level].itervalues():
            group.aggr_coeffs = group.ntnn_coeffs  
                
        for l in xrange(min_level, max_level):
            
            lvl = qt.levels[l]
            
            newkdir = leveldata[l + 1]['kdir']
            kdir = leveldata[l]['kdir']
            phiweights = leveldata[l]['phiweights']
  
            for group in lvl.itervalues():
                
                # calculate filtered coefficients
                #aggr_coeffs = legfilter(group.aggr_coeffs, phiweights, kdir, 
                    #newkdir)
                aggr_coeffs = fftfilter(group.aggr_coeffs, kdir, newkdir)
                
                # for each child group, shift filtered coefficients and add the 
                # child group's ntnn coefficients    
                for key, child in group.children.iteritems():
                    
                    # use conjugate of shifter to reverse its direction
                    child().aggr_coeffs = (np.conj(shifters[l + 1][key])*
                        aggr_coeffs + child().ntnn_coeffs) 
    
    def precompute_estimate(self, dps=5):
        
        qt = self.quadtree
        leveldata = self.leveldata
        prms = self.params
        k = prms['wave_number']
        
        translators = dict()
        
        for l, lvl in qt.levels.iteritems(): 
            
            kcoord = leveldata[l]['kcoord']
            kcoordT = np.transpose(kcoord, (0, 2, 1))
            order = leveldata[l]['order']
            
            for group in lvl.itervalues():
                
                #group.translators = []
                
                for neighbor in group.ntnn:
                    
                    r = group.center - neighbor().center
                    rmag = mag(r)
                    rhat = r/rmag
                    cos_angle = rhat.dot(kcoordT)
                    
                    #trans = np.zeros_like(kcoord[:,:,0], dtype='complex')
                    
                    for theta in xrange(kcoord.shape[0]):
                        for phi in xrange(kcoord.shape[1]):
                            
                            ca = cos_angle[theta, phi]
                            
                            key = (round(float(rmag), dps), round(float(ca), dps))
                            if key in translators:
                                
                                pass
                                
                            else:
                                
                                translators[key] = None
                            
                            #trans[theta, phi] = value
                    
                    #group.translators.append(trans)
            
            #del translators 
        
        return translators