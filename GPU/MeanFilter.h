

#pragma once

#include "../GPUBase.h"


class MeanFilter :
	public GPUBase
{
public:

	/*!
	* Destructor.
	*/
	~MeanFilter(void);

	/*!
	* Constructor.
	*/
	MeanFilter();
	
	bool Process(int sigma);
};

