rlprms.lineDuration = int32(26); % line duration in micro seconds
rlprms.numSamples = int32(1024); % assuming 3000 samples at 40MHz
rlprms.channels = [uint32(2^32) uint32(2^32) uint32(2^32) uint32(2^32)];
%rlprms.gainDelay;
%rlprms.gainOffset;
%rlprms.rxDelay;
rlprms.decimation = uint8(0);
rlprms.sampling = uint8(40);

seqprms.freeRun = false;
seqprms.hpfBypass = false;
seqprms.divisor = uint8(2); % data size = 16GB / 2^divisor
seqprms.externalTrigger = true;
seqprms.externalClock = false; % set to true if external clock is provided
seqprms.lnaGain = int32(1); % 16dB, 18dB, 21dB
seqprms.pgaGain = int32(1); % 21dB, 24dB, 27dB, 30dB
seqprms.biasCurrent = int32(1); % 0,1,2,...,7
seqprms.fixedTGC = true;
seqprms.fixedTGCLevel = int32(30);
