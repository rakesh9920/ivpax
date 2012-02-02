#pragma once
#ifndef FRAME_H
#define FRAME_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include <texo.h>
#include <texo_def.h>
#include "Buffer.h"
#include "Errors.h"

/* CLASS */
/*------------------- FRAME DEFINITIONS -------------------*/
class Frame {

protected:
	texo * tex;
	texoTransmitParams * tx;
	texoReceiveParams * rx;
	int lineSize;
	int lineCount;
	bool running;
	bool validsequence;

public:
	Frame() {};
	Frame(texo *, texoTransmitParams *, texoReceiveParams *);
	~Frame() {};
	void collectFrame();
	virtual void loadTable() = 0;
	virtual void saveToBuffer(Buffer *) = 0;
	void setTexo(texo * _tex) {tex = _tex;}
	void setTransmit(texoTransmitParams * _tx) {tx = _tx;}
	void setReceive(texoReceiveParams * _rx) {rx = _rx;}
	int getLineSize() {return lineSize;}
	int getLineCount() {return lineCount;}
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

class ScanningChannelFrame2: public Frame {

protected:

public:
	ScanningChannelFrame2() {}
	ScanningChannelFrame2(texo *, texoTransmitParams *, texoReceiveParams *);
	~ScanningChannelFrame2() {}
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