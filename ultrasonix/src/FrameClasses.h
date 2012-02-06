#pragma once
#ifndef FRAMECLASSES_H
#define FRAMECLASSES_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include "Frame.h"

/* CLASS */
class FastAveragedFrame: public Frame {

protected:
	int numberOfLinesToAvg;
	int digitalGain;
	int startChannel;
	int stopChannel;
	unsigned char * average(signed short *);

public:
	FastAveragedFrame() {}
	FastAveragedFrame(texo *, texoTransmitParams *, texoReceiveParams *);
	~FastAveragedFrame() {}
	void loadTable();
	void saveToBuffer(Buffer *);
	void setStartChannel(int _startChannel) {startChannel = _startChannel;}
	void setStopChannel(int _stopChannel) {stopChannel = _stopChannel;}
	void setNumberOfLinesToAvg(int _numberOfLinesToAvg) {numberOfLinesToAvg = _numberOfLinesToAvg;}
	void setDigitalGain(int _digitalGain) {digitalGain = _digitalGain;}
	void populateTable();
};

class AveragedFrame: public Frame {

protected:
	int numberOfLinesToAvg;
	int digitalGain;
	unsigned char * average(signed short *);

public:
	AveragedFrame() {}
	AveragedFrame(texo *, texoTransmitParams *, texoReceiveParams *);
	~AveragedFrame() {}
	void loadTable();
	void saveToBuffer(Buffer *);
	void setNumberOfLinesToAvg(int _numberOfLinesToAvg) {numberOfLinesToAvg = _numberOfLinesToAvg;}
	void setDigitalGain(int _digitalGain) {digitalGain = _digitalGain;}
};

class ScanningChannelFrame: public Frame {

protected:

public:
	ScanningChannelFrame() {}
	ScanningChannelFrame(texo *, texoTransmitParams *, texoReceiveParams *);
	~ScanningChannelFrame() {}
	void loadTable();
	void saveToBuffer(Buffer *);
};

class NoiseFrame: public Frame {

protected:
	//int numberOfLines;

public:
	NoiseFrame() {}
	NoiseFrame(texo *, texoTransmitParams *, texoReceiveParams *);
	~NoiseFrame() {}
	void loadTable();
	void saveToBuffer(Buffer *);
	//void setNumberOfLines(int _numberOfLines) {numberOfLines = _numberOfLines;}
};

#endif