

#pragma once
#include "ContextFilter.h"



class Magnitude :
	public ContextFilter
{
public:

	/*!
	* Destructor.
	*/
	~Magnitude(void);

	/*!
	* Constructor, creates a program object for a context, loads the source code (.cl files) and build the program.
	*/
	Magnitude(cl_context GPUContext ,GPUTransferManager* transfer);

	int number;

	int numberReject;

	/*!
	* Start
	*/
	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b, IplImage* c );

	bool filter(cl_command_queue GPUCommandQueue,  IplImage* a, IplImage* b);

	bool filter(cl_command_queue GPUCommandQueue, float s);
};
