// IVPAX - Intravascular Photoacoustics Experiment

/* include */
#include "ivpax.h"

/* global */
// texo vars
texo tex;
fileHeader h;
bool running = false;
bool validprobe = false;
bool validsequence = false;
bool transmitOn = true;
int power = 15;
int gain = 50;
int depth;
int focus[3];
int averagingN = 1;
CURVE tgc1;

// statistics vars
int lineCount = 0;
char baseName[50];
int frameSize;
int totalParts;
int numOfScanlines;
int beamformed;
int lineSize;

// double buffer vars
int pos;
int linePos;
int bufferSize;
unsigned char * buffer;

/* entry point */
int main() {    

	char sel;

	// texo initialization
	if(!tex.init(DATA_PATH, 3, 3, 0, NUMCHANNELS, 3, 128))
		return -1;

	// set the new frame callback
	tex.setCallback(newImage, 0);

	// initialize global parameters
	tex.setPower(power, power, power);
	tex.clearTGCs();

	// enable external trigger synchronization
	tex.setSyncSignals(1,1,0);

	// probe and sequence initialization
	printf("initializing probe 0 ... ");
	selectProbe(0);
	printf("[ok]\n");

	// memory buffer initialization
	printf("initializing memory buffer ... ");
	buffer = (unsigned char *) initBuffer(128 * 1024 * 1024);
	if (buffer == NULL) 
	{
		printf("[failed]\n");
		return -1;
	} else {
		printf("[ok!]\n");
	}

	// menu options
	for(;;) 
	{
		printf("\n");
		printf("(1) load bf rf sequence\n");
		printf("(2) load/run partitioned multifocus non-bf rf sequence\n");
		printf("(3) load/run partitioned single focus non-bf rf sequence\n");
		printf("\n");
		printf("(R) run sequence\n");
		printf("(S) stop sequence\n");
		printf("\n");
		printf("(D) store data to disk\n");
		printf("(X) exit\n");
		printf("\n");
		scanf("%c", &sel);

		switch(sel) {

			case '1': createSequence(1); break;
			case '2': runPartNonBf(true); break;
			case '3': runPartNonBf(false); break;
			case 'r': case 'R': run(); break;
			case 's': case 'S': stop(); break;
			case 'd': case 'D': saveData(); break;
			case 'x': case 'X': goto goodbye;
		}

		wait();        
	}

goodbye:
	if(running)
		stop();

	// clean up
	if (buffer != NULL) 
		free(buffer);

	tex.shutdown();
	return 0;
}

/* double buffer */
void * initBuffer(int sz) {

	pos = 0;
	bufferSize = sz;
	return malloc(sz);
}

bool transferFrame(void * data) {

	memcpy(buffer + pos, data, frameSize);

	pos += frameSize;
	if(pos > bufferSize - frameSize)
		pos = 0;

	return true;
}

bool transferLine(void * data) {

	memcpy(buffer + linePos, data, lineSize);

	linePos += lineSize;
	if(linePos > bufferSize - lineSize)
		linePos = 0;

	return true;
}

short * average(short * frame, int length, int averagingN) {

	for (int sample = 0; sample < length; sample++) {

		signed int sum = 0;

		for (int n = 0; n < averagingN; n++) 
			sum += ((signed int) frame[sample + length*n]);

		frame[sample] = (signed short) (sum/((signed int)averagingN));
	}

	return frame;
}

/* sequences */
// transmits and receives across the entire probe to acquire focused RF data from each element
bool sequenceBf() 
{
	int i, lineSize;
	texoTransmitParams tx;
	texoReceiveParams rx;

	// transmit parameters
	tx.centerElement = 0;
	tx.aperture = 64;
	tx.focusDistance = 20000;
	tx.angle = 0;
	tx.frequency = tex.getProbeCenterFreq();
	strcpy(tx.pulseShape, "+-");
	tx.speedOfSound = 1540;
	tx.useManualDelays = false;
	tx.tableIndex = -1;
	tx.useDeadElements = false;
	tx.trex = false;

	// receive parameters
	rx.centerElement = 0;
	rx.aperture = NUMCHANNELS;
	rx.angle = 0;
	rx.maxApertureDepth = 20000;
	rx.acquisitionDepth = depth * 1000;
	rx.saveDelay = 5000;
	rx.speedOfSound = 1540;
	rx.channelMask[0] = rx.channelMask[1] = 0xFFFFFFFF;
	rx.applyFocus = true;
	rx.useManualDelays = false;
	rx.decimation = 0;
	rx.customLineDuration = 0;
	rx.lgcValue = 0;
	rx.tgcSel = 0;
	rx.tableIndex = -1;

	// sequence
	for(i = 0; i < tex.getProbeNumElements(); i++)
	{
		// add 5 to the virtual element, to make symettrical time delays
		// we should do this because the aperture values must be even for now
		tx.centerElement = (i * 10) + 0; 
		rx.centerElement = (i * 10) + 0;

		lineSize = tex.addLine(rfData, tx, rx);
		lineCount++;

		if(lineSize == -1)
			return false;

		tx.centerElement = (i * 10) + 5;
		rx.centerElement = (i * 10) + 5;

		lineSize = tex.addLine(rfData, tx, rx);
		lineCount++;

		if(lineSize == -1)
			return false;
	}

	frameSize = tex.getFrameSize() - 4;
	beamformed = 1;
	return true;
}

bool sequencePartNonBf(int part, int totalparts, int foc) 
{
	int lineSize, start, end;
	texoTransmitParams tx;
	texoReceiveParams rx;

	// transmit parameters
	tx.centerElement = 0;
	tx.aperture = 0;
	tx.focusDistance = foc; // in microns
	tx.angle = 0;
	tx.frequency = 6600000;
	transmitOn ? strcpy(tx.pulseShape, "+-") : strcpy(tx.pulseShape, "00");
	tx.speedOfSound = 1482;
	tx.useManualDelays = false;
	tx.tableIndex = -1;
	tx.useDeadElements = false;
	tx.trex = false;

	// receive parameters
	rx.centerElement = 0;
	rx.aperture = 0;
	rx.angle = 0;
	rx.maxApertureDepth = foc; // in microns
	rx.acquisitionDepth = depth * 1000;
	rx.saveDelay = 5000;
	rx.speedOfSound = 1482;
	rx.applyFocus = false;
	rx.useManualDelays = false;
	rx.decimation = 0;
	rx.customLineDuration = 0;
	rx.lgcValue = 0;
	rx.tgcSel = 0;
	rx.tableIndex = -1;
	rx.channelMask[0] = rx.channelMask[1] = 0xFFFFFFFF;

	start = (part - 1)*numOfScanlines/totalparts;
	end = start + numOfScanlines/totalparts;
	lineCount = 0;

	// sequence
	for (int k = start; k < end; k++) {

		tx.centerElement = (k * 1280/numOfScanlines) + 5;

		for (int c = 0; c < 128; c++) {

			rx.centerElement = (c * 10) + 5;

			lineSize = tex.addLine(rfData, tx, rx);
			lineCount++;

			if (lineSize == -1)
				return false;
		}
	}

	frameSize = tex.getFrameSize() - 4;
	beamformed = 0;
	return true;
}

int sequenceAveraging(texoTransmitParams tx, texoReceiveParams rx, int averagingN) {

	// sequence
	if(!tex.beginSequence()) {
		//printf("[failed]\n");
		return false;
	}

	for (int n = 0; n < averagingN; n++) {

		lineSize = tex.addLine(rfData, tx, rx);

		if (lineSize == -1)
			return false;
	}

	if (tex.endSequence() == -1) {
		//printf("[failed]\n");
		return false;
	}

	validsequence = true;
	return lineSize;
}

bool queryParameters(bool mf) {

	int focus1, focus2, focus3;

	printf("enter a filename: ");
	scanf("%s", baseName);

	printf("enter desired image depth in mm (10-300):\n");
	scanf("%d", &depth);    
	if(depth < 10 || depth > 300) 
	{
		fprintf(stderr, "invalid depth entered\n");
		return false;
	}

	printf("enter focus 1 distance in mm (10-300, 300=plane):\n");
	scanf("%d", &focus1);
	focus[0] = 1000*focus1;
	if(focus1 < 10 || focus1 > 300) 
	{
		fprintf(stderr, "invalid depth entered\n");
		return false;
	}

	if (mf) {
		printf("enter focus 2 distance in mm (10-300, 300=plane):\n");
		scanf("%d", &focus2);  
		focus[1] = 1000*focus2;
		if(focus2 < 10 || focus2 > 300) 
		{
			fprintf(stderr, "invalid depth entered\n");
			return false;
		}

		printf("enter focus 3 distance in mm (10-300, 300=plane):\n");
		scanf("%d", &focus3);    
		focus[2] = 1000*focus3;
		if(focus3 < 10 || focus3 > 300) 
		{
			fprintf(stderr, "invalid depth entered\n");
			return false;
		}
	}

	printf("enter total number of partitions\n");
	scanf("%d", &totalParts);    
	if(totalParts < 0) 
	{
		fprintf(stderr, "invalid number of partitions entered\n");
		return false;
	}

	printf("enter total number of scanlines:\n");
	scanf("%d", &numOfScanlines);    
	if(numOfScanlines % 128 != 0) 
	{
		fprintf(stderr, "invalid number of scanlines\n");
		return false;
	}

	printf("set transmit on/off (1/0)\n");
	scanf("%d", &transmitOn);    

	printf("enter analog gain value (0-100)\n");
	scanf("%d", &gain);   
	if(gain > 100 || gain < 0) 
	{
		fprintf(stderr, "invalid gain value\n");
		return false;
	}

	printf("enter number of lines to average (1-1000)\n");
	scanf("%d", &averagingN); 

	return true;
}

bool initSequence(int part, int totalparts, int foc) {

	//printf("initializing sequence ... ");

	if(!tex.beginSequence()) {
		//printf("[failed]\n");
		return false;
	}

	if (!sequencePartNonBf(part, totalparts, foc)){
		//printf("[failed]\n");
		return false;
	}

	if (tex.endSequence() == -1) {
		//printf("[failed]\n");
		return false;
	}

	validsequence = true; //printf("[ok!]\n");
	return true;
}

bool runPartNonBf(bool mf) {

	bool firstframe = true;
	texoTransmitParams tx;
	texoReceiveParams rx;

	if (!queryParameters(mf))
		return false;

	if(!validprobe) {
		fprintf(stderr, "\ncannot create sequence, no probe selected\n");
		return false;
	}

	tgc1.top = gain;
	tgc1.mid = gain;
	tgc1.btm = gain;
	tgc1.vmid = 50;
	tex.addTGC(&tgc1, 100000);

	// transmit parameters
	tx.centerElement = 0;
	tx.aperture = 0;
	tx.angle = 0;
	tx.frequency = 6600000;
	transmitOn ? strcpy(tx.pulseShape, "+-") : strcpy(tx.pulseShape, "00");
	tx.speedOfSound = 1482;
	tx.useManualDelays = false;
	tx.tableIndex = -1;
	tx.useDeadElements = false;
	tx.trex = false;

	// receive parameters
	rx.centerElement = 0;
	rx.aperture = 0;
	rx.angle = 0;
	rx.acquisitionDepth = depth * 1000;
	rx.saveDelay = 5000;
	rx.speedOfSound = 1482;
	rx.applyFocus = false;
	rx.useManualDelays = false;
	rx.decimation = 0;
	rx.customLineDuration = 0;
	rx.lgcValue = 0;
	rx.tgcSel = 0;
	rx.tableIndex = -1;
	rx.channelMask[0] = rx.channelMask[1] = 0xFFFFFFFF;

	beamformed = 0;

	for (int part = 0; part < totalParts; part++) { // part loop

		for (int j = 0; j < 3; j++) { // focus loop

			tx.focusDistance = focus[j];
			rx.maxApertureDepth = focus[j];

			int start = part*numOfScanlines/totalParts;
			int end = start + numOfScanlines/totalParts;
			lineCount = 0;
			linePos = 0;

			for (int line = start; line < end; line++) { // line loop

				tx.centerElement = (line * 1280/numOfScanlines) + 5;

				for (int channel = 0; channel < 128; channel++) { // channel loop

					clearLine();
					printf("Channel %d/%d for line %d of part %d/%d", channel+1,128, line+1, part+1, totalParts);
					rx.centerElement = (channel * 10) + 5;

					lineSize = sequenceAveraging(tx, rx, averagingN);
					lineCount++;

					if (lineSize == -1)
						return false;

					if (firstframe) {
						frameSize = 128*numOfScanlines/totalParts*lineSize;
						printStats();
						saveHeaderFile();
						firstframe = false;
						wait();
					}

					run(); 

					while (tex.getCollectedFrameCount() == 1)
						;

					while (tex.getCollectedFrameCount() < 1)
						;

					stop();

					//tex.getCineStart(0)+averagingN*lineSize
					//short * avg = 
					average((short *) tex.getCineStart(0), lineSize/2, averagingN);
					//transferLine((char * ) avg);	
					transferLine(tex.getCineStart(0));
				}
			}

			frameSize = 128*numOfScanlines/totalParts*lineSize;

			std::stringstream ss;
			ss << "rfdata/";
			ss << baseName;
			ss << "_p";
			ss << part+1;
			if (mf) {
				ss << "f";
				ss << j+1;
			}

			saveData(ss.str());

			if (!mf) 
				break;
		}
	}

	return true;
}

bool saveData() {

	char path[100];

	printf("enter a filename: ");
	scanf("%s", path);

	saveData(path);

	return true;
}

// store data to disk
bool saveData(std::string path) {

	FILE * fp;

	//printf("saving data to file ... ");

	/*
	if(numFrames < 1)
	{
	printf("[failed]\n");
	fprintf(stderr, "no frames have been acquired\n");
	return false;
	}
	*/

	fp = fopen(path.c_str(), "wb+");
	if(!fp)
	{
		printf("[failed]\n");
		fprintf(stderr, "could not store data to specified path\n");
		return false;
	}

	fwrite(buffer, frameSize, 1, fp);
	fclose(fp);
	//printf("[ok!]\n");

	return true;
}

bool saveHeaderFile() {

	FILE * fp;
	std::stringstream ss;

	h.frameSize = frameSize;
	h.linesPerFrame = numOfScanlines/totalParts*128;
	h.totalParts = totalParts;
	h.beamformed = beamformed;
	h.focus1 = focus[0];
	h.focus2 = focus[1];
	h.focus3 = focus[2];

	ss << "rfdata/";
	ss << baseName;

	fp = fopen(ss.str().c_str(), "wb+");
	fwrite(baseName, 1, 50, fp);
	fwrite(&h, sizeof(h), 1, fp);
	fclose(fp);

	return true;
}
// selects a probe
bool selectProbe(int connector) {    

	if(!tex.activateProbeConnector(connector))
	{
		fprintf(stderr, "\ncould not activate connector %d\n", connector);
		return false;
	}

	validprobe = true;
	return true;
}

// statistics printout for after sequence has been loaded
void printStats() {

	// print out sequence statistics
	printf("sequence statistics:\n");
	//printf("frame size = %d bytes\n", tex.getFrameSize());
	printf("frame size = %d bytes\n", frameSize);
	printf("lines per frame = %d\n", numOfScanlines/totalParts);
	printf("bytes per line = %d\n", lineSize);
	printf("total number of frames = %d\n", totalParts);
	//printf("frame rate= %.1f fr/sec\n", tex.getFrameRate());
	//printf("buffer size = %d frames\n", tex.getMaxFrameCount()); 
	//printf("probe center frequency = %d\n\n", tex.getProbeCenterFreq());
}

bool createSequence(int sequence) {  

	if(!validprobe)
	{
		fprintf(stderr, "\ncannot create sequence, no probe selected\n");
		return false;
	}

	printf("enter desired depth in mm (10 - 300):\n");
	scanf("%d", &depth);    
	if(depth < 10 || depth > 300)
	{
		fprintf(stderr, "invalid depth entered\n");
		return false;
	}

	// tell program to initialize for new sequence
	if(!tex.beginSequence())
		return false;

	switch (sequence) {
		case 1:
			if (!sequenceBf())
				return false;
			break;
	}

	// tell program to finish sequence
	if(tex.endSequence() == -1)
		return false;

	printStats();

	validsequence = true;
	return true;
}

// runs a sequence
bool run() {

	if(!validsequence){
		fprintf(stderr, "cannot run, no sequence selected\n");
		return false;
	}

	if(running){
		fprintf(stderr, "sequence is already running\n");
		return false;
	}

	if(tex.runImage()){
		running = true;
		return true;
	}

	return false;
}

// stops a sequence from running
bool stop() {
	if(!running){
		fprintf(stderr, "nothing to stop, sequence is not running\n");
		return false;
	}

	if(tex.stopImage()){
		running = false;        
		//fprintf(stdout, "acquired (%d) frames\n", tex.getCollectedFrameCount());
		return true;
	}

	return false;
}

// called when a new frame is received
bool newImage(void *, unsigned char * /*data*/, int /*frameID*/) {  

	// withhold from printing out anything right now 
	return true;
}

void wait() {

	printf("\npress any key to continue\n");
	while(!_kbhit());
	_getch();
	fflush(stdin);
	//system("cls");
}

void clearLine() {

	printf("\r");
	printf("                                                  \r");
}