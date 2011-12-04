

#pragma once
#include "contextfreefilter.h"



class Subtract :
	public ContextFreeFilter
{
public:

	/*!
	* Destructor.
	*/
	~Subtract(void);

	/*!
	* Constructor, creates a program object for a context, loads the source code (.cl files) and build the program.
	*/
	Subtract(cl_context GPUContext ,GPUTransferManager* transfer);

	/*!
	* Start
	*/
	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b );

	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b, IplImage* c );

	bool filter(cl_command_queue GPUCommandQueue, float s);
};
