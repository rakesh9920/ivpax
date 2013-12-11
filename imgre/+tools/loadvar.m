function [var] = loadvar(file, varname)

data = load(file, varname);
var = data.(varname);
end