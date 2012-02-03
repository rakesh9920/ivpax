/* INCLUDE */
#include "SequenceClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
AveragedNonBFSequence::AveragedNonBFSequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

/* METHODS */
void AveragedNonBFSequence::collectSequence() {
	using namespace std;

	int cat = 0;

	saveHeaderFile();

	for (int part = 0; part < numberOfParts; part++) { // part loop

		int start = part * numberOfImageLines/numberOfParts;
		int end = start + numberOfImageLines/numberOfParts;

		for (int line = start; line < end; line++) { // line loop

			tx->centerElement = (line * 1280/numberOfImageLines) + 5;

			for (int channel = 0; channel < 128; channel++) { // channel loop

				system("cls");
				printf("RUNNING SEQUENCE\n\n");
				printf("Part: %d/%d\n", part+1, numberOfParts);
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
		ss << fileName;
		ss << "_p";
		ss << part+1;

		buf->saveToFile(ss.str());
		buf->reset();
	}
}

void AveragedNonBFSequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &fileName);
	printf("Number of image lines: \n"); scanf("%d", &numberOfImageLines);
	printf("Number of parts: \n"); scanf("%d", &numberOfParts);
	printf("Number of lines to average: \n"); scanf("%d", &numberOfLinesToAvg);
	frm.setNumberOfLinesToAvg(numberOfLinesToAvg);

	linesPerPart = numberOfImageLines/numberOfParts*128;
	frm.loadTable();
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;
}

void AveragedNonBFSequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	printf("Part size = %d bytes\n", partSize);
	printf("Line size = %d bytes\n", lineSize);
	printf("Lines per part = %d\n", linesPerPart);
	printf("Number of parts = %d\n", numberOfParts);
}

void AveragedNonBFSequence::saveHeaderFile() {

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