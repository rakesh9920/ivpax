#include "Sequence.h"

/* CONSTRUCTORS & DESTRUCTORS */
Sequence::Sequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) {

	setTexo(_tex);
	setTransmit(_tx);
	setReceive(_rx);
	buf = _buf;
}

AveragedNonBFSequence::AveragedNonBFSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

NonBFSequence::NonBFSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf)
:  Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

NonBFSequence2::NonBFSequence2(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf)
:  Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

SpatialCompoundingSequence::SpatialCompoundingSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

AveragedPASequence::AveragedPASequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

AveragedPASequence2::AveragedPASequence2(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

NoiseSequence::NoiseSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

/* METHODS */
/*------------------- NON-BEAMFORMED SEQUENCE WITH AVERAGING -------------------*/
void AveragedNonBFSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	for (int part = 0; part < prm.numberOfParts; part++) { // part loop

		int start = part * prm.numberOfImageLines/prm.numberOfParts;
		int end = start + prm.numberOfImageLines/prm.numberOfParts;

		for (int line = start; line < end; line++) { // line loop

			tx->centerElement = (line * 1280/prm.numberOfImageLines) + 5;

			for (int channel = 0; channel < 128; channel++) { // channel loop

				system("cls");
				printf("RUNNING SEQUENCE\n\n");
				printf("Part: %d/%d\n", part+1, prm.numberOfParts);
				printf("Line: %d/%d\n", line-start+1, end-start);
				printf("Channel: %d/128\n\n", channel+1);

				switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
				}

				printf("\nPress any key to terminate sequence\n");

				if (_kbhit()) {
					_getch();
					fflush(stdin);
					throw Error("Sequence cancelled by user");
					return;
				}

				rx->centerElement = (channel * 10) + 5;

				frm.loadTable();
				frm.collectFrame();
				frm.saveToBuffer(buf);
			}
		}

		stringstream ss;
		ss << "rfdata/";
		ss << prm.fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void AveragedNonBFSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of image lines: \n"); scanf("%d", &prm.numberOfImageLines);
	printf("Number of parts: \n"); scanf("%d", &prm.numberOfParts);
	printf("Number of lines to average: \n"); scanf("%d", &prm.numberOfLinesToAvg);
	frm.setNumberOfLinesToAvg(prm.numberOfLinesToAvg);

	linesPerPart = prm.numberOfImageLines/prm.numberOfParts*128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void AveragedNonBFSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
	printf("Number of parts = %d\n", prm.numberOfParts);
}

void AveragedNonBFSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = prm.numberOfParts;
	h.beamformed = 0;
	h.focusDepth = tx->focusDistance;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

/*------------------- NON-BEAMFORMED SEQUENCE NO AVERAGING -------------------*/
void NonBFSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	for (int part = 0; part < prm.numberOfParts; part++) { // part loop

		int start = part * prm.numberOfImageLines/prm.numberOfParts;
		int end = start + prm.numberOfImageLines/prm.numberOfParts;

		for (int line = start; line < end; line++) { // line loop

			tx->centerElement = (line * 1280/prm.numberOfImageLines) + 5;

			system("cls");
			printf("RUNNING SEQUENCE\n\n");
			printf("Part: %d/%d\n", part+1, prm.numberOfParts);
			printf("Line: %d/%d\n\n", line-start+1, end-start);

			switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
			}

			printf("\nPress any key to terminate sequence\n");

			if (_kbhit()) {
				_getch();
				fflush(stdin);
				throw Error("Sequence cancelled by user");
				return;
			}

			frm.loadTable();
			frm.collectFrame();
			frm.saveToBuffer(buf);
		}

		stringstream ss;
		ss << "rfdata/";
		ss << prm.fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void NonBFSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of image lines: \n"); scanf("%d", &prm.numberOfImageLines);
	printf("Number of parts: \n"); scanf("%d", &prm.numberOfParts);

	linesPerPart = prm.numberOfImageLines/prm.numberOfParts*128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void NonBFSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
	printf("Number of parts = %d\n", prm.numberOfParts);
	printf("Transmit On/Off: %s\n", tx->pulseShape);
}

void NonBFSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = prm.numberOfParts;
	h.beamformed = 0;
	h.focusDepth = tx->focusDistance;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

/*------------------- NON-BEAMFORMED SEQUENCE NO AVERAGING TYPE 2 -------------------*/
void NonBFSequence2::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	for (int part = 0; part < prm.numberOfParts; part++) { // part loop

		int start = part * prm.numberOfImageLines/prm.numberOfParts;
		int end = start + prm.numberOfImageLines/prm.numberOfParts;

		for (int line = start; line < end; line++) { // line loop

			tx->centerElement = (line * 1280/prm.numberOfImageLines) + 5;

			system("cls");
			printf("RUNNING SEQUENCE\n\n");
			printf("Part: %d/%d\n", part+1, prm.numberOfParts);
			printf("Line: %d/%d\n\n", line-start+1, end-start);

			switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
			}

			printf("\nPress any key to terminate sequence\n");

			if (_kbhit()) {
				_getch();
				fflush(stdin);
				throw Error("Sequence cancelled by user");
				return;
			}

			frm.loadTable();
			frm.collectFrame();
			frm.saveToBuffer(buf);
		}

		stringstream ss;
		ss << "rfdata/";
		ss << prm.fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void NonBFSequence2::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of image lines: \n"); scanf("%d", &prm.numberOfImageLines);
	printf("Number of parts: \n"); scanf("%d", &prm.numberOfParts);

	linesPerPart = prm.numberOfImageLines/prm.numberOfParts*128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void NonBFSequence2::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
	printf("Number of parts = %d\n", prm.numberOfParts);
	printf("Transmit On/Off: %s\n", tx->pulseShape);
}

void NonBFSequence2::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = prm.numberOfParts;
	h.beamformed = 0;
	h.focusDepth = tx->focusDistance;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

/*------------------- SPATIAL COMPOUNDING SEQUENCE NO AVERAGING -------------------*/
void SpatialCompoundingSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	prm.minAngle = -(prm.numberOfAngles-1)/2*prm.angleIncrement;
	prm.maxAngle = (prm.numberOfAngles-1)/2*prm.angleIncrement;
	int part = 0;

	//tx->focusDistance = 300000;
	tx->useManualDelays = true;
	tx->centerElement = 640;
	tx->aperture = 128;

	for (int angle = prm.minAngle; angle <= prm.maxAngle; angle += prm.angleIncrement) {

		system("cls");
		printf("RUNNING SEQUENCE\n\n");
		printf("Angle: %d/%d\n", part+1, prm.numberOfAngles);

		switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
		}

		printf("\nPress any key to terminate sequence\n");

		if (_kbhit()) {
			_getch();
			fflush(stdin);
			throw Error("Sequence cancelled by user");
			return;
		}

		//tx->angle = angle;
		setManualDelays(angle);

		frm.loadTable();
		frm.collectFrame();
		frm.saveToBuffer(buf);

		stringstream ss;
		ss << "rfdata/";
		ss << prm.fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();

		part++;
	}
}

void SpatialCompoundingSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of angles: \n"); scanf("%d", &prm.numberOfAngles);
	printf("Angle increment (in 1/1000th of a deg): \n"); scanf("%d", &prm.angleIncrement);

	linesPerPart = 128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
	prm.minAngle = -(prm.numberOfAngles-1)/2*prm.angleIncrement;
	prm.maxAngle = (prm.numberOfAngles-1)/2*prm.angleIncrement;
}

void SpatialCompoundingSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per angle/part = %d\n", linesPerPart);
	printf("Number of angles/parts = %d\n", prm.numberOfAngles);
	printf("Minimum angle = %d\n", prm.minAngle);
	printf("Maximum angle = %d\n", prm.maxAngle);
	printf("Transmit On/Off: %s\n", tx->pulseShape);
}

void SpatialCompoundingSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	spatialCompoundingHeaderFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = prm.numberOfAngles;
	h.beamformed = 0;
	h.focusDepth = 300;
	h.minAngle = prm.minAngle;
	h.maxAngle = prm.maxAngle;
	h.angleIncrement = prm.angleIncrement;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".sch";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

void SpatialCompoundingSequence::setManualDelays(int angle) {

	double tanofangle = tan(((double) angle)/1000*2*M_PI/360);

	for (int element = 0; element < 128; element++) {

		double distance;
		if (angle >= 0) {
			distance = (1275 - (element*10 + 5))*30*tanofangle; // in microns
		} else {
			distance = -(element*10 + 5)*30*tanofangle; // in microns
		}

		double time = distance/tx->speedOfSound; // in microsec

		tx->manualDelays[element] = (int) (time/0.025 + 0.5);
	}
}

/*------------------- PHOTOACOUSTIC SEQUENCE WITH AVERAGING -------------------*/
void AveragedPASequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	strcpy(tx->pulseShape, "00");
	rx->aperture = 0;
	rx->applyFocus = false;

	for (int channel = 0; channel < 128; channel++) { // channel loop

		system("cls");
		printf("RUNNING SEQUENCE\n\n");
		printf("Channel: %d/128\n\n", channel+1);

		switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
		}

		printf("\nPress any key to terminate sequence\n");

		if (_kbhit()) {
			_getch();
			fflush(stdin);
			throw Error("Sequence cancelled by user");
			return;
		}

		rx->centerElement = (channel * 10) + 5;

		frm.loadTable();
		frm.collectFrame();
		frm.saveToBuffer(buf);
	}

	stringstream ss;
	ss << "rfdata/" << prm.fileName << ".rf";

	buf->saveToFile(ss.str());
	buf->reset();
}

void AveragedPASequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of lines to average: \n"); scanf("%d", &prm.numberOfLinesToAvg);
	printf("Digital gain multiplier: \n"); scanf("%d", &prm.digitalGain);
	frm.setNumberOfLinesToAvg(prm.numberOfLinesToAvg);
	frm.setDigitalGain(prm.digitalGain);
	linesPerPart = 128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void AveragedPASequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
}

void AveragedPASequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = 1;
	h.beamformed = 0;
	h.focusDepth = 0;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

/*------------------- PHOTOACOUSTIC SEQUENCE WITH AVERAGING TYPE 2-------------------*/
void AveragedPASequence2::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	strcpy(tx->pulseShape, "00");
	rx->aperture = 64;

	for (int channel = 0; channel < 128; channel++) { // channel loop

		system("cls");
		printf("RUNNING SEQUENCE\n\n");
		printf("Channel: %d/128\n\n", channel+1);

		switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
		}

		printf("\nPress any key to terminate sequence\n");

		if (_kbhit()) {
			_getch();
			fflush(stdin);
			throw Error("Sequence cancelled by user");
			return;
		}

		if (channel < 64) 
			rx->centerElement = 315;
		else 
			rx->centerElement = 955;

		int c = channel % 64;
		rx->channelMask[0] = (c < 32) ? (1 << c) : 0;
		rx->channelMask[1] = (c >= 32) ? (1 << (c - 32)) : 0;

		frm.loadTable();
		frm.collectFrame();
		frm.saveToBuffer(buf);
	}

	stringstream ss;
	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".rf";

	buf->saveToFile(ss.str());
	buf->reset();
}

void AveragedPASequence2::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Number of lines to average: \n"); scanf("%d", &prm.numberOfLinesToAvg);
	printf("Digital gain multiplier: \n"); scanf("%d", &prm.digitalGain);
	frm.setNumberOfLinesToAvg(prm.numberOfLinesToAvg);
	frm.setDigitalGain(prm.digitalGain);
	linesPerPart = 128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void AveragedPASequence2::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
}

void AveragedPASequence2::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = 1;
	h.beamformed = 0;
	h.focusDepth = 0;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}

/*------------------- NOISE SEQUENCE -------------------*/
void NoiseSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	strcpy(tx->pulseShape, "00");
	tx->centerElement = 645;
	tx->speedOfSound = 1482;

	rx->channelMask[0] = rx->channelMask[1] = 0xFFFFFFFF;
	rx->centerElement = 645;
	rx->aperture = 64;
	rx->applyFocus = false;
	rx->speedOfSound = 1482;
    rx->acquisitionDepth = 30000;

	frm.loadTable();

	int noParts = prm.receiveTime/3;

	for (int part = 0; part < noParts; part++) {
		for (int frame = 0; frame < 60; frame++) { // frame loop

			system("cls");
			printf("RUNNING SEQUENCE\n\n");
			printf("Part: %d/%d\n", part+1, noParts);
			printf("Frame: %d/60\n\n", frame+1);

			switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break; }
					case 2: {printf("       nom\n"); cat = 0; break;}
			}

			printf("\nPress any key to terminate sequence\n");

			if (_kbhit()) {
				_getch();
				fflush(stdin);
				throw Error("Sequence cancelled by user");
				return;
			}

			
			frm.collectFrame();
			frm.saveToBuffer(buf);
		}

		stringstream ss;
		ss << "rfdata/" << prm.fileName;
		ss << "_p" << part+1 <<".rf";

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void NoiseSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &prm.fileName);
	printf("Receive time in seconds: \n"); scanf("%d", &prm.receiveTime);

	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = tex->getFrameSize()*3;
	linesPerPart = partSize/lineSize;
}

void NoiseSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Line size = %d bytes\n", lineSize);
	printf("Frame size = %d bytes\n", tex->getFrameSize());
	printf("Part size = %d bytes\n", partSize);	
	printf("Lines per part = %d\n", linesPerPart);
}

void NoiseSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = 1;
	h.totalParts = prm.receiveTime/3;
	h.beamformed = 0;
	h.focusDepth = 0;

	ss << "rfdata/";
	ss << prm.fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(prm.fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}