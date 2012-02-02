/* INCLUDE */
#include "FrameClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
NoiseFrame::NoiseFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {}

/* METHODS */
void NoiseFrame::loadTable() {

	if (!tex->beginSequence()) 
		throw Error("Could not define sequence");
	
	lineCount = 0;
	for (int line = 0; line < 1235; line++) {

		lineSize = tex->addLine(rfData, *tx, *rx);

		if (lineSize == -1)
			throw Error("Could not add line to sequence");

		lineCount++;
	}

	if (!tex->endSequence()) 
		throw Error("Could not define sequence");
	
	//lineSize -= 4;

	validsequence = true;
}

void NoiseFrame::saveToBuffer(Buffer * buf) {

	buf->transferLine(tex->getCineStart(0), lineSize*lineCount);
}