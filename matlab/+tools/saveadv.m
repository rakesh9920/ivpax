function [] = saveadv(fileStr, AdvMat)
% Saves an advdouble variable as separate parts.

data = double(AdvMat);
label = AdvMat.label;
dim = AdvMat.dim;
meta = AdvMat.meta;

save(fileStr, 'data', 'label' ,'dim', 'meta');

end

