%stiffness matrix for one membrane

function K=K_matrix_with_FD_last(Nodes, D,dx,dy)

Nodes.x=Nodes.node_x(:,1);
Nodes.y=Nodes.node_x(:,2);


K=zeros(numel(Nodes.x),numel(Nodes.x));


for ind=1:numel(Nodes.x)
    
 
                 K(ind,ind)=6/dx^4+6/dy^4;
        
                
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)))<eps))=1/dx^4;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)))<eps))=-4/dx^4;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)))<eps))=-4/dx^4;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)))<eps))=1/dx^4;
       
        K(ind,find(abs(Nodes.y-(Nodes.y(ind)+2*dy))<eps & abs(Nodes.x-(Nodes.x(ind)))<eps))=1/dy^4;
        K(ind,find(abs(Nodes.y-(Nodes.y(ind)+1*dy))<eps & abs(Nodes.x-(Nodes.x(ind)))<eps))=-4/dy^4;
        K(ind,find(abs(Nodes.y-(Nodes.y(ind)-1*dy))<eps & abs(Nodes.x-(Nodes.x(ind)))<eps))=-4/dy^4;
        K(ind,find(abs(Nodes.y-(Nodes.y(ind)-2*dy))<eps & abs(Nodes.x-(Nodes.x(ind)))<eps))=1/dy^4;
        
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+1*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-1*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+1*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-1*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+2*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-2*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-2*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+2*dy))<eps))=2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+1*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-1*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-1*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+2*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+1*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+2*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-2*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)-1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)-2*dy))<eps))=-2/9/dx^2/dy^2;
        K(ind,find(abs(Nodes.x-(Nodes.x(ind)+1*dx))<eps & abs(Nodes.y-(Nodes.y(ind)+2*dy))<eps))=-2/9/dx^2/dy^2;
        
end
    

K=D*K;

%remove boundary nodes
%  K(Nodes.boundary_nodes,:)=[];
%  K(:,Nodes.boundary_nodes)=[];

 

 