%% plot array
hold on
axis equal
for mem_ind=1:numel(membranes)
    for ind=1:size(membranes{mem_ind}.node_x,1)
        
        dx=membranes{mem_ind}.dx;
        dy=membranes{mem_ind}.dy;
        
        x1=[-dx/2;-dy/2]+membranes{mem_ind}.node_x(ind,:)';
        x2=[-dx/2;dy/2]+membranes{mem_ind}.node_x(ind,:)';
        x3=[dx/2;dy/2]+membranes{mem_ind}.node_x(ind,:)';
        x4=[dx/2;-dy/2]+membranes{mem_ind}.node_x(ind,:)';
        
      
            fill([x1(1),x2(1),x3(1),x4(1)],[x1(2),x2(2),x3(2),x4(2)],[1 0 0])
        

    
    end
    
end
hold off
grid on 
axis tight
set(gca,'fontsize',16)


for mem_ind=1:numel(membranes)
 text(membranes{mem_ind}.center(1),membranes{mem_ind}.center(2),num2str(mem_ind),'color','w','fontsize',16)
end