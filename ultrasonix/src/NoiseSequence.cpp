/* INCLUDE */
#include "SequenceClasses.h"

/* STRUCT */
struct NoiseParams {

	int receiveTime; //in seconds
	char fileName[50];
};

/* CONSTRUCTORS & DESTRUCTORS */
NoiseSequence::NoiseSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

/* METHODS */
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