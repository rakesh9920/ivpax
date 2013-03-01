function [] = upicstatus(status)

assert(isa(status, 'char') || isa(status, 'numeric'), 'status must be of type char or int');

if isa(status, 'char')
    fprintf(status);
    fprintf(',');
else
    switch status
        case 0
            fprintf(' failed.\n');
        case 1
            fprintf(' done.\n');
    end
end

drawnow('update');

end

