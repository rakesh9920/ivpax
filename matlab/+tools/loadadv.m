function [AdvMat] = loadadv(fileStr)
%

import tools.advdouble

fileStruct = load(fileStr);

data = fileStruct.data;
label = fileStruct.label;
meta = fileStruct.meta;

AdvMat = advdouble(data, label);
AdvMat.meta = meta;

end

