/*!
 * \file MedianFilter.cpp
 * \brief Mean filter.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#include "MeanFilter.h"



MeanFilter::~MeanFilter(void)
{
}
	
MeanFilter::MeanFilter(cl_context GPUContext ,GPUTransferManager* transfer): LowpassFilter("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\BlurGaussFilter.cl","ckConv")
{

	// gauss

	

	// -----

	LowpassFilter::onInit(GPUContext,transfer);
}
