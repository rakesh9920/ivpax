#pragma once
#ifndef DBLBUFFER_H
#define DBLBUFFER_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include <stdlib.h>
#include <cstring>
#include <string>

/* CLASS */
class dblBuffer {

protected:
	int pos;
	int size;
	unsigned char * start;

public:
	dblBuffer();
	dblBuffer(int);
	~dblBuffer();
	void transferFrame(unsigned char *, int);
	void transferLine(unsigned char *, int);
	unsigned char * getBufferStart() {return start;}
	int getPos() {return pos;}
	void reset() {pos = 0;}
	void saveToFile(std::string);
};

#endif