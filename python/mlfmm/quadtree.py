# mlfmm / quadtree.py

import numpy as np
import matplotlib.pyplot as plt
import weakref

from mlfmm.transforms import *

class Group:
    '''
    '''
    def __init__(self, group_id, level_id, origin, dim):
        
        i, j = group_id
        xdim, ydim = dim
             
        #self.center = (origin[0] + xdim/(2**level_id)*(i + 0.5), 
        #    origin[1] + ydim/(2**level_id)*(j + 0.5))
        self.center = origin + np.array([xdim/(2**level_id)*(i + 0.5), 
            ydim/(2**level_id)*(j + 0.5), 0])
        self.group_id = np.array(group_id).astype(int)
        self.level_id = np.array(level_id).astype(int)
        self.nodes = None
        self.node_ids = None
        self.coeff =None
        self.children = []
        self.parent = None
        self.neighbors = []
        self.ntnn = []
        
    def __repr__(self):
        
        return 'Group %s, %s {level: %s}' % (self.group_id[0], 
            self.group_id[1], self.level_id)

    def add_child(self, child):
        self.children.append(weakref.ref(child))
    
    def spawn_parent(self, level, origin, dim):
        
        group_id = self.group_id
        parent_id = np.floor(group_id/2.0).astype(int)
        
        if not level.is_enabled(parent_id):
            
            parent = Group(parent_id, level.level_id, origin, dim)
            level.add_group(parent)
            
        else:
        
            parent = level.get_group(parent_id)
            
        parent.add_child(self)
        self.parent = weakref.ref(parent)
    
    def find_neighbors(self, level):
        
        i, j = self.group_id
        level_id = level.level_id
        
        istart = int(max(i - 1, 0))
        istop = int(min(i + 2, 2**level_id))
        jstart = int(max(j - 1, 0))
        jstop = int(min(j + 2, 2**level_id))
        
        neighbors = []
        
        for dx in xrange(istart, istop):
            for dy in xrange(jstart, jstop):
                if level.is_enabled((dx, dy)) and (dx, dy) != (i,j):
                    neighbors.append(weakref.ref(level.get_group((dx, dy))))
        
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
        
        if self.nodes is None:
            self.nodes = node.reshape((1,3))
        else:
            self.nodes = np.append(self.nodes, node.reshape((1,3)), axis=0)
        
        if self.node_ids is None:
            self.node_ids = np.array(node_id, ndmin=1)
        else:
            self.node_ids = np.append(self.node_ids, node_id)
        
        #return ntnn
    
        #def spawn_children(self, level, origin, dim):
        #
        #    group_id = self.group_id
        #    level_id = self.level_id
        #    
        #    child1 = Group((group_id[0]*2, group_id[1]*2), level_id + 1, 
        #        origin, dim)
        #    child2 = Group((group_id[0]*2 + 1, group_id[1]*2), level_id + 1, 
        #        origin, dim)
        #    child3 = Group((group_id[0]*2, group_id[1]*2 + 1), level_id + 1, 
        #        origin, dim)
        #    child4 = Group((group_id[0]*2 + 1, group_id[1]*2 + 1), level_id + 1, 
        #        origin, dim)
        #    
        #    self.children = [child1, child2, child3, child4]
        #    map(lambda x: x.set_parent(self), self.children)
        #    level.extend((child1, child2, child3, child4))

class Level:
    '''
    '''
    def __init__(self, lvl):
        
        self.level_id = lvl
        self.enabled = np.zeros((2**lvl, 2**lvl), dtype='bool')
        self.indices = np.zeros((2**lvl, 2**lvl), dtype='int')
        self.groups = []
        
    def __repr__(self):
        
        return 'Level %s {%s groups}' % (self.level_id, 
            len(self.groups))
        
    def is_enabled(self, group_id):
        
        i, j = group_id
        return self.enabled[i,j]
        
    def add_group(self, group):
        
        i, j = group.group_id
        self.groups.append(group)
        self.indices[i,j] = len(self.groups) - 1
        self.enabled[i,j] = True
        
    def get_group(self, group_id):
        
        i, j = group_id
        return self.groups[self.indices[i,j]]
    
class QuadTree:
    '''
    '''
    def __init__(self, nodes, origin, dim):
        
        self.nodes = nodes
        #self.group_ids = np.zeros((nodes.shape[0], 2), dtype='int')
        self.origin = np.array(origin, dtype='float').reshape(3)
        self.dim = np.array(dim, dtype='float').reshape(2)
        self.levels = []
        self.group_ids = None
                       
    def populate_tree(self, maxlevel, nlevel):

        origin = self.origin
        dim = self.dim
        group_ids = self.group_ids
        nodes = self.nodes
        
        self.levels = []
        
        # create "leaf" groups that are non-empty
        indices_tup = [tuple(row) for row in group_ids]
        uniq = np.unique(indices_tup)
        
        leaves = Level(maxlevel)
        
        for idx in uniq:
            
            leaves.add_group(Group(idx, leaves.level_id, origin, dim))
        
        # assign nodes to their corresponding leaves
        for n in xrange(nodes.shape[0]):
            
            leaf = leaves.get_group(group_ids[n,:])
            leaf.add_node(nodes[n,:], n)
        
        self.levels.append(leaves)
        
        # populate parent levels up to the desired level
        for n in xrange(1, nlevel):
            
            parent_level = Level(maxlevel - n)
            
            for g in self.levels[n - 1].groups:
                g.spawn_parent(parent_level, origin, dim)
            
            self.levels.append(parent_level)
        
        # populate neighbors for all levels 
        for l in self.levels:
            for g in l.groups:
                g.find_neighbors(l)
        
        # populate ntnn for all levels except the lowest level
        for l in self.levels[:-1]:
            for g in l.groups:
                g.find_ntnn()
        
    def assign_nodes(self, maxlevel):
        
        self.group_ids = np.floor((self.nodes[:,:2] - self.origin[None,:2])/ \
            (self.dim[None,:]*2**(-maxlevel))).astype(int)    
    

class Operator:
    '''
    '''
    def __init__(self, quadtree):
        
        self.quadtree = quadtree
        self.k = None
        self.rho = None
        self.c = None
        self.s_n = None
        self.order = None
    
    def calculate_mpole_coeff(self, q, k, rho, c, order):
        
        qt = self.quadtree
        
        # calculate multipole coefficients for all leaf groups
        leaves = qt.levels[0]
        
        for g in leaves.groups:
            
            idx = g.node_ids
            points = g.nodes
            center = g.center
            
            coeff = mpole_coeff(q[idx], points, center, k, rho, c, order)
            
            g.coeff = coeff
        
        # for remaining levels, translate and sum multipole coefficients from
        # lower level
        for lvl in qt.levels[1:]:     
            for group in lvl.groups:
                
                new_coeff = np.zeros(coeff.size, dtype='cfloat')
                new_center = group.center
                
                for child in group.children:
                    
                    new_coeff += m2m(child().coeff, child().center, new_center, 
                        k)
                
                group.coeff = new_coeff
    
    def calculate_pressure(self, node_id, q, k, rho, c):
        
        qt = self.quadtree
        s_n = self.s_n
        leaves = qt.levels[0]
        idx = qt.group_ids[node_id]
        pos = qt.nodes[node_id,:]
        
        top_group = leaves.get_group(idx)
        pres = 0j
        
        # add self-pressure
        pres += calc_self_pressure(q[node_id], s_n, k, rho, c)
        
        # add exact pressures from nodes in the target group
        # mask out target node
        mask = top_group.node_ids != node_id
        strengths = q[top_group.node_ids[mask]]
        
        if strengths.size > 0:
            pres += calc_pressure_exact(strengths, pos, top_group.nodes[mask,:],
                k, rho, c)
        
        ## add exact pressure from nodes in neighboring groups
        for group in top_group.neighbors:
            
            node_ids = group().node_ids
            nodes = group().nodes
            
            strengths = q[node_ids]
            
            pres += calc_pressure_exact(strengths, pos, nodes, k, rho, 
                c)
                
        # add approx pressure from nodes in ntnn via multipole expansion
        for group in top_group.ntnn:
            
            pres += 2*mpole_eval(group().coeff, pos, group().center, k)
        
        # add approx pressure from nodes in ntnn for remaining levels
        for lvl in qt.levels[1:]:
        
            top_group = top_group.parent()
            
            for group in top_group.ntnn:
                
                pres += 2*mpole_eval(group().coeff, pos, group().center, k)
       
        return pres 
    
    def matvec(self, u):
        
        k = self.k
        rho = self.rho
        c = self.c
        s_n = self.s_n
        order = self.order
        
        q = 1j*k*c*s_n*u
        
        self.calculate_mpole_coeff(q, k, rho, c, order)
        
        pres = np.zeros_like(u, dtype='cfloat')
        
        for i in xrange(q.size):
               
            pres[i] = self.calculate_pressure(i, q, k, rho, c)[0]
            print i
        
        return pres
                
                
            
            
            
            
        
        
    
                        

        
        
        
        