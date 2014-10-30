
              


node_S=[];



for ind=1:numel(membranes)
    
    membranes{ind}.electrode_width=membranes{1}.width;
    membranes{ind}.angle=0;         
    
    membrane_x=membranes{ind}.width(1);
    membrane_y=membranes{ind}.width(2);
    NodesX=membranes{ind}.meshnum(1);
    NodesY=membranes{ind}.meshnum(2);
    
       
    x=linspace(-membrane_x/2,membrane_x/2,NodesX)';
    y=linspace(-membrane_y/2,membrane_y/2,NodesY)';
    membranes{ind}.dx=x(2)-x(1);
    membranes{ind}.dy=y(2)-y(1);
    [x,y]=meshgrid(x,y);
    myinds=find(abs(x)==membrane_x/2 | abs(y)==membrane_y/2);
    x(myinds)=[];
    y(myinds)=[];

    membranes{ind}.node_x=[x' y'];

    membranes{ind}.numofnodes=size(membranes{ind}.node_x,1);
    
       
    D=membrane_E*membranes{ind}.thickness^3/12/(1-membrane_v^2);
    membranes{ind}.K=K_matrix_with_FD(membranes{ind}, D, membranes{ind}.dx, membranes{ind}.dy);
    
    membranes{ind}.M=membrane_rho*membranes{ind}.thickness*eye(size(membranes{ind}.K));
     
    
     
   
    mem_angle=membranes{ind}.angle;
    rotation_matrix=[cos(mem_angle) -sin(mem_angle);sin(mem_angle) cos(mem_angle)];
    
    for ind2=1:size(membranes{ind}.node_x,1)
        membranes{ind}.node_x(ind2,:)=(rotation_matrix*membranes{ind}.node_x(ind2,:)')';
    end
    
    
    membranes{ind}.node_x(:,1)=membranes{ind}.node_x(:,1)+membranes{ind}.center(1);
    membranes{ind}.node_x(:,2)=membranes{ind}.node_x(:,2)+membranes{ind}.center(2);
    
  
   
         membranes{ind}.node_no=size(node_S,1)+1:size(membranes{ind}.node_x,1)+size(node_S,1);

    
    node_S=[node_S; zeros(membranes{ind}.numofnodes,1)+membranes{ind}.dx*membranes{ind}.dy];
    

end