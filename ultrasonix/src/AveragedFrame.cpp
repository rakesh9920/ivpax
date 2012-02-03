/* INCLUDE */
#include "FrameClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
AveragedFrame::AveragedFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {setNumberOfLinesToAvg(1);}

/* METHODS */
void AveragedFrame::loadTable() {

	if (!tex->beginSequence()) 
		throw Error("Could not define sequence");
	
	lineCount = 0;
	for (int line = 0; line < numberOfLinesToAvg; line++) {

		lineSize = tex->addLine(rfData, *tx, *rx);

		if (lineSize == -1)
			throw Error("Could not add line to sequence");

		lineCount++;
	}

	if (!tex->endSequence()) 
		throw Error("Could not define sequence");
	
	if (numberOfLinesToAvg == 1)
		lineSize -= 4;

	validsequence = true;
}

unsigned char * AveragedFrame::average(signed short * set) {

	for (int sample = 0; sample < lineSize/2; sample++) {

		double sum = 0;

		for (int n = 0; n < numberOfLinesToAvg; n++) 
			sum += ((double) set[sample + lineSize/2*n]);

		set[sample] = (signed short) ((((double) digitalGain)*sum)/((double) numberOfLinesToAvg));
	}

	return (unsigned char *) set;
}

void AveragedFrame::saveToBuffer(Buffer * buf) {

	average((signed short *) tex->getCineStart(0));
	buf->transferLine(tex->getCineStart(0), lineSize);
}