function [meta] = loadmeta(file)

data = load(file, 'meta');
meta = data.meta;
end