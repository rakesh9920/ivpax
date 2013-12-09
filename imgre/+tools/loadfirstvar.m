function [Mat] = loadfirstvar(filename)

MatStruct = load(filename);
fields = fieldnames(MatStruct);
Mat = MatStruct.(fields{1});

end

