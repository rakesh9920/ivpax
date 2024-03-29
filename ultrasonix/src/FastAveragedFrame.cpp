/* INCLUDE */
#include "FrameClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
FastAveragedFrame::FastAveragedFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {setNumberOfLinesToAvg(1);}

/* METHODS */
void FastAveragedFrame::loadTable() {

	if (!tex->beginSequence()) 
		throw Error("Could not define sequence");

	populateTable();

	lineCount = 0;
	for (int channel = startChannel; channel < stopChannel + 1; channel++) {

		tx->tableIndex = 0;
		rx->tableIndex = (channel < 64) ? 0: 1;

		int c = channel % 64;
		rx->channelMask[0] = (c < 32) ? (1 << c) : 0;
		rx->channelMask[1] = (c >= 32) ? (1 << (c - 32)) : 0;

		for (int line = 0; line < numberOfLinesToAvg; line++) {

			lineSize = tex->addLine(rfData, *tx, *rx);

			if (lineSize == -1)
				throw Error("Could not add line to sequence");

			lineCount++;
		}
	}

	if (!tex->endSequence()) 
		throw Error("Could not define sequence");

	validsequence = true;
}

void FastAveragedFrame::populateTable() {

	rx->aperture = 64;
	rx->tableIndex = -1;
	tx->tableIndex = -1;

	tex->addTransmit(*tx);

	rx->centerElement = 315;
	tex->addReceive(*rx);

	rx->centerElement = 955;
	tex->addReceive(*rx);
}

unsigned char * FastAveragedFrame::average(signed short * set) {

	for (int channel = 0; channel < (stopChannel - startChannel + 1); channel++) {
		for (int sample = 0; sample < lineSize/2; sample++) {

			double sum = 0;

			for (int line = 0; line < numberOfLinesToAvg; line++) 
				sum += ((double) set[channel*numberOfLinesToAvg*lineSize/2 + line*lineSize/2 + sample]);

			set[channel*lineSize/2 + sample] = (signed short) ((((double) digitalGain)*sum)/((double) numberOfLinesToAvg));
		}
	}

	return (unsigned char *) set;
}

void FastAveragedFrame::saveToBuffer(Buffer * buf) {

	average((signed short *) tex->getCineStart(0));
	buf->transferLine(tex->getCineStart(0), lineSize*(stopChannel-startChannel+1));
}