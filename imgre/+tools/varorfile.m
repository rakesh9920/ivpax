function [var] = varorfile(inPath, func)
% Determines if input is a variable or a file path (or prompt if empty). If
% input is a file path, applies the function to the file path and returns
% the output.  If input is a variable, the variable is passed directly to
% the output without change.

if isa(inPath, 'char')
    
    if inPath(end) == '/'
        inPath(end) = [];
    end
    
    var = func(inPath);
elseif isempty(inPath)
    
    [inFile, inDir] = uigetfile('', 'select a file');
    var = func(strcat(inDir, inFile));
else
    
    var = inPath;
end


end

