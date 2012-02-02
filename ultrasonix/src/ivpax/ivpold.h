#pragma once
#ifndef IVPAX_H
#define IVPAX_H

#define _CRT_SECURE_NO_WARNINGS

/* include */
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <cstring>
#include <string>
#include <sstream>
#include <texo.h>
#include <texo_def.h>

/* define */
#define SONIXTOUCH
#define NUMCHANNELS		64
#define MAXELEMENTS		128
#define SZCINE          128
#ifndef DATA_PATH
    #define DATA_PATH     "../dat/"
#endif

/* prototypes */
bool selectProbe(int);
void wait();
void clearLine();
void printStats();
bool createSequence(int);
bool sequenceBf();
bool sequencePartNonBf(int, int, int);
bool runPartNonBf(bool);
bool run();
bool stop();
bool saveData();
bool saveData(std::string);
bool newImage(void *, unsigned char *, int);
void * initBuffer(int);
bool transferFrame(void *);
bool queryParameters(bool);
bool initSequence(int, int, int);
bool saveHeaderFile();
short * average(short *, int, int);
int sequenceAveraging(texoTransmitParams, texoReceiveParams, int);

struct fileHeader {

	int frameSize;
	int linesPerFrame;
	int totalParts;
	int beamformed;
	int focus1;
	int focus2;
	int focus3;
};

#endif