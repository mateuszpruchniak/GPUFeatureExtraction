﻿/*!
 * \file LinearFilter.h
 * \brief Linear filters.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */


#pragma once
#include "contextfilter.h"

/*!
 * \class LinearFilter
 * \brief Linear filters. In linear filters the output pixel value is a result of a linear combination on input pixels below the mask.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */
class LinearFilter :
	public ContextFilter
{
public:


	/*!
	* Destructor.
	*/
	~LinearFilter(void);

	/*!
	* Constructor.
	*/
	LinearFilter(char* source, char* KernelName);

};

