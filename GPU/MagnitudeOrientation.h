


#pragma once

#include "../GPUBase.h"


class MagnitudeOrientation :
	public GPUBase
{
public:

	/*!
	* Destructor.
	*/
	~MagnitudeOrientation(void);

	/*!
	* Constructor.
	*/
	MagnitudeOrientation();
	
	bool Process();
};