#include "dblBuffer.h"

/* CONSTRUCTORS & DESTRUCTORS */
dblBuffer::dblBuffer() {

	pos = 0;
	size = 256 * 1024 * 1024;
	start = new unsigned char [size];
}

dblBuffer::dblBuffer(int _size) {

	pos = 0;
	size = _size;
	start = new unsigned char [size];
}

dblBuffer::~dblBuffer() {
	
	delete start;
}

/* METHODS */
void dblBuffer::transferFrame(unsigned char * data, int frameSize) {

	if(pos > size - frameSize)
		pos = 0;

	memcpy(start + pos, data, frameSize);
	pos += frameSize;
}

void dblBuffer::transferLine(unsigned char * data, int lineSize) {

	if(pos > size - lineSize)
		pos = 0;

	memcpy(start + pos, data, lineSize);
	pos += lineSize;
}

void dblBuffer::saveToFile(std::string path) {

	FILE * fp;

	fp = fopen(path.c_str(), "wb+");

	//if(!fp)
		//throw Error("Could not save buffer to file");

	fwrite(start, pos, 1, fp);
	fclose(fp);
}
