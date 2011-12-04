

#include "DetectExtrema.h"

DetectExtrema::~DetectExtrema(void)
{
}

DetectExtrema::DetectExtrema(cl_context GPUContext ,GPUTransferManager* transfer): ContextFreeFilter("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\DetectExtrema.cl","ckDetect")
{
	Filter::onInit(GPUContext,transfer);
}




bool DetectExtrema::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c )
{

	GPUTransfer->SendImage(a);

	
	// wyslalenie drugiego obrazku !!!!!! poprawic!
	int ImageHeight = b->height;
	int ImageWidth = b->width;
	int szBuffBytesLocal = ImageWidth * ImageHeight * 4 * sizeof (char);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, GPUTransfer->cmDevBuf2, CL_TRUE, 0, szBuffBytesLocal, (void*)b->imageData, 0, NULL, NULL);
	CheckError(GPUError);

	// wyslalenie trzeciego obrazku !!!!!! poprawic!
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, GPUTransfer->cmDevBuf3, CL_TRUE, 0, szBuffBytesLocal, (void*)c->imageData, 0, NULL, NULL);
    CheckError(GPUError);


	size_t GPULocalWorkSize[2];
	GPULocalWorkSize[0] = iBlockDimX;
	GPULocalWorkSize[1] = iBlockDimY;
	GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)GPUTransfer->ImageWidth);
	GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)GPUTransfer->ImageHeight);
	

	int iLocalPixPitch = iBlockDimX + 2;
	GPUError = clSetKernelArg(GPUFilter, 0, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf);
	GPUError = clSetKernelArg(GPUFilter, 1, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf2);
	GPUError = clSetKernelArg(GPUFilter, 2, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf3);
	GPUError = clSetKernelArg(GPUFilter, 3, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBufOutput);
	GPUError |= clSetKernelArg(GPUFilter, 4, sizeof(cl_uint), (void*)&GPUTransfer->ImageWidth);
	GPUError |= clSetKernelArg(GPUFilter, 5, sizeof(cl_uint), (void*)&GPUTransfer->ImageHeight);
	GPUError |= clSetKernelArg(GPUFilter, 6, sizeof(cl_int), (void*)&GPUTransfer->nChannels);
	if(GPUError) return false;

	if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUFilter, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;
	return true;
}

bool DetectExtrema::filter(cl_command_queue GPUCommandQueue, float sigma)
{
	return false;
}

bool DetectExtrema::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b)
{
	return false;
}