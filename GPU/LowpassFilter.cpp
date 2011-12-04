/*!
 * \file LowpassFilter.cpp
 * \brief Lowpass filters.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */


#include "LowpassFilter.h"

LowpassFilter::~LowpassFilter(void)
{
	if(cmDevBufMask)clReleaseMemObject(cmDevBufMask);
}


LowpassFilter::LowpassFilter(char* source, char* KernelName): LinearFilter(source,KernelName)
{

}


bool LowpassFilter::filter(cl_command_queue GPUCommandQueue, float sigma)
{
	maskSize = cvRound(sigma * 3 * 2 + 1) | 1;
	size_t GPULocalWorkSize[2];
	GPULocalWorkSize[0] = iBlockDimX;
	GPULocalWorkSize[1] = iBlockDimY;
	GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)GPUTransfer->ImageWidth);
	GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)GPUTransfer->ImageHeight);
	
	int iLocalPixPitch = iBlockDimX + 2;
	GPUError = clSetKernelArg(GPUFilter, 0, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf);
	GPUError = clSetKernelArg(GPUFilter, 1, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBufOutput);
	GPUError |= clSetKernelArg(GPUFilter, 2, sizeof(cl_uint), (void*)&GPUTransfer->ImageWidth);
	GPUError |= clSetKernelArg(GPUFilter, 3, sizeof(cl_uint), (void*)&GPUTransfer->ImageHeight);
	GPUError |= clSetKernelArg(GPUFilter, 4, sizeof(cl_int), (void*)&GPUTransfer->nChannels);
	GPUError |= clSetKernelArg(GPUFilter, 5, sizeof(cl_float), (void*)&sigma);
	GPUError |= clSetKernelArg(GPUFilter, 6, sizeof(cl_int), (void*)&maskSize);
	if(GPUError) return false;

	if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUFilter, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;
	return true;
}


bool LowpassFilter::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b)
{
	
	return false;
}


bool LowpassFilter::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c)
{
	
	return false;
}


void LowpassFilter::LoadMask(int* mask,int count,GPUTransferManager* transfer)
{
	cout << "LoadMask" << endl;
	// Create the device buffers in GMEM on each device, for now we have one device :)
    cmDevBufMask = clCreateBuffer(transfer->GPUContext, CL_MEM_READ_WRITE, count * sizeof (unsigned int), NULL, &GPUError);
    CheckError(GPUError);

    GPUError = clEnqueueWriteBuffer(transfer->GPUCommandQueue, cmDevBufMask, CL_TRUE, 0, count * sizeof (unsigned int), (void*)mask, 0, NULL, NULL);
    CheckError(GPUError);
}
