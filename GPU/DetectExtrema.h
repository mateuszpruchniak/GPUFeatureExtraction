

#pragma once
#include "contextfreefilter.h"



class DetectExtrema :
	public ContextFreeFilter
{
public:

	/*!
	* Destructor.
	*/
	~DetectExtrema(void);

	/*!
	* Constructor, creates a program object for a context, loads the source code (.cl files) and build the program.
	*/
	DetectExtrema(cl_context GPUContext ,GPUTransferManager* transfer);

	int number;

	/*!
	* Start
	*/
	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b, IplImage* c );

	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b);

	bool filter(cl_command_queue GPUCommandQueue, float s);
};
