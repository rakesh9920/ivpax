function mcset(c1,c2,c3)

mc = gpib('ni', 0, 1);

 fopen(mc);


% fprintf(mc,'2TP?');
% myans=str2double(fscanf(mc));
%     
    
     fprintf(mc,['1PA' num2str(c1)]);
%      fprintf(mc,'\r');  %return carriage
     fprintf(mc,['2PA' num2str(c2)]);
     fprintf(mc,'\r');  %return carriage
%      pause(0.05)
     fprintf(mc,['3PA' num2str(c3)]);
     fprintf(mc,'\r');
     pause(0.05);
fclose(mc)