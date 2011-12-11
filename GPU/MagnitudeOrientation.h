

#pragma once
#include "ContextFilter.h"



class MagnitudeOrientation :
	public ContextFilter
{
public:

	/*!
	* Destructor.
	*/
	~MagnitudeOrientation(void);

	/*!
	* Constructor, creates a program object for a context, loads the source code (.cl files) and build the program.
	*/
	MagnitudeOrientation(cl_context GPUContext ,GPUTransferManager* transfer);

	int number;

	int numberReject;

	/*!
	* Start
	*/
	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b, IplImage* c, float sigma = 0 );

	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b);

	bool filter(cl_command_queue GPUCommandQueue, float s);

	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b, IplImage* c, IplImage* d, float sigma = 0);
};
