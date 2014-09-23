# mlfmm / quadtree.py

import numpy as np
import matplotlib.pyplot as plt
import weakref
from mlfmm.fasttransforms import *

class Group:
    '''
    '''
    def __init__(self, group_id, origin, dim):
        
        lvl, i, j = group_id
        xdim, ydim = dim
        
        self.group_dims = np.array([xdim/(2**lvl), ydim/(2**lvl)])
            
        self.center = np.array(origin).reshape(3) + np.array([xdim/(2**lvl)*(i + 
            0.5), ydim/(2**lvl)*(j + 0.5), 0])
        
        if isinstance(group_id, np.ndarray):
            self.group_id = tuple(group_id.ravel())
        else:
            self.group_id = group_id
        self.children = dict()
        self.parent = None
        self.neighbors = [] 
        self.ntnn = []
        self.nodes = dict()
        
    def __repr__(self):
        
        return 'Group %d, %d {level: %d}' % (self.group_id[1], 
            self.group_id[2], self.group_id[0])

    def add_child(self, child):
        
        lvl, i, j = child.group_id
        
        self.children[(i % 2, j % 2)] = weakref.ref(child)
    
    def spawn_parent(self, qt):
        
        lvl, i, j = self.group_id
        
        parent_id = (lvl - 1, np.floor(i/2.0), np.floor(j/2.0))
        
        if not qt.is_member(parent_id):
            parent = Group(parent_id, qt.origin, qt.dim)
            qt.add_member(parent)
        
        parent = qt.get_member(parent_id)
        parent.add_child(self)

        self.parent = weakref.ref(parent)
        
    def find_neighbors(self, qt):
        
        lvl, i, j = self.group_id
        
        istart = int(max(i - 1, 0))
        istop = int(min(i + 2, 2**lvl))
        jstart = int(max(j - 1, 0))
        jstop = int(min(j + 2, 2**lvl))
        
        neighbors = []
        #idx = 0
        
        for dx in xrange(istart, istop):
            for dy in xrange(jstart, jstop):
                
                if qt.is_member((lvl, dx, dy)) and (lvl, dx, dy) != (lvl, i, j):
                    neighbors.append(weakref.ref(qt.get_member((lvl, dx, dy))))
                    #neighbors[idx] = weakref.ref(qt.get_member((lvl, dx, dy)))
                
                #idx += 1
                    
        self.neighbors = neighbors
    
    def find_ntnn(self):
        
        parent = self.parent
        
        if parent is None:
            return
            
        ntnn = []
        
        for n in parent().neighbors:
            ntnn.extend([x for x in n().children.itervalues() if x not in 
                self.neighbors])

        self.ntnn = ntnn
    
    def add_node(self, node, node_id):
        
        self.nodes[node_id] = node

class QuadTree:
    '''
    '''
    def __init__(self, nodes, origin, dim):
        
        self.nodes = np.array(nodes)
        self.group_ids = None
        self.origin = np.array(origin, dtype='float').reshape(3)
        self.dim = np.array(dim, dtype='float').reshape(2)
        self.levels = dict()
    
    #def __repr__(self):
    #    pass
    
    def add_level(self, lvl):
        
        self.levels[lvl] = dict()
        
    def is_member(self, group_id):
        
        lvl, i, j = group_id
        return (lvl, i, j) in self.levels[lvl]
        
    def get_member(self, group_id):
        
        if self.is_member(group_id):
            return self.levels[group_id[0]][group_id]
        else:
            return None
            
    def add_member(self, group):
        
        group_id = group.group_id
        self.levels[group_id[0]][group_id] = group
 
    def setup(self, minlevel, maxlevel):
        
        origin = self.origin
        dim = self.dim
        nodes = self.nodes
        levels = self.levels
        
        # create empty levels
        for lvl in xrange(minlevel, maxlevel + 1):
            self.add_level(lvl)
        
        # populate finest level
        self.assign_nodes(maxlevel)
        group_ids = self.group_ids
        group_ids_tup = [tuple(row) for row in group_ids]
        unique_ids = set(group_ids_tup)
        
        for group_id in unique_ids:
            self.add_member(Group(group_id, origin, dim))
            
        for n in xrange(nodes.shape[0]):
            
            group = self.get_member(group_ids[n])
            group.add_node(nodes[n,:], n)
        
        # populate remaining levels
        for lvl in xrange(maxlevel, minlevel, -1):
            for group in levels[lvl].itervalues():
                group.spawn_parent(self)
        
        # populate neighbor lists
        for lvl in levels.itervalues():
            for group in lvl.itervalues():
                group.find_neighbors(self)
        
        # populate ntnn lists
        for lvl in levels.itervalues():
            for group in lvl.itervalues():
                group.find_ntnn()
          
    def assign_nodes(self, maxlevel):
        
        ids = np.floor((self.nodes[:,:2] - self.origin[None,:2])/ \
            (self.dim[None,:]*2**(-maxlevel))).astype(int) 
            
        group_ids = np.insert(ids, 0, maxlevel*np.ones(ids.shape[0]), axis=1)   

        self.group_ids = [tuple(row) for row in group_ids]
        
class Operator:
    '''
    '''
    def __init__(self):
        
        #self.translators = dict()
        self.params = dict.fromkeys(['wave_number', 'density', 'sound_speed', 
            'node_area', 'nodes', 'origin', 'box_dims', 'min_level', 
            'max_level'])
        self.qt = None
        self.levelinfo = None
    
    def setup(self):
        '''
        Initialize operator and precompute translators and shifters.
        '''
        prms = self.params
        k = prms['wave_number']
        
        # create and initialize quadtree
        qt = QuadTree(prms['nodes'], prms['origin'], prms['box_dims'])
        qt.setup(prms['min_level'], prms['max_level'])
        self.qt = qt
        #self.levelinfo = dict.fromkeys(range(prms['max_level'] + 1), None)
        self.levelinfo = dict()
        
        # compute far-field angles for each level
        for l, lvl in qt.levels.iteritems():
            
            xdim, ydim = prms['box_dims']
            min_level = prms['min_level']
            D = max(xdim/(2**min_level), ydim/(2**min_level))
            #D = max(xdim/(2**l), ydim/(2**l))

            order = np.int(np.ceil(k*D + 5/1.6*np.log(k*D + np.pi)))
            
            kdir, weights, thetaweights, phiweights = quadrule2(2*order + 1)
            kcoord = dir2coord(kdir)
            
            self.levelinfo[l] = dict()
            self.levelinfo[l]['kdir'] = kdir
            self.levelinfo[l]['kcoord'] = kcoord
            self.levelinfo[l]['weights'] = weights
            self.levelinfo[l]['thetaweights'] = thetaweights
            self.levelinfo[l]['phiweights'] = phiweights
            self.levelinfo[l]['order'] = order
            self.levelinfo[l]['group_dims'] = np.array([xdim/(2**l), 
                ydim/(2**l)])
        
        # precompute translation operators for each level
        for l, lvl in qt.levels.iteritems(): 
            
            kcoord = self.levelinfo[l]['kcoord']
            kcoordT = np.transpose(kcoord, (0, 2, 1))
            order = self.levelinfo[l]['order']
            
            for group in lvl.itervalues():
                
                group.translators = []
                
                for neighbor in group.ntnn:
                    
                    r = group.center - neighbor().center
                    rhat = r/mag(r)
                    cos_angle = rhat.dot(kcoordT)
                    
                    group.translators.append(m2l(mag(r), cos_angle, k, 
                        order + 1))
        
        # precompute shifters for each level
        for l, lvl in qt.levels.iteritems():
            
            kcoord = self.levelinfo[l]['kcoord']
            kcoordT = np.transpose(kcoord, (0, 2, 1))
            
            group_dims = self.levelinfo[l]['group_dims']
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
            
            self.levelinfo[l]['shifters'] = dict()
            self.levelinfo[l]['shifters'][(0,0)] = shift_ll
            self.levelinfo[l]['shifters'][(1,0)] = shift_lr
            self.levelinfo[l]['shifters'][(0,1)] = shift_ul
            self.levelinfo[l]['shifters'][(1,1)] = shift_ur   
            
        # precompute interpolate/filter operators?
        
    def apply(self, u):
        '''
        Apply operator to input velocity vector to approximate the matrix-vector
        product.
        '''
        qt = self.qt
        prms = self.params
        
        rho = prms['density']
        c = prms['sound_speed']
        k = prms['wave_number']
        s_n = prms['node_area']
        max_level = prms['max_level']
        min_level = prms['min_level']
        weights = self.levelinfo[max_level]['weights']

        # calculate node source strength from velocity
        q = 1j*rho*c*k*s_n*u
        
        # calculate far-field coefficients for each group in max level
        maxl = qt.levels[max_level]
        kcoord = self.levelinfo[max_level]['kcoord']
        
        for group in maxl.itervalues():
            
            sources = np.array(group.nodes.values())
            strengths = q[group.nodes.keys()]
            center = group.center
            
            group.coeffs = ffcoeff(strengths, sources, center, k, kcoord)
        
        # calculate local coefficients for group's non-touching nearest 
        # neighbors using far-to-local translators
        for group in maxl.itervalues():
            
            sum_coeffs = np.zeros_like(group.coeffs)
            
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
            
            sources = np.array(neighbor_nodes.values())
            
            # find their source strengths and evaluate the summed pressure 
            # contribution at each node in the group
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
        qt = self.qt
        prms = self.params
        #k = prms['wave_number']
        max_level = prms['max_level']
        min_level = prms['min_level']
        
        # shift-interpolate-sum far-field coefficients for each group in a level
        for l in xrange(max_level - 1, min_level - 1, -1):
            
            lvl = qt.levels[l]
            shifters = self.levelinfo[l + 1]['shifters']
            kdir = self.levelinfo[l + 1]['kdir']
            newkdir = self.levelinfo[l]['kdir']
            phiweights = self.levelinfo[l + 1]['phiweights']
            
            for group in lvl.itervalues():
                
                sum_coeffs = np.zeros_like(newkdir[:,:,0], dtype='complex')
                
                for key, child in group.children.iteritems():
                    
                    #sum_coeffs += interpolate(shifters[key]*(child().coeffs), 
                    #    phiweights, kdir, newkdir)
                    sum_coeffs += shifters[key]*(child().coeffs)
                
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
        qt = self.qt
        prms = self.params
        max_level = prms['max_level']
        min_level = prms['min_level']
        
        # filter-shift ntnn coefficients for each group, passing coefficients 
        # to their children groups for aggregation
        for l in xrange(min_level, max_level):
            
            lvl = qt.levels[l]
            shifters = self.levelinfo[l + 1]['shifters']
            kdir = self.levelinfo[l]['kdir']
            newkdir = self.levelinfo[l + 1]['kdir']
            phiweights = self.levelinfo[l]['phiweights']

            # seed top level aggregate coefficients with ntnn coefficients
            if l == min_level:
                for group in lvl.itervalues():
                    group.aggr_coeffs = group.ntnn_coeffs
                    
            for group in lvl.itervalues():
                
                # calculate filtered coefficients
                #aggr_coeffs = filter(group.aggr_coeffs, phiweights, kdir, 
                #    newkdir)
                aggr_coeffs = group.aggr_coeffs
                
                # for each child group, shift filtered coefficients and add the 
                # child group's ntnn coefficients    
                for key, child in group.children.iteritems():
                    
                    # use conjugate of shifter to reverse its direction
                    child().aggr_coeffs = (np.conj(shifters[key])*aggr_coeffs +
                        child().ntnn_coeffs) 
            
    

            
        
        
    
                        

        
        
        
        