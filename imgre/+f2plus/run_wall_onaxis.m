function [] = run_wall_onaxis(rxDepth, sctFile, varargin)

import fieldii.field_init
import fieldii.calc_scat_multi
import fieldii.field_end
import fieldii.set_field
import fieldii.xdc_piston
import fieldii.xdc_impulse
import fieldii.xdc_excitation
import fieldii.xdc_focus_times
import fieldii.xdc_free
import f2plus.xdc_nphys
import f2plus.xdc_shift
import tools.loadmat
import tools.advdouble
addpath ./bin/Mat_field.mexw64
addpath ./bin/Mat_field.mexa64

if nargin > 2
    outDir = varargin{1};
    if outDir(end) ~= '/'
        outDir = strcat(outDir, '/');
    end
else
    pathstr = fileparts(sctFile);
    outDir = strcat(pathstr, '/');
end

% load sctFile and read meta data
ScatInfo = loadmat(sctFile);
fileNo = ScatInfo.Meta.fileNo;

outFile = strcat(outDir, 'rf_', sprintf('%0.4d', fileNo));

% run Field II
field_init(-1);

% Set Field II parameters

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 5e6;
att = 0; % 176 % in dB/m
freq_att = 0;
att_f0 = 5e6;

set_field('c', c);
set_field('fs', fs);
set_field('att', att);
set_field('freq_att', freq_att);
set_field('att_f0', att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:1000/f0));

% Define circular piston for transmit and receive

radius1 = 3/1000;
radius2 = 1/1000;
elementSize = 0.05/1000;
impScale = 1;
excScale = 1;

TxArray = xdc_piston(radius1, elementSize);
xdc_impulse(TxArray, impScale.*impulse_response);
xdc_excitation(TxArray, excScale.*excitation);
xdc_focus_times(TxArray, 0, zeros(1, xdc_nphys(TxArray)));

RxArray2 = xdc_piston(radius2, elementSize);
RxArray = xdc_shift(RxArray2, [0 0 R]);
xdc_impulse(RxArray, impScale.*impulse_response);
xdc_excitation(RxArray, excScale.*excitation);
xdc_focus_times(RxArray, 0, zeros(1, xdc_nphys(RxArray)));

xdc_free(RxArray2);

[RfMat, startTime] = calc_scat_multi(TxArray, RxArray, double(ScatInfo(:,1:3)), ...
    double(ScatInfo(:,4)));

field_end;

% write metadata and save output
RfMat = advdouble(RfMat, {'rf', 'scatterer'});
RfMat.Meta.fileNo = fileNo;
RfMat.Meta.startTime = startTime;
RfMat.Meta.rxDepth = rxDepth;

if nargout == 0
    save(outFile, 'RfMat');
end






end

