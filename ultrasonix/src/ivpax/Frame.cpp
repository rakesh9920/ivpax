#include "Frame.h"

/* CONSTRUCTORS & DESTRUCTORS */
Frame::Frame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx) {

	setTexo(_tex);
	setTransmit(_tx);
	setReceive(_rx);
	running = false;
	validsequence = false;
}

AveragedFrame::AveragedFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {setNumberOfLinesToAvg(1);}

ScanningChannelFrame::ScanningChannelFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {}

ScanningChannelFrame2::ScanningChannelFrame2(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {}

NoiseFrame::NoiseFrame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx)
: Frame(_tex, _tx, _rx) {}

/* METHODS */
void Frame::collectFrame() {

	if(!validsequence)
		throw Error("Invalid Sequence");

	if(running)
		throw Error("Frame collection already running");

	if(!tex->runImage()) 
		throw Error("Could not start frame collection");

	running = true;

	while (tex->getCollectedFrameCount() >= 1)
		;
	while (tex->getCollectedFrameCount() < 1)
		;

	if(!tex->stopImage()) 
		throw Error("Could not stop frame collection");

	running = false;  
}

/*------------------- AVERAGING FRAME -------------------*/
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

/*------------------- SCANNING CHANNEL FRAME -------------------*/
void ScanningChannelFrame::loadTable() {

	if (!tex->beginSequence()) {
		throw Error("Could not define sequence");
	}

	lineCount = 0;
	for (int channel = 0; channel < 128; channel++) {

		rx->centerElement = (channel * 10) + 5;
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

/*------------------- SCANNING CHANNEL FRAME TYPE 2 -------------------*/
void ScanningChannelFrame2::loadTable() {

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

void ScanningChannelFrame2::saveToBuffer(Buffer * buf) {

	buf->transferFrame(tex->getCineStart(0), lineSize*lineCount);
}

/*------------------- NOISE FRAME -------------------*/
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