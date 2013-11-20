function [Mat] = loadmat(filename)

MatStruct = load(filename);
fields = fieldnames(MatStruct);
Mat = MatStruct.(fields{1});

end

