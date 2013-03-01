function [] = upictest()

% upicmsg('hello world');
% upicstatus('testing');
% upicstatus(1);
% upicstatus('testing');
% upicstatus(0);
% % 
bar = upicbar('upictest');
%%


for i = 1:1000
    
    upicbar(bar, i/1000);
    pause(0.01);
end
% 
% fprintf(repmat(sprintf(' '), 1, 20));
% drawnow('update');
% fprintf(repmat(sprintf('\b'), 1, 20));
% fprintf('asdf');
% drawnow('update');

% 
% test1();
% %%
% test2();