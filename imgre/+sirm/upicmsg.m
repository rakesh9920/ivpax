function [] = upicmsg(msg)

assert(isa(msg, 'char'), 'message must be of type char');

fprintf(msg); 
fprintf('\n');
drawnow('update');

end

