#include "Ivpax.h"

/* MAIN */
int main() {

	Ivpax * ivp = new Ivpax();
	Sequence * seq = NULL;
	
	while (true) {

		try {
			
			system("cls");
			ivp->selectionMenu();
			seq = ivp->seqInit(); 

			if (seq == NULL)
				break;

			system("cls");
			ivp->queryTexoParams();

			system("cls");
			ivp->texoInit();
			
			ivp->wait();

			system("cls");
			seq->querySequenceParams();

			system("cls");
			ivp->printStats(seq);

			ivp->wait();

			system("cls");
			ivp->run(seq);

		} catch (std::exception & e){

			system("cls");
			printf("\nERROR: "); printf(e.what());
		} 

		ivp->shutdown();
		ivp->wait();
	}

	ivp->shutdown();
	delete seq;
	delete ivp;
	return 0;
}

/* METHODS */
void Ivpax::shutdown() {

	//tex.stopImage();
	tex.shutdown();
}
void Ivpax::selectionMenu() {

	printf("SELECTION MENU\n\n");
	printf("Sequence: \n");
	printf("(1) Averaged Non-BeamFormed RF \n");
	printf("(2) Non-BeamFormed RF \n");
	printf("(3) Spatial Compounding RF \n");
	printf("(4) Averaged Photoacoustic RF \n");
	printf("(5) Noise Sequence \n");
	printf("(x) Exit \n");
	scanf("%c", &tprm.sequenceSelect); 
}
void Ivpax::queryTexoParams() {

	printf("TEXO PARAMETERS\n\n");
	printf("Transmit power (1-15): \n"); 
	scanf("%d", &tprm.power);

	printf("Analog gain (0-100): \n"); 
	scanf("%d", &tprm.gain);

	printf("Transmit on/off (1/0): \n"); 
	scanf("%d", &tprm.transmitOn);

	printf("Image depth in mm (10-300):\n"); 
	scanf("%d", &tprm.imageDepth);

	int focusDepth;
	printf("Transmit focus depth in mm (10-300, 300=plane):\n"); 
	scanf("%d", &focusDepth); tprm.focusDepth = 1000*focusDepth;

	printf("Sync signal on/off (1/0): \n");
	scanf("%d", &tprm.syncOn);
}

Sequence * Ivpax::seqInit() {

	switch (tprm.sequenceSelect) {

		case '1': { AveragedNonBFSequence * seq = new AveragedNonBFSequence(&tex, &tx, &rx, &buf); return seq; }
		case '2': { NonBFSequence * seq = new NonBFSequence(&tex, &tx, &rx, &buf); return seq; }
		case '3': { SpatialCompoundingSequence * seq = new SpatialCompoundingSequence(&tex, &tx, &rx, &buf); return seq; }
		case '4': { AveragedPASequence * seq = new AveragedPASequence(&tex, &tx, &rx, &buf); return seq; }
		case '5': { NoiseSequence * seq = new NoiseSequence(&tex, &tx, &rx, &buf); return seq; } 
		case 'x': return NULL;
		default: return NULL;
	}
}

void Ivpax::texoInit() {

	printf("TEXO INITIALIZATION\n\n");
	printf("Initializing ... ");

	if (!tex.init("../dat/", 3, 3, 0, 64, 3, 128))
		throw Error("TEXO could not be initialized"); //E
	printf("[OK]\n");

	tex.setCallback(newImage, 0);
	tex.setPower(tprm.power, tprm.power, tprm.power);
	tprm.syncOn ? tex.setSyncSignals(1,1,0) : tex.setSyncSignals(0,0,0);

	printf("Setting analog gain and TGC ...");
	tex.clearTGCs();
	CURVE tgc1;
	tgc1.top = tprm.gain;
	tgc1.mid = tprm.gain;
	tgc1.btm = tprm.gain;
	tgc1.vmid = 50;
	tex.addTGC(&tgc1, 100000);
	printf("[OK]\n");

	printf("Activating probe on connector 0 ...");
	if (!tex.activateProbeConnector(0))
		throw Error("Probe could not be activated"); //E
	printf("[OK]\n");

	printf("Defining transmit parameters ...");
	tx.centerElement = 0;
	tx.aperture = 64;
	tx.focusDistance = tprm.focusDepth; // in microns
	tx.angle = 0;
	tx.frequency = 6600000;
	tprm.transmitOn ? strcpy(tx.pulseShape, "+-") : strcpy(tx.pulseShape, "00");
	tx.speedOfSound = 1482;
	tx.useManualDelays = false;
	tx.tableIndex = -1;
	tx.useDeadElements = false;
	tx.trex = false;
	printf("[OK]\n");

	printf("Defining receive parameters ...");
	rx.centerElement = 0;
	rx.aperture = 0;
	rx.angle = 0;
	rx.maxApertureDepth = tprm.focusDepth; // in microns
	rx.acquisitionDepth = tprm.imageDepth * 1000;
	rx.saveDelay = 0;
	rx.speedOfSound = 1482;
	rx.applyFocus = false;
	rx.useManualDelays = false;
	rx.decimation = 0;
	rx.customLineDuration = 0;
	rx.lgcValue = 0;
	rx.tgcSel = 0;
	rx.tableIndex = -1;
	rx.numChannels = 64;
	rx.channelMask[0] = rx.channelMask[1] = 0xFFFFFFFF;
	printf("[OK]\n");
}

void Ivpax::run(Sequence * seq) {

	seq->collectSequence();
}

void Ivpax::printStats(Sequence * seq) {

	seq->printStats();
}

void Ivpax::wait() {

	printf("\nPress any key to continue\n");
	while(!_kbhit());
	_getch();
	fflush(stdin);
}