/* INCLUDE */
#include "SequenceClasses.h"

/* STRUCT */
struct spatialCompoundingHeaderFile : public headerFile {

	int minAngle;
	int maxAngle;
	int angleIncrement;
};

/* CONSTRUCTORS & DESTRUCTORS */
SpatialCompoundingSequence::SpatialCompoundingSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}



/* METHODS */
void SpatialCompoundingSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	minAngle = -(numberOfAngles-1)/2*angleIncrement;
	maxAngle = (numberOfAngles-1)/2*angleIncrement;
	int part = 0;

	//tx->focusDistance = 300000;
	tx->useManualDelays = true;
	tx->centerElement = 640;
	tx->aperture = 128;

	for (int angle = minAngle; angle <= maxAngle; angle += angleIncrement) {

		system("cls");
		printf("RUNNING SEQUENCE\n\n");
		printf("Angle: %d/%d\n", part+1, numberOfAngles);

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
		ss << fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();

		part++;
	}
}

void SpatialCompoundingSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &fileName);
	printf("Number of angles: \n"); scanf("%d", &numberOfAngles);
	printf("Angle increment (in 1/1000th of a deg): \n"); scanf("%d", &angleIncrement);

	linesPerPart = 128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
	minAngle = -(numberOfAngles-1)/2*angleIncrement;
	maxAngle = (numberOfAngles-1)/2*angleIncrement;
}

void SpatialCompoundingSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per angle/part = %d\n", linesPerPart);
	printf("Number of angles/parts = %d\n", numberOfAngles);
	printf("Minimum angle = %d\n", minAngle);
	printf("Maximum angle = %d\n", maxAngle);
	printf("Transmit On/Off: %s\n", tx->pulseShape);
}

void SpatialCompoundingSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	spatialCompoundingHeaderFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = numberOfAngles;
	h.beamformed = 0;
	h.focusDepth = 300;
	h.minAngle = minAngle;
	h.maxAngle = maxAngle;
	h.angleIncrement = angleIncrement;

	ss << "rfdata/";
	ss << fileName;
	ss << ".sch";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(fileName, 1, 50, fp);
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