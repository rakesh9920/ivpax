%% setup parallel pool 

% try
%     if isempty(gcp)
%         parpool;
%     end
%     poolobj=gcp;
%     numofcores=poolobj.NumWorkers;
%     
%     disp([num2str(numofcores) ' cores detected.'])
% catch
%     if ~matlabpool('size')
%         matlabpool open
%     end
%     numofcores=matlabpool('size');
%     
%     disp([num2str(numofcores) ' cores detected.'])
% end


%% Material Properties 

membrane_E    = 110e9;   
membrane_v    = .22;
membrane_rho  = 2040;    

fluid_rho    = 1000;  
fluid_c      = 1500;  

  
mech_damping=1e5;         % mechanical loss. it is included in the BEM 
                        % formulation as a diagonal matrix
                   
%% Array geometry
clear membranes;

  
membranes{1}.center=[25e-6;25e-6];      %[x,y]
membranes{1}.width=[35e-6;35e-6];           %[x,y]
membranes{1}.thickness=2e-6;         
membranes{1}.meshnum=[21;21];               %number of nodes,[x,y]
 
   
membranes{2}=membranes{1};    
membranes{2}.center=membranes{1}.center+[45e-6;0];

membranes{3}=membranes{1};    
membranes{3}.center=membranes{1}.center+[0;45e-6];

membranes{4}=membranes{1};    
membranes{4}.center=membranes{1}.center+[45e-6;45e-6];

 
build_membranes;    % build the array

plot_array;         % visualize the array in xy plane


%% setup boundary element problem

%% construct K,B and M matrices and the node_x variable


K=[];
M=[];
node_x=[];
for ind=1:numel(membranes)
    K=blkdiag(K,membranes{ind}.K);
    M=blkdiag(M,membranes{ind}.M);
    node_x=[node_x; membranes{ind}.node_x];
end
B=mech_damping*eye(size(M));

%% construct R matrix

R=K-K;

% parfor ind=1:numel(K)
for ind=1:numel(K)
    [r_ind,c_ind]=ind2sub(size(K),ind);
    if r_ind>=c_ind
          R(ind)=norm(node_x(r_ind,:)-node_x(c_ind,:));
    end
end

for ind=1:size(K,1)
    R(ind,ind:end)=R(ind:end,ind);
end



%% construct Zr matrix

f=5e6;
w=2*pi*f;
k=w/fluid_c;

alpha=0.217*(f./1e6).^2;    %attenuation in water
% alpha=17*(f./1e6).^1.7;    %attenuation in oil

Zr=calc_Zr(fluid_rho,fluid_c,w,k,node_S,R,alpha);

%% Solve BEM for given pressure distribution

    P=zeros(size(node_x,1),1);

    P(membranes{1}.node_no)=1e6; % excite membrane 1 only with uniform pressure of 1MPa
%     P(membranes{2}.node_no)=0;    
%     P(membranes{3}.node_no)=0; 
%     P(membranes{4}.node_no)=0;    
                              
    G=-w^2*M + 1i*w*Zr + 1i*w*B + K;    
    
    U=G\P;
    
    
%% plot the displacement amplitude on the array surface

% amplitude plot

figure
  for mem_ind=1:numel(membranes)


            x_domain=reshape(membranes{mem_ind}.node_x(:,1),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

            y_domain=reshape(membranes{mem_ind}.node_x(:,2),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

            membrane_U=reshape(U(membranes{mem_ind}.node_no),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

          surf(x_domain,y_domain,abs(membrane_U))
         hold on
    end
    hold off
    grid on 
    zlabel('nm')
    title(['f=' num2str(f/1e6) ' MHz'])
      axis tight
    set(gca,'fontsize',16)
    ylabel('y')
%     plot_aspect_ratio=get(gca,'DataAspectRatio');
%     set(gca,'DataAspectRatio',[plot_aspect_ratio(1) plot_aspect_ratio(1) plot_aspect_ratio(3)]);
    zlim([-max(abs(U)) max(abs(U))])
    view(30,60)
    
  

%%
% time animation
figure
for t=linspace(0,2/f,40)

    for mem_ind=1:numel(membranes)


            x_domain=reshape(membranes{mem_ind}.node_x(:,1),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

            y_domain=reshape(membranes{mem_ind}.node_x(:,2),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

            membrane_U=reshape(U(membranes{mem_ind}.node_no),numel(unique(membranes{mem_ind}.node_x(:,2))) ...
                ,numel(unique(membranes{mem_ind}.node_x(:,1))));

          surf(x_domain,y_domain,real(membrane_U*exp(j*w*t)))
         hold on
    end
    hold off
    grid on 
    zlabel('nm')
    title(['f=' num2str(f/1e6) ' MHz'])
      axis tight
    set(gca,'fontsize',16)
    if ~t
    plot_aspect_ratio=get(gca,'DataAspectRatio');
    end
    set(gca,'DataAspectRatio',[plot_aspect_ratio(1) plot_aspect_ratio(1) plot_aspect_ratio(3)]);
    zlim([-max(abs(U)) max(abs(U))])
    view(30,60)
    
    pause(1/20)
    
end

%%

filename = './bem_vars.mat';
save(filename, 'K', 'node_x', 'M', 'B', 'membranes', 'fluid_c', 'fluid_rho', 'w', ...
    'dx', 'dy', 'P', 'U', 'Zr');



        