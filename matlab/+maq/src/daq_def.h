////////////////////////////////////////////////////////////////////////////////
///@file daq_def.h
////////////////////////////////////////////////////////////////////////////////
#pragma once

#define DEVICE_HEALTH_TEMPS 4
#define DEVICE_HEALTH_VOLTS 28
#define TGC_POINTS          3

enum EAdvancedFunction
{
    advEnableI2C = 0,
    advDisableI2C = 1,
    advDDR2Test,
    advFlipStartBit,
    advResetUSBFifo,
    advEmptyFifo,
    advResetFPGA,
    advResetDCM,
    advResetRxFPGA,
    advProgramRxPhase,
    advProgramRxClock,
    advReadDevice,
    advWriteDevice,
    advReadUsbReg,
    advWriteUsbReg
};

enum ELedMode
{
    ledTrigger = 0x80,
    ledInit = 0x00,
    ledAcquire = 0x01,
    ledDownload = 0x02,
    ledIdle = 0x03,
    ledError = 0x04,
    ledStop = 0x05
};

enum EUSBRegister
{
    usbControl      = 0x08,
    usbNoTimeout    = 0x10,
    usbFIFOStatus   = 0x17,
    usbAccessRAM    = 0x20,
    usbRXReset      = 0x21,
    usbRXStatus     = 0x22,
    usbRXFull       = 0x23
};

enum EDeviceID
{
    eV5Reg      = 0x00,
    eSEQSRAM    = 0x01,
    eCTSRAM        = 0x02,
    eRX1Reg        = 0x03,
    eRX1SRAM1    = 0x04,
    eRX1SRAM2    = 0x05,
    eRX2Reg        = 0x06,
    eRX2SRAM1    = 0x07,
    eRX2SRAM2    = 0x08,
    eRX3Reg        = 0x09,
    eRX3SRAM1    = 0x0A,
    eRX3SRAM2    = 0x0B,
    eRX4Reg        = 0x0C,
    eRX4SRAM1    = 0x0D,
    eRX4SRAM2    = 0x0E,
    eRXPStart    = 0x0F,
    eRXPProg    = 0x10,
    eRXPEnd        = 0x11,
    eRXRegAll    = 0x12
};

/// Sources of a callback.
enum ECallbackSources
{
    /// Called from the initialization stage.
    eCbInit = 0,
    /// Called while downloading data.
    eCbDownload = 1,
    /// Called when the buffers are full after an acquisition.
    eCbBuffersFull
};

/// Callback function for monitoring progress of various functions
/// @param[in]      prm The parameter to be provided back to the callback.
/// @param[in]      info The information passed back on progress, typically the percentage complete.
/// @param[in]      src The source of the callback..
typedef void (*DAQ_CALLBACK)(void* prm, int info, ECallbackSources src);

/// The parameters that are applied to the full DAQ sequence, and not per line
struct daqSequencePrms
{
    /// Set to 1 if running continually, 0 if the acquisition should stop before filling up the memory buffer
    int freeRun;
    /// The divisor used to set the memory buffer size.
    /// 4GB per board divided by 2^divisor.
    /// 0 for 4GB per board, 1 for 2GB per board, 2 for 1GB per board, etc.
    unsigned char divisor;
    /// Set to 1 to bypass the high-pass filter on the ADC's
    int hpfBypass;
    /// Set to 1 to use an external trigger from the Sonix system or another device, 0 to use the internal trigger.
    /// The internal trigger is based on the line duration of each rayline, once the duration expires, the next line is immediately started.
    int externalTrigger;
    /// Set to 1 to use an external clock provided from the Sonix system, 0 to use the internal 40MHz clock.
    /// To prevent jitter between frames, the external clock should be used.
    int externalClock;
    /// Set to 1 to use a fixed TGC, 0 to use the curve value provided as in the daqTGC structure.
    int fixedTGC;
    /// The fixed TGC level if fixedTGC is set to true.
    int fixedTGCLevel;
    /// The LNA gain.
    int lnaGain;
    /// The PGA gain.
    int pgaGain;
    /// The Bias Current setting.
    int biasCurrent;
};

/// The rayline parameters applied to each DAQ acquisition.
struct daqRaylinePrms
{
    /// A pointer to 4 32-bit integers specifying what channels are active on each board for the specific receive.
    unsigned int* channels;
    /// The delay used before loading the gain.
    int gainDelay;
    /// The offset into the gain table.
    int gainOffset;
    /// The line duration to use, note that it should at least be the time it takes to capture the number of samples supplied by numSamples.
    int lineDuration;
    /// The number of samples to capture. The lineDuration parameter should not be less than the time it takes to capture the number of samples set.
    int numSamples;
    /// The receive delay used to delay the capture of data after the start signal for the rayline.
    int rxDelay;
    /// The decimation used to capture data, based on the sampling frequency.
    unsigned char decimation;
    /// The sampling frequency used based on the firmware chosen (40 or 80MHz).
    unsigned char sampling;
};
