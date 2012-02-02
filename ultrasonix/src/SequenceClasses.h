#pragma once
#ifndef SEQUENCECLASSES_H
#define SEQUENCECLASSES_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include "Sequence.h"

/* CLASS */
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