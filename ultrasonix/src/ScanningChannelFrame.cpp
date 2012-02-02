/* INCLUDE */
#include "FrameClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
ScanningChannelFrame::ScanningChannelFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {}

/* METHODS */
void ScanningChannelFrame::loadTable() {

	if (!tex->beginSequence()) {
		throw Error("Could not define sequence");
	}

	rx->aperture = 64;

	lineCount = 0;

	rx->centerElement = 315;
	for (int channel = 0; channel < 64; channel++) {

        rx->channelMask[0] = (channel < 32) ? (1 << channel) : 0;
        rx->channelMask[1] = (channel >= 32) ? (1 << (channel - 32)) : 0;
		lineSize = tex->addLine(rfData, *tx, *rx);
		lineCount++;
	}

	rx->centerElement = 955;
	for (int channel = 0; channel < 64; channel++) {

        rx->channelMask[0] = (channel < 32) ? (1 << channel) : 0;
        rx->channelMask[1] = (channel >= 32) ? (1 << (channel - 32)) : 0;
		lineSize = tex->addLine(rfData, *tx, *rx);
		lineCount++;
	}

	if (!tex->endSequence()) {
		throw Error("Could not define sequence");
	}

	validsequence = true;
}

void ScanningChannelFrame::saveToBuffer(Buffer * buf) {

	buf->transferFrame(tex->getCineStart(0), lineSize*lineCount);
}

