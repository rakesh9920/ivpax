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
             
        self.center = np.array(origin).reshape(3) + np.array([xdim/(2**lvl)*(i + 
            0.5), ydim/(2**lvl)*(j + 0.5), 0])
        
        if isinstance(group_id, np.ndarray):
            self.group_id = tuple(group_id.ravel())
        else:
            self.group_id = group_id
        self.children = []
        self.parent = None
        self.neighbors = []
        self.ntnn = []
        self.nodes = dict()
        
    def __repr__(self):
        
        return 'Group %s, %s {level: %s}' % (self.group_id[1], 
            self.group_id[2], self.group_id[0])

    def add_child(self, child):
        self.children.append(weakref.ref(child))
    
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
        
        for dx in xrange(istart, istop):
            for dy in xrange(jstart, jstop):
                if qt.is_member((lvl, dx, dy)):
                    neighbors.append(weakref.ref(qt.get_member((lvl, dx, dy))))
        
        self.neighbors = neighbors
    
    def find_ntnn(self):
        
        parent = self.parent
        
        if parent is None:
            return
            
        ntnn = []
        
        for n in parent().neighbors:
            ntnn.extend([x for x in n().children if x not in self.neighbors])

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
        unique_ids = np.unique(group_ids_tup)
        
        for group_id in unique_ids:
            self.add_member(Group(group_id, origin, dim))
            
        # add nodes to groups in finest level
        for n in xrange(nodes.shape[0]):
            
            group = self.get_member(tuple(group_ids[n,:].ravel()))
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
        #for lvl in xrange(maxlevel, minlevel, -1):
        #    for group in levels[lvl].itervalues():
        #        group.find_ntnn()
          
    def assign_nodes(self, maxlevel):
        
        ids = np.floor((self.nodes[:,:2] - self.origin[None,:2])/ \
            (self.dim[None,:]*2**(-maxlevel))).astype(int) 
        
        self.group_ids = np.insert(ids, 0, 
            maxlevel*np.ones(self.nodes.shape[0]), axis=1)   
    
class Operator:
    
    def __init__(self):
        
        self.translators = dict()
        pass
    
    def setup(self):
        
        # create quadtree
        # precompute translation operators for each level
        # precompute shift operators for each level
        pass
        
    def apply(self):
        
        # calculate far-field coefficients for each group in max level
        # far to local translation for each group in max level
        # uptree pass
        # downwtree pass
        # calculate the total field at each node
        pass
        
    def uptree(self):
        
        # shift-interpolate-sum far-field coefficients for each group in a level
        # far to local translation for each group in a level
        pass
    
    def downtree(self):
        
        # shift-filter-sum far-field coefficients for each group in a level
        pass
    
    

            
        
        
    
                        

        
        
        
        