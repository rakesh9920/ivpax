%% scope get data
function [t,data]=scopesave(chan)


scope = gpib('ni', 0, 7);
 set(scope,'InputBufferSize',10000);

try

    fopen(scope);

     
    
    
    fprintf(scope, 'Data:Encdg SRPbinary');
    fprintf(scope, 'Data:Width 8');
    
    
    
    %%
  
mychannel=['CH' num2str(chan)];

fprintf(scope, 'HOR:RECO?');
num_of_pts=str2num(fscanf(scope));


fprintf(scope, ['Data:Source ' mychannel]);


num_of_iters=floor(num_of_pts/4999);
remainings=mod(num_of_pts,4999);
data=zeros(num_of_pts,1);
cur_stop=0;

for ind=1:num_of_iters
    
    fprintf(scope, ['Data:Start ' num2str(cur_stop+1)]);
    fprintf(scope, ['Data:Stop ' num2str(cur_stop+4999)]);  
    fprintf(scope, 'Curve?');
    trash = fread(scope, 6, 'int8');
    data(cur_stop+1:cur_stop+4999,1) = fread(scope, 4999, 'uint16');
    trash = fread(scope, 1, 'int8');
    
    cur_stop=cur_stop+4999;
    
end



if remainings>10

    fprintf(scope, ['Data:Start ' num2str(cur_stop+1)]);
    fprintf(scope, ['Data:Stop ' num2str(cur_stop+remainings)]);  
    fprintf(scope, 'Curve?');
    trash = fread(scope, 6, 'int8');
    data(cur_stop+1:cur_stop+remainings,1) = fread(scope, remainings, 'uint16');
    trash = fread(scope, 1, 'int8');
    


end



fprintf(scope, 'WFMPre:YMult?')
ymult = fscanf(scope, '%%g');
fprintf(scope, 'WFMPre:YOff?')
yoff = fscanf(scope, '%%g');
fprintf(scope, 'WFMPre:YZEro?')
yzero = fscanf(scope, '%%g');
yoff=str2num(yoff);
yzero=str2num(yzero);
ymult=str2num(ymult);
data = (data - yoff) * ymult + yzero;

fprintf(scope, 'WFMP:XIN?');
samplingrate=1/str2num( fscanf(scope));

t=(0:size(data)-1)'/samplingrate;


    fclose(scope);

catch
    t=0;
     fclose(scope);
end