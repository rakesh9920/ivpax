#pragma once
#ifndef SEQUENCE_H
#define SEQUENCE_H
#define _CRT_SECURE_NO_WARNINGS
#define _USE_MATH_DEFINES

/* INCLUDE */
#include <texo.h>
#include <texo_def.h>
#include <sstream>
#include <conio.h>
#include "Frame.h"
#include "Buffer.h"
#include "Errors.h"
#include <cmath>

/* STRUCT */
struct headerFile {

	int partSize;
	int linesPerPart;
	int totalParts;
	int beamformed;
	int focusDepth;
};

/* CLASS */
class Sequence {

protected:
	texo * tex;
	texoTransmitParams * tx;
	texoReceiveParams * rx;
	Buffer * buf;

public:
	Sequence() {};
	Sequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~Sequence() {};
	int lineSize;
	int partSize;
	int linesPerPart;
	virtual void collectSequence() = 0;
	virtual void querySequenceParams() = 0;
	virtual void printStats() = 0;
	virtual void saveHeaderFile() = 0;
	int getLineSize() {return lineSize;}
	int getPartSize() {return partSize;}
	int getLinesPerPart() {return linesPerPart;}
	void setTexo(texo * _tex) {tex = _tex;}
	void setTransmit(texoTransmitParams * _tx) {tx = _tx;}
	void setReceive(texoReceiveParams * _rx) {rx = _rx;}
	void setBuffer(Buffer * _buf) {buf = _buf;}
};

#endif