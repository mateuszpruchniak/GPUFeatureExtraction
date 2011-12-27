

#pragma once

#include "../GPUBase.h"


class DetectExtrema :
	public GPUBase
{
public:

	/*!
	* Destructor.
	*/
	~DetectExtrema(void);

	/*!
	* Constructor.
	*/
	DetectExtrema();
	
	bool Process(int* num, int* numRej);
};

