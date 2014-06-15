# mlfmm / quadtree.py

import numpy as np
import matplotlib.pyplot as plt
import weakref


class Group:
    
    def __init__(self, local_id, level_id, origin, dim):
        
        i, j = local_id
        xdim, ydim = dim
             
        self.center = (origin[0] + xdim/(2**level_id)*(i + 0.5), 
            origin[1] + ydim/(2**level_id)*(j + 0.5))
        self.local_id = np.int(local_id)
        self.level_id = np.int(level_id)
        self.nodes = []
        self.node_indices = []
        self.children = []
        
        #self.coeff = []
        #self.parent = None
        #self.neighbors = []
        #self.ntnn = []
        
    def __repr__(self):
        
        return 'Group %s, %s {level: %s}' % (self.local_id[0], 
            self.local_id[1], self.level_id)

    def add_child(self, child):
        self.children.append(weakref.ref(child))
    
    def spawn_parent(self, level, origin, dim):
        
        local_id = self.local_id
        parent_id = np.floor(local_id/2.0).astype(int)
        
        if not level.is_enabled(parent_id):
            
            parent = Group(parent_id, level.level_id, origin, dim)
            level.add_member(parent)
            
        else:
        
            parent = level.get_member(parent_id)
            
        parent.add_child(self)
        self.parent = weakref.ref(parent)
    
    def find_neighbors(self, level):
        
        i, j = self.local_id
        level_id = level.level_id
        
        istart = int(max(i - 1, 0))
        istop = int(min(i + 2, 2**level_id))
        jstart = int(max(j - 1, 0))
        jstop = int(min(j + 2, 2**level_id))
        
        neighbors = []
        
        for dx in xrange(istart, istop):
            for dy in xrange(jstart, jstop):
                if level.is_enabled((dx, dy)) and (dx, dy) != (i,j):
                    neighbors.append(weakref.ref(level.get_member((dx, dy))))
        
        self.neighbors = neighbors
    
    def find_ntnn(self):
        
        parent = self.parent
        
        if parent is None:
            return
            
        ntnn = []
        
        for n in parent().neighbors:
            ntnn.extend([x for x in n().children if x not in self.neighbors])
        
        self.ntnn = ntnn
    
        #return ntnn
    
        #def spawn_children(self, level, origin, dim):
        #
        #    local_id = self.local_id
        #    level_id = self.level_id
        #    
        #    child1 = Group((local_id[0]*2, local_id[1]*2), level_id + 1, 
        #        origin, dim)
        #    child2 = Group((local_id[0]*2 + 1, local_id[1]*2), level_id + 1, 
        #        origin, dim)
        #    child3 = Group((local_id[0]*2, local_id[1]*2 + 1), level_id + 1, 
        #        origin, dim)
        #    child4 = Group((local_id[0]*2 + 1, local_id[1]*2 + 1), level_id + 1, 
        #        origin, dim)
        #    
        #    self.children = [child1, child2, child3, child4]
        #    map(lambda x: x.set_parent(self), self.children)
        #    level.extend((child1, child2, child3, child4))

class Level:
    
    def __init__(self, lvl):
        
        self.level_id = lvl
        self.enabled = np.zeros((2**lvl, 2**lvl), dtype='bool')
        self.indices = np.zeros((2**lvl, 2**lvl), dtype='int')
        self.members = []
        
    def __repr__(self):
        
        return 'Level %s {%s members}' % (self.level_id, 
            len(self.members))
        
    def is_enabled(self, local_id):
        
        i, j = local_id
        return self.enabled[i,j]
        
    def add_member(self, group):
        
        i, j = group.local_id
        self.members.append(group)
        self.indices[i,j] = len(self.members) - 1
        self.enabled[i,j] = True
        
    def get_member(self, local_id):
        
        i, j = local_id
        return self.members[self.indices[i,j]]
    
class QuadTree:
    
    def __init__(self, nodes, origin, dim):
        
        self.nodes = nodes
        #self.node_indices = np.zeros((nodes.shape[0], 2), dtype='int')
        self.origin = np.array(origin, dtype='float').reshape(2)
        self.dim = np.array(dim, dtype='float').reshape(2)
        self.levels = []
                       
    def populate_tree(self, maxlevel, nlevel):

        origin = self.origin
        dim = self.dim
        node_indices = self.node_indices
        nodes = self.nodes
        
        self.levels = []
        
        # create "leaf" groups that are non-empty
        indices_tup = [tuple(row) for row in node_indices]
        uniq = np.unique(indices_tup)
        
        leaves = Level(maxlevel)
        
        for idx in uniq:
            
            leaves.add_member(Group(idx, leaves.level_id, origin, dim))
        
        # assign nodes to their corresponding leaves
        for n in xrange(nodes.shape[0]):
            
            leaf = leaves.get_member(node_indices[n,:])
            leaf.node_indices.append(n)
            leaf.nodes.append(nodes[n,:])
        
        self.levels.append(leaves)
        
        # populate parent levels up to the desired level
        for n in xrange(1, nlevel):
            
            parent_level = Level(maxlevel - n)
            
            for g in self.levels[n - 1].members:
                g.spawn_parent(parent_level, origin, dim)
            
            self.levels.append(parent_level)
        
        # populate neighbors for all levels 
        for l in self.levels:
            for g in l.members:
                g.find_neighbors(l)
        
    def assign_nodes(self, maxlevel):
        
        self.node_indices = np.floor((self.nodes - self.origin[None,:])/ \
            (self.dim[None,:]*2**(-maxlevel))).astype(int)    
                

        
        
        
        