/* INCLUDE */
#include "FrameClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
FastAveragedFrame::FastAveragedFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {setNumberOfLinesToAvg(1);}

/* METHODS */
void FastAveragedFrame::loadTable() {

	if (!tex->beginSequence()) 
		throw Error("Could not define sequence");

	lineCount = 0;
	for (int channel = startChannel; channel < stopChannel + 1; channel++) {

		tx->tableIndex = 0;
		rx->tableIndex = channel;

		for (int line = 0; line < numberOfLinesToAvg; line++) {

			lineSize = tex->addLine(rfData, *tx, *rx);

			if (lineSize == -1)
				throw Error("Could not add line to sequence");

			lineCount++;
		}
	}

	if (!tex->endSequence()) 
		throw Error("Could not define sequence");

	if (numberOfLinesToAvg == 1)
		lineSize -= 4;

	validsequence = true;
}

void FastAveragedFrame::populateTable() {

	rx->aperture = 64;
	tex->addTransmit(*tx);

	for (int channel = startChannel; channel < stopChannel + 1; channel++) {

		if (channel < 64) 
			rx->centerElement = 315;
		else 
			rx->centerElement = 955;

		int c = channel % 64;
		rx->channelMask[0] = (c < 32) ? (1 << c) : 0;
		rx->channelMask[1] = (c >= 32) ? (1 << (c - 32)) : 0;
		tex->addReceive(*rx);
	}
}

unsigned char * FastAveragedFrame::average(signed short * set) {

	for (int channel = 0; channel < 128; channel++) {
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
	buf->transferLine(tex->getCineStart(0), lineSize*(stopChannel-startChannel));
}