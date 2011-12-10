﻿

#include "Magnitude.h"

Magnitude::~Magnitude(void)
{
}

Magnitude::Magnitude(cl_context GPUContext ,GPUTransferManager* transfer): ContextFilter("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\Magnitude.cl","ckMagn")
{
	Filter::onInit(GPUContext,transfer);
	number = 0;
	numberReject = 0;

}




bool Magnitude::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c )
{
	return false;
}

bool Magnitude::filter(cl_command_queue GPUCommandQueue, float sigma = 0)
{
	size_t GPULocalWorkSize[2];
	GPULocalWorkSize[0] = iBlockDimX;
	GPULocalWorkSize[1] = iBlockDimY;
	GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)GPUTransfer->ImageWidth);
	GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)GPUTransfer->ImageHeight);

	int iLocalPixPitch = iBlockDimX + 2;
	GPUError = clSetKernelArg(GPUFilter, 0, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf);
	GPUError |= clSetKernelArg(GPUFilter, 1, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBufOutput);
	GPUError |= clSetKernelArg(GPUFilter, 2, sizeof(cl_uint), (void*)&GPUTransfer->ImageWidth);
	GPUError |= clSetKernelArg(GPUFilter, 3, sizeof(cl_uint), (void*)&GPUTransfer->ImageHeight);

	if(GPUError) return false;

	if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUFilter, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;



	return true;
}

bool Magnitude::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b)
{
	return false;
}