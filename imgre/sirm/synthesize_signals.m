%% Set global parameters %%

global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE

SOUND_SPEED = 1500; % [m/s]
SAMPLE_FREQUENCY = 40e6; % [Hz]
PULSE_REPITITION_RATE = 250; % [Hz]

% define runtime flags
global VERBOSE

[~, Freq] = qfft2(zeros(1,2048), SAMPLE_FREQUENCY);
Freq2S = [Freq(1:end-1) -Freq(end) -fliplr(Freq(2:(end-1)))];

%% Mesh transducers %%

[Tx1Mesh Tx1Area] = polarmesh([0 0.0011], [0 2*pi], 0.0000125);
[Rx1Mesh Rx1Area] = polarmesh([0.0011 0.0013], [0 pi/2], 0.0000125);
Rx2Mesh = polarmesh([0.0011 0.0013], [pi/2 pi], 0.0000125);
Rx3Mesh = polarmesh([0.0011 0.0013], [pi 3*pi/2], 0.0000125);
Rx4Mesh = polarmesh([0.0011 0.0013], [3*pi/2 2*pi], 0.0000125);

if (exist('VERBOSE', 'var'))
    figure;
    plot3(Tx1Mesh(1,:), Tx1Mesh(2,:), Tx1Mesh(3,:),'b.'); hold on;
    plot3(Rx1Mesh(1,:),Rx1Mesh(2,:),Rx1Mesh(3,:),'r.');
    plot3(Rx2Mesh(1,:),Rx2Mesh(2,:),Rx2Mesh(3,:),'g.');
    plot3(Rx3Mesh(1,:),Rx3Mesh(2,:),Rx3Mesh(3,:),'c.');
    plot3(Rx4Mesh(1,:),Rx4Mesh(2,:),Rx4Mesh(3,:),'k.');
end

%% Define flow field for moving scatterers %%

simulationTime = 1; % [s]

FlowInitialPos = [0; 0; 0.020];
FlowVelocity = [0; 0; 0.01];
FlowField = vfield(FlowInitialPos, FlowVelocity, PULSE_REPITITION_RATE, ...
    simulationTime);

if (exist('VERBOSE', 'var'))
    figure;
    quiver3(FlowInitialPos(1,:), FlowInitialPos(2,:), FlowInitialPos(3,:), ...
        FlowVelocity(1,:), FlowVelocity(2,:), FlowVelocity(3,:),'ro');
end

%% Generate speckle field %%

[SpeckleComplex, SpeckleNum] = scattergen(1e-6, [1000 1000 1000], [0 0.4], [0 2*pi]);

X = linspace(-0.002, 0.002, 1000);
Y = linspace(-0.002, 0.002, 1000);
Z = linspace(0, 0.03, 1000);

SpecklePos = [X(SpeckleNum(1,:)); Y(SpeckleNum(2,:)); Z(SpeckleNum(3,:))];
SpecklePhase = angle(SpeckleComplex);
SpeckleAmp = abs(SpeckleComplex).*0.01;

if (exist('VERBOSE', 'var'))
    figure;
    plot3(SpecklePos(1,:),SpecklePos(2,:),SpecklePos(3,:),'.');
end

%% Plot full geometry

if (exist('VERBOSE', 'var'))
   figure;
   plot3(SpecklePos(1,:),SpecklePos(2,:),SpecklePos(3,:),'.');
   hold on; xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
   quiver3(FlowInitialPos(1,:), FlowInitialPos(2,:), FlowInitialPos(3,:), ...
        FlowVelocity(1,:), FlowVelocity(2,:), FlowVelocity(3,:),0,'ro');
    plot3(Tx1Mesh(1,:), Tx1Mesh(2,:), Tx1Mesh(3,:),'b.');
    plot3(Rx1Mesh(1,:),Rx1Mesh(2,:),Rx1Mesh(3,:),'r.');
    plot3(Rx2Mesh(1,:),Rx2Mesh(2,:),Rx2Mesh(3,:),'g.');
    plot3(Rx3Mesh(1,:),Rx3Mesh(2,:),Rx3Mesh(3,:),'c.');
    plot3(Rx4Mesh(1,:),Rx4Mesh(2,:),Rx4Mesh(3,:),'k.');
end
%% Calculate spatial frequency responses for moving scatterers %%

FlowFieldPts = reshape(FlowField, 3, []);

% calculate and convert to 2-sided
FlowTx1Sfr = convert2sided(sfr(Tx1Mesh, FlowFieldPts, Freq, SOUND_SPEED, Tx1Area), 1);
FlowRx1Sfr = convert2sided(sfr(Rx1Mesh, FlowFieldPts, Freq, SOUND_SPEED, Rx1Area), 1);
FlowRx2Sfr = convert2sided(sfr(Rx2Mesh, FlowFieldPts, Freq, SOUND_SPEED, Rx1Area), 1);
FlowRx3Sfr = convert2sided(sfr(Rx3Mesh, FlowFieldPts, Freq, SOUND_SPEED, Rx1Area), 1);
FlowRx4Sfr = convert2sided(sfr(Rx4Mesh, FlowFieldPts, Freq, SOUND_SPEED, Rx1Area), 1);

if (exist('VERBOSE', 'var'))
    figure;
    plot(fftshift(Freq2s.*1e-6).', fftshift(abs(FlowTx1Sfr)), 'b');
    figure;
    plot(fftshift(Freq2s.*1e-6).', fftshift(abs(FlowRx1Sfr)), 'r:');
    hold on; xlabel('frequency [MHz]');
    plot(fftshift(Freq2s.*1e-6).', fftshift(abs(FlowRx2Sfr)), 'g:');
    plot(fftshift(Freq2s.*1e-6).', fftshift(abs(FlowRx3Sfr)), 'c:');
    plot(fftshift(Freq2s.*1e-6).', fftshift(abs(FlowRx4Sfr)), 'k:');
end

%% Calculate spatial frequency responses for speckle scatterers %%

SpeckleTx1Sfr = convert2sided(sfr(Tx1Mesh, SpecklePos, Freq, SOUND_SPEED, Tx1Area), 1);
SpeckleRx1Sfr = convert2sided(sfr(Rx1Mesh, SpecklePos, Freq, SOUND_SPEED, Rx1Area), 1);
SpeckleRx2Sfr = convert2sided(sfr(Rx2Mesh, SpecklePos, Freq, SOUND_SPEED, Rx1Area), 1);
SpeckleRx3Sfr = convert2sided(sfr(Rx3Mesh, SpecklePos, Freq, SOUND_SPEED, Rx1Area), 1);
SpeckleRx4Sfr = convert2sided(sfr(Rx4Mesh, SpecklePos, Freq, SOUND_SPEED, Rx1Area), 1);

if (exist('VERBOSE', 'var'))
    figure;
    plot(fftshift(Freq2S.*1e-6).', fftshift(abs(SpeckleTx1Sfr)), 'b');
    figure;
    plot(fftshift(Freq2S.*1e-6).', fftshift(abs(SpeckleRx1Sfr)), 'r:');
    hold on; xlabel('frequency [MHz]');
    plot(fftshift(Freq2S.*1e-6).', fftshift(abs(SpeckleRx2Sfr)), 'g:');
    plot(fftshift(Freq2S.*1e-6).', fftshift(abs(SpeckleRx3Sfr)), 'c:');
    plot(fftshift(Freq2S.*1e-6).', fftshift(abs(SpeckleRx4Sfr)), 'k:');
end


%% create pulse time signal and pulse spectrum

Opt.pulseType = 'gaussian';
Opt.timeDelay = 0.22e-5;
Opt.timeLength = 5.12e-5;
Opt.fbw = 0.50;
Opt.sampleFreq = 40e6;
Opt.centerFreq = 1e6;
PulseSig = waveformgen(Opt);
PulseSig(end) = [];
PulseSpect = fft(PulseSig).'; %

if (exist('VERBOSE', 'var'))
    figure; plot(PulseSig); xlabel('sample');
    figure; plot(fftshift(Freq2S).*1e-6, fftshift(abs(PulseSpect)));
    xlabel('frequency [MHz]');
end

clear Opt;
%% Synthesize receive signals %%

SpeckleTx1Complex = SpeckleTx1Sfr.*repmat(exp(-1i.*2.*pi.*SpecklePhase).*SpeckleAmp, ...
    size(SpeckleTx1Sfr, 1), 1);

% synthesize moving scatterer signals
FlowRx1Sig = ifft(bsxfun(@times ,PulseSpect, FlowTx1Sfr).*FlowRx1Sfr, 'symmetric');
FlowRx2Sig = ifft(bsxfun(@times, PulseSpect, FlowTx1Sfr).*FlowRx2Sfr, 'symmetric');
FlowRx3Sig = ifft(bsxfun(@times, PulseSpect, FlowTx1Sfr).*FlowRx3Sfr, 'symmetric');
FlowRx4Sig = ifft(bsxfun(@times, PulseSpect, FlowTx1Sfr).*FlowRx4Sfr, 'symmetric');

% synthesize speckle signals

SpeckleRx1Sig = ifft(sum(bsxfun(@times, PulseSpect, SpeckleTx1Complex).*SpeckleRx1Sfr, 2), 'symmetric');
SpeckleRx2Sig = ifft(sum(bsxfun(@times, PulseSpect, SpeckleTx1Complex).*SpeckleRx2Sfr, 2), 'symmetric');
SpeckleRx3Sig = ifft(sum(bsxfun(@times, PulseSpect, SpeckleTx1Complex).*SpeckleRx3Sfr, 2), 'symmetric');
SpeckleRx4Sig = ifft(sum(bsxfun(@times, PulseSpect, SpeckleTx1Complex).*SpeckleRx4Sfr, 2), 'symmetric');

% add flow and speckle
Rx1Sig = bsxfun(@plus, FlowRx1Sig, SpeckleRx1Sig);
Rx2Sig = bsxfun(@plus, FlowRx2Sig, SpeckleRx2Sig);
Rx3Sig = bsxfun(@plus, FlowRx3Sig, SpeckleRx3Sig);
Rx4Sig = bsxfun(@plus, FlowRx4Sig, SpeckleRx4Sig);

if (exist('VERBOSE', 'var'))
    figure; plot(Rx1Sig); xlabel('sample'); 
    figure; plot(Rx2Sig); xlabel('sample'); 
    figure; plot(Rx3Sig); xlabel('sample'); 
    figure; plot(Rx4Sig); xlabel('sample'); 
end

