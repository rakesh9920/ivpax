#pragma once
#ifndef BUFFER_H
#define BUFFER_H
#define _CRT_SECURE_NO_WARNINGS

/* INCLUDE */
#include <stdlib.h>
#include <cstring>
#include <string>
#include "Errors.h"

/* CLASS */
class Buffer {

protected:
	int pos;
	int size;
	unsigned char * start;

public:
	Buffer();
	Buffer(int);
	~Buffer();
	void transferFrame(unsigned char *, int);
	void transferLine(unsigned char *, int);
	unsigned char * getStart() {return start;}
	int getPos() {return pos;}
	void reset() {pos = 0;}
	void saveToFile(std::string);
};

#endif