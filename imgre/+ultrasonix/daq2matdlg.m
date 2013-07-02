function [] = daq2matdlg(varargin)

import ultrasonix.daq2mat

inDir = uigetdir('', 'Select input directory');
outDir = uigetdir('', 'Select output directory');

daq2mat(inDir, outDir, varargin);

end

