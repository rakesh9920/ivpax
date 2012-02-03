#pragma once
#ifndef IVPAX_H
#define IVPAX_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include <texo.h>
#include <texo_def.h>
#include "Sequence.h"
#include "SequenceClasses.h"
#include "Buffer.h"
#include "Errors.h"	

/* STRUCT */
struct texoParams {

	bool transmitOn;
	char sequenceSelect;
	int gain;
	int power;
	int imageDepth;
	int focusDepth;
	int syncOn;
};

/* CLASS */
class Ivpax {

protected:
	texo tex;
	texoTransmitParams tx;
	texoReceiveParams rx;
	Buffer buf;
	texoParams tprm;
	
public:
	Ivpax() {}
	~Ivpax() {tex.shutdown();}
	void wait();
	void texoInit();
	void printStats(Sequence *);
	void selectionMenu();
	void queryTexoParams();
	Sequence * seqInit();
	void run(Sequence *);
	void shutdown();
};

/* METHODS */
bool newImage(void *, unsigned char *, int) {return true;}

#endif