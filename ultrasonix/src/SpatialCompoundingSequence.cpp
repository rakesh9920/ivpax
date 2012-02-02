/* INCLUDE */
#include "SequenceClasses.h"

/* STRUCT */
struct spatialCompoundingHeaderFile : public headerFile {

	int minAngle;
	int maxAngle;
	int angleIncrement;
};

struct spatialCompoundingParams {

	int angleIncrement;
	int numberOfAngles;
	int minAngle;
	int maxAngle;
	char fileName[50];
};

/* CONSTRUCTORS & DESTRUCTORS */
SpatialCompoundingSequence::SpatialCompoundingSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}



/* METHODS */
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