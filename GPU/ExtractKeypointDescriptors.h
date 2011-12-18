

#pragma once

#include "../GPUBase.h"


class ExtractKeypointDescriptors :
	public GPUBase
{
public:

	/*!
	* Destructor.
	*/
	~ExtractKeypointDescriptors(void);

	/*!
	* Constructor, creates a program object for a context, loads the source code (.cl files) and build the program.
	*/
	ExtractKeypointDescriptors();

	bool Process();

};