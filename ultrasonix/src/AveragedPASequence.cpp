/* INCLUDE */
#include "SequenceClasses.h"

/* CONSTRUCTORS & DESTRUCTORS */
AveragedPASequence::AveragedPASequence(texo * _tex, texoTransmitParams * _tx, texoReceiveParams * _rx, Buffer * _buf) 
: Sequence(_tex, _tx, _rx, _buf), frm(_tex, _tx, _rx) {}

/* METHODS */
void AveragedPASequence::collectSequence() {
	using namespace std;

	int cat = 0;

	strcpy(tx->pulseShape, "00");
	rx->aperture = 64;

	for (int section = 0; section < totalSections; section++) {

		system("cls");
		printf("RUNNING SEQUENCE\n\n");
		printf("Channel: %d/%d\n\n", section+1, totalSections);

		switch (cat) {
					case 0: {printf("om\n"); cat++; break;}
					case 1: {printf("   nom\n"); cat++; break;}
					case 2: {printf("       nom\n"); cat = 0; break;}
		}

		printf("\nPress any key to terminate sequence\n");

		if (_kbhit()) {
			_getch();
			fflush(stdin);
			throw Error("Sequence cancelled by user");
			return;
		}

		int startChannel = section*128/totalSections;
		int stopChannel = startChannel + 128/totalSections - 1;

		frm.setStartChannel(startChannel);
		frm.setStopChannel(stopChannel);
		frm.loadTable();
		frm.collectFrame();
		frm.saveToBuffer(buf);		
	}
	
	lineSize = frm.getLineSize();
	partSize = lineSize*linesPerPart;

	saveHeaderFile();

	stringstream ss;
	ss << "rfdata/";
	ss << fileName;
	ss << ".rf";

	buf->saveToFile(ss.str());
	buf->reset();
}

void AveragedPASequence::querySequenceParams() {

	printf("SEQUENCE PARAMETERS\n\n");
	printf("filename: \n"); scanf("%s", &fileName);
	printf("Number of lines to average: \n"); scanf("%d", &numberOfLinesToAvg);
	printf("Digital gain multiplier: \n"); scanf("%d", &digitalGain);
	printf("Number of sections: \n"); scanf("%d", &totalSections);
	frm.setNumberOfLinesToAvg(numberOfLinesToAvg);
	frm.setDigitalGain(digitalGain);
	linesPerPart = 128;
	//frm.loadTable();
	//lineSize = frm.getLineSize();
	//partSize = lineSize*linesPerPart;
}

void AveragedPASequence::printStats() {

	printf("SEQUENCE STATISTICS\n\n");
	//printf("Part size = %d bytes\n", partSize);
	//printf("Line size = %d bytes\n", lineSize);
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
	ss << fileName;
	ss << ".bmh";

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(fileName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);
}