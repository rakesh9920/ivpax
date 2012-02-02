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

#endif