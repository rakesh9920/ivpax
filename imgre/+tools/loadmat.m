function [Mat] = loadmat(filename)

MatStruct = load(filename);
fields = fieldnames(ScattMat);
Mat = MatStruct.(fields{1});

end

