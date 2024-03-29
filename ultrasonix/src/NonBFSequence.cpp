/* INCLUDE */
#include "SequenceClasses.h"

/* STRUCT */


/* CONSTRUCTORS & DESTRUCTORS */
NonBFSequence::NonBFSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf)
:  Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

/* METHODS */
void NonBFSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	for (int part = 0; part < numberOfParts; part++) { // part loop

		int start = part * numberOfImageLines/numberOfParts;
		int end = start + numberOfImageLines/numberOfParts;

		for (int line = start; line < end; line++) { // line loop

			tx->centerElement = (line * 1280/numberOfImageLines) + 5;

			system("cls");
			printf("RUNNING SEQUENCE\n\n");
			printf("Part: %d/%d\n", part+1, numberOfParts);
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
		ss << fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void NonBFSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &fileName);
	printf("Number of image lines: \n"); scanf("%d", &numberOfImageLines);
	printf("Number of parts: \n"); scanf("%d", &numberOfParts);

	linesPerPart = numberOfImageLines/numberOfParts*128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void NonBFSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
	printf("Number of parts = %d\n", numberOfParts);
	printf("Transmit On/Off: %s\n", tx->pulseShape);
}

void NonBFSequence::saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;
	headerFile h;

	h.partSize = partSize;
	h.linesPerPart = linesPerPart;
	h.totalParts = numberOfParts;
	h.beamformed = 0;
	h.focusDepth = tx->focusDistance;

	ss << "rfdata/";
	ss << fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}