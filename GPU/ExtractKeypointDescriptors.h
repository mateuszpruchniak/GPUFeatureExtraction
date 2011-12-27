

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
	* Constructor.
	*/
	ExtractKeypointDescriptors();

	bool Process();

};