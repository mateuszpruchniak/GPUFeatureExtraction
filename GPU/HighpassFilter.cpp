/*!
 * \file HighpassFilter.cpp
 * \brief Highpass filters.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#include "HighpassFilter.h"


HighpassFilter::~HighpassFilter(void)
{
	if(cmDevBufMaskV)clReleaseMemObject(cmDevBufMaskV);
	if(cmDevBufMaskH)clReleaseMemObject(cmDevBufMaskH);
}

HighpassFilter::HighpassFilter(char* source, char* KernelName): NonLinearFilter(source,KernelName)
{
	
}

bool HighpassFilter::filter(cl_command_queue GPUCommandQueue)
{

    int iLocalPixPitch = iBlockDimX + 2;
    GPUError = clSetKernelArg(GPUFilter, 0, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf);
    GPUError = clSetKernelArg(GPUFilter, 1, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBufOutput);
	GPUError |= clSetKernelArg(GPUFilter, 2, sizeof(cl_mem), (void*)&cmDevBufMaskV);
	GPUError |= clSetKernelArg(GPUFilter, 3, sizeof(cl_mem), (void*)&cmDevBufMaskH);
	GPUError |= clSetKernelArg(GPUFilter, 4, ( maskSize * sizeof(int)), NULL);
	GPUError |= clSetKernelArg(GPUFilter, 5, ( maskSize * sizeof(int)), NULL);
    GPUError |= clSetKernelArg(GPUFilter, 6, sizeof(cl_int), (void*)&maskSize);
    GPUError |= clSetKernelArg(GPUFilter, 7, sizeof(cl_uint), (void*)&GPUTransfer->ImageWidth);
    GPUError |= clSetKernelArg(GPUFilter, 8, sizeof(cl_uint), (void*)&GPUTransfer->ImageHeight);
	GPUError |= clSetKernelArg(GPUFilter, 9, sizeof(cl_int), (void*)&GPUTransfer->nChannels);
	GPUError |= clSetKernelArg(GPUFilter, 10, sizeof(cl_int), (void*)&maskDim);
    if(GPUError) return false;
	size_t GPULocalWorkSize[2]; 
    GPULocalWorkSize[0] = iBlockDimX;
    GPULocalWorkSize[1] = iBlockDimY;
    GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)GPUTransfer->ImageWidth);
    GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)GPUTransfer->ImageHeight);
    cout << GPUGlobalWorkSize[0] << "x" << GPUGlobalWorkSize[1] << endl;
    if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUFilter, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;
	return true;
}


void HighpassFilter::LoadMask(cl_mem* cmDevBufMask,int* mask,int count,GPUTransferManager* transfer)
{
	// Create the device buffers in GMEM on each device, for now we have one device :)
    *cmDevBufMask = clCreateBuffer(transfer->GPUContext, CL_MEM_READ_WRITE, count * sizeof (unsigned int), NULL, &GPUError);
    CheckError(GPUError);

    GPUError = clEnqueueWriteBuffer(transfer->GPUCommandQueue, *cmDevBufMask, CL_TRUE, 0, count * sizeof (unsigned int), (void*)mask, 0, NULL, NULL);
    CheckError(GPUError);
}
