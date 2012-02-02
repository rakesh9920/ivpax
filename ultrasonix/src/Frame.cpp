/* INCLUDE */
#include "Frame.h"

/* CONSTRUCTORS & DESTRUCTORS */
Frame::Frame(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx) {

	setTexo(_tex);
	setTransmit(_tx);
	setReceive(_rx);
	running = false;
	validsequence = false;
}

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









