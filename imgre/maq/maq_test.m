seqprms = daqSequencePrms();
rlprms = daqRaylinePrms();

seqprms.freeRun = false;
seqprms.hpfBypass = false;
seqprms.divisor = 2; % data size = 16GB / 2^divisor
seqprms.externalTrigger = true;
seqprms.externalClock = true;
seqprms.lnaGain = 1; % 16dB, 18dB, 21dB
seqprms.pgaGain = 1; % 21dB, 24dB, 27dB, 30dB
seqprms.biasCurrent = 1; % 0,1,2,...,7
seqprms.fixedTGC = true;
seqprms.fixedTGCLevel = 30;

rlprms.lineDuration = 26; % line duration in micro seconds
rlprms.numSamples = 1024; 
rlprms.channels = [uint32(2^32) uint32(2^32) uint32(2^32) uint32(2^32)];
rlprms.decimation = uint8(0);
rlprms.sampling = uint8(40);

if ~daqSetFirmwarePath('./fw/')
    error('daqSetFirmwarePath failed');
end

if ~daqInit(0)
    error('daqInit failed');
end

if ~daqConnect()
    error('daqCOnnect failed);
end