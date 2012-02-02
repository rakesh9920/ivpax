#include "Sequence.h"

/* CONSTRUCTORS & DESTRUCTORS */
Sequence::Sequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) {

	setTexo(_tex);
	setTransmit(_tx);
	setReceive(_rx);
	buf = _buf;
}

