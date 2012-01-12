
#include "DetectExtrema.h"



DetectExtrema::~DetectExtrema(void)
{
}

DetectExtrema::DetectExtrema(): GPUBase("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\DetectExtrema.cl","ckDetect")
{

}


bool DetectExtrema::Process( int* num, int* numRej, float prelim_contr_thr, int intvl )
{

	int maxNumberKeys = 1000;
	Keys keys[1000];

	for (int i =0 ; i < maxNumberKeys ; i++)
	{
		keys[i].x = 0.0;
		keys[i].y = 0.0;
		keys[i].mag = 0.0;
		keys[i].orien = 0.0;
		keys[i].scale = 0.0;
	}


	cl_mem cmDevBufNumber = clCreateBuffer(GPUContext, CL_MEM_READ_WRITE, sizeof(int), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufNumber, CL_TRUE, 0, sizeof(int), (void*)num, 0, NULL, NULL);
	CheckError(GPUError);

	cl_mem cmDevBufNumberReject = clCreateBuffer(GPUContext, CL_MEM_READ_WRITE, sizeof(int), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufNumberReject, CL_TRUE, 0, sizeof(int), (void*)numRej, 0, NULL, NULL);
	CheckError(GPUError);

	int count = 0;
	cl_mem cmDevBufCount = clCreateBuffer(GPUContext, CL_MEM_READ_WRITE, sizeof(int), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufCount, CL_TRUE, 0, sizeof(int), (void*)&count, 0, NULL, NULL);
	CheckError(GPUError);

	cl_mem cmDevBufKeys = clCreateBuffer(GPUContext, CL_MEM_READ_WRITE, maxNumberKeys*sizeof(Keys), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufKeys, CL_TRUE, 0, sizeof(int), (void*)&keys, 0, NULL, NULL);
	CheckError(GPUError);

	size_t GPULocalWorkSize[2];
	GPULocalWorkSize[0] = iBlockDimX;
	GPULocalWorkSize[1] = iBlockDimY;
	GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)imageWidth);
	GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)imageHeight);
	
	int iLocalPixPitch = iBlockDimX + 2;
	GPUError = clSetKernelArg(GPUKernel, 0, sizeof(cl_mem), (void*)&buffersListIn[0]);
	GPUError |= clSetKernelArg(GPUKernel, 1, sizeof(cl_mem), (void*)&buffersListIn[1]);
	GPUError |= clSetKernelArg(GPUKernel, 2, sizeof(cl_mem), (void*)&buffersListIn[2]);
	GPUError |= clSetKernelArg(GPUKernel, 3, sizeof(cl_mem), (void*)&buffersListOut[0]);
	GPUError |= clSetKernelArg(GPUKernel, 4, sizeof(cl_mem), (void*)&cmDevBufCount);
	GPUError |= clSetKernelArg(GPUKernel, 5, sizeof(cl_mem), (void*)&cmDevBufKeys);
	GPUError |= clSetKernelArg(GPUKernel, 6, sizeof(cl_uint), (void*)&imageWidth);
	GPUError |= clSetKernelArg(GPUKernel, 7, sizeof(cl_uint), (void*)&imageHeight);
	GPUError |= clSetKernelArg(GPUKernel, 8, sizeof(cl_float), (void*)&prelim_contr_thr);
	GPUError |= clSetKernelArg(GPUKernel, 9, sizeof(cl_uint), (void*)&intvl);
	GPUError |= clSetKernelArg(GPUKernel, 10, sizeof(cl_mem), (void*)&cmDevBufNumber);
	GPUError |= clSetKernelArg(GPUKernel, 11, sizeof(cl_mem), (void*)&cmDevBufNumberReject);
	if(GPUError) return false;

	if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUKernel, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;


	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufNumber, CL_TRUE, 0, sizeof(int), (void*)num, 0, NULL, NULL);
	CheckError(GPUError);
	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufNumberReject, CL_TRUE, 0, sizeof(int), (void*)numRej, 0, NULL, NULL);
	CheckError(GPUError);

	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufCount, CL_TRUE, 0, sizeof(int), (void*)&count, 0, NULL, NULL);
	CheckError(GPUError);
	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufKeys, CL_TRUE, 0, maxNumberKeys*sizeof(Keys), (void*)&keys, 0, NULL, NULL);
	CheckError(GPUError);

	cout << "Number GPU: " << *num << endl;
	cout << "Number reject GPU: " << *numRej << endl;

	return true;
}
