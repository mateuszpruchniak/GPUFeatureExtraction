/*!
 * \file LowpassFilter.h
 * \brief Lowpass filters.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#pragma once
#include "linearfilter.h"

/*!
 * \class LowpassFilter
 * \brief Low pass filtering, otherwise known as "smoothing", is employed to remove high spatial frequency noise from a digital image.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */
class LowpassFilter :
	public LinearFilter
{
protected:

	/*!
	* Pointer to mask.
	*/
	int* mask;

	/*!
	* OpenCL device memory input buffer for mask.
	*/
	cl_mem cmDevBufMask;

	/*!
	* Load mask to buffer.
	*/
	void LoadMask(int* mask, int count,GPUTransferManager* transfer);


	

public:

	/*!
	* Destructor.
	*/
	~LowpassFilter(void);

	/*!
	* Constructor,loads the source code (.cl files).
	*/
	LowpassFilter(char* source,char* KernelName);

	/*!
	* Start filtering. Launching GPU processing.
	*/
	bool filter(cl_command_queue GPUCommandQueue, float s);


	bool filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b);

	bool filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c);

	int maskSize;

};

