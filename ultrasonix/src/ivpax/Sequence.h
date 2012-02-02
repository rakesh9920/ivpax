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
/*------------------- INPUT PARAMETER DEFINITIONS -------------------*/
struct averagedNonBFParams {

	int numberOfParts;
	int numberOfImageLines;
	int numberOfLinesToAvg;
	char fileName[50];
};

struct nonBFParams {

	int numberOfParts;
	int numberOfImageLines;
	char fileName[50];
};

struct spatialCompoundingParams {

	int angleIncrement;
	int numberOfAngles;
	int minAngle;
	int maxAngle;
	char fileName[50];
};

struct averagedPAParams {

	int numberOfLinesToAvg;
	int digitalGain;
	char fileName[50];
};

struct NoiseParams {

	int receiveTime; //in seconds
	char fileName[50];
};

/*------------------- HEADER FILE DEFINITIONS -------------------*/
struct headerFile {

	int partSize;
	int linesPerPart;
	int totalParts;
	int beamformed;
	int focusDepth;
};

struct spatialCompoundingHeaderFile : public headerFile {

	int minAngle;
	int maxAngle;
	int angleIncrement;
};

/* CLASS */
/*------------------- SEQUENCE DEFINITIONS -------------------*/
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

class AveragedNonBFSequence: public Sequence {

protected:
	AveragedFrame frm;
	averagedNonBFParams prm;

public:
	AveragedNonBFSequence() {}
	AveragedNonBFSequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~AveragedNonBFSequence() {};
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class SpatialCompoundingSequence: public Sequence {

protected:
	ScanningChannelFrame frm;
	spatialCompoundingParams prm;
	int minAngle;
	int maxAngle;
	void setManualDelays(int);

public:
	SpatialCompoundingSequence() {}
	SpatialCompoundingSequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~SpatialCompoundingSequence() {};
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class NonBFSequence: public Sequence {

protected:
	ScanningChannelFrame frm;
	nonBFParams prm;

public:
	NonBFSequence() {}
	NonBFSequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~NonBFSequence() {}
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class NonBFSequence2: public Sequence {

protected:
	ScanningChannelFrame2 frm;
	nonBFParams prm;

public:
	NonBFSequence2() {}
	NonBFSequence2(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~NonBFSequence2() {}
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class AveragedPASequence: public Sequence {

protected:
	AveragedFrame frm;
	averagedPAParams prm;

public:
	AveragedPASequence() {}
	AveragedPASequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~AveragedPASequence() {};
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class AveragedPASequence2: public Sequence {

protected:
	AveragedFrame frm;
	averagedPAParams prm;

public:
	AveragedPASequence2() {}
	AveragedPASequence2(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~AveragedPASequence2() {};
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

class NoiseSequence: public Sequence {

protected:
	NoiseFrame frm;
	NoiseParams prm;

public:
	NoiseSequence() {}
	NoiseSequence(texo *, texoTransmitParams *, texoReceiveParams *, Buffer *);
	~NoiseSequence() {};
	void collectSequence();
	void querySequenceParams();
	void printStats();
	void saveHeaderFile();
};

#endif