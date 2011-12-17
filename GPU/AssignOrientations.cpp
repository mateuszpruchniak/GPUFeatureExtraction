

#include "AssignOrientations.h"

AssignOrientations::~AssignOrientations(void)
{
}

AssignOrientations::AssignOrientations(cl_context GPUContext ,GPUTransferManager* transfer): ContextFilter("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\AssignOrientations.cl","AssignOrient")
{
	Filter::onInit(GPUContext,transfer);
	number = 0;
	numberReject = 0;

}

bool AssignOrientations::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c, IplImage* d, float sigma )
{
	maskSize = GetKernelSize(sigma);

	GPUTransfer->SendImageData(a->imageData,a->height,a->width);


	// wyslalenie drugiego obrazku !!!!!! poprawic!
	int ImageHeight = b->height;
	int ImageWidth = b->width;
	int szBuffBytesLocal = ImageWidth * ImageHeight * 4 * sizeof (char);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, GPUTransfer->cmDevBuf2, CL_TRUE, 0, szBuffBytesLocal, (void*)b->imageData, 0, NULL, NULL);
	CheckError(GPUError);

	// wyslalenie trzeciego obrazku !!!!!! poprawic!
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, GPUTransfer->cmDevBuf3, CL_TRUE, 0, szBuffBytesLocal, (void*)c->imageData, 0, NULL, NULL);
	CheckError(GPUError);

	// wyslalenie  !!!!!! poprawic!
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, GPUTransfer->cmDevBuf4, CL_TRUE, 0, szBuffBytesLocal, (void*)d->imageData, 0, NULL, NULL);
	CheckError(GPUError);


	Keys keys[36*700];

	for (int i =0 ; i < 36*700 ; i++)
	{
		keys[i].x = 0.0;
		keys[i].y = 0.0;
		keys[i].mag = 0.0;
		keys[i].orien = 0.0;
		keys[i].scale = 0.0;
	}



	int count = 0;


	cl_mem cmDevBufCount = clCreateBuffer(GPUTransfer->GPUContext, CL_MEM_READ_WRITE, sizeof(int), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufCount, CL_TRUE, 0, sizeof(int), (void*)&count, 0, NULL, NULL);
	CheckError(GPUError);


	cl_mem cmDevBufKeys = clCreateBuffer(GPUTransfer->GPUContext, CL_MEM_READ_WRITE, 700*36*sizeof(Keys), NULL, &GPUError);
	CheckError(GPUError);
	GPUError = clEnqueueWriteBuffer(GPUCommandQueue, cmDevBufKeys, CL_TRUE, 0, sizeof(int), (void*)&keys, 0, NULL, NULL);
	CheckError(GPUError);



	size_t GPULocalWorkSize[2];
	GPULocalWorkSize[0] = iBlockDimX;
	GPULocalWorkSize[1] = iBlockDimY;
	GPUGlobalWorkSize[0] = shrRoundUp((int)GPULocalWorkSize[0], (int)GPUTransfer->ImageWidth);
	GPUGlobalWorkSize[1] = shrRoundUp((int)GPULocalWorkSize[1], (int)GPUTransfer->ImageHeight);

	int iLocalPixPitch = iBlockDimX + 2;
	GPUError = clSetKernelArg(GPUFilter, 0, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf);
	GPUError |= clSetKernelArg(GPUFilter, 1, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf2);
	GPUError |= clSetKernelArg(GPUFilter, 2, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf3);
	GPUError |= clSetKernelArg(GPUFilter, 3, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBuf4);
	GPUError |= clSetKernelArg(GPUFilter, 4, sizeof(cl_mem), (void*)&cmDevBufCount);
	GPUError |= clSetKernelArg(GPUFilter, 5, sizeof(cl_mem), (void*)&cmDevBufKeys);
	GPUError |= clSetKernelArg(GPUFilter, 6, sizeof(cl_mem), (void*)&GPUTransfer->cmDevBufOutput);
	GPUError |= clSetKernelArg(GPUFilter, 7, sizeof(cl_uint), (void*)&a->width);
	GPUError |= clSetKernelArg(GPUFilter, 8, sizeof(cl_uint), (void*)&a->height);
	GPUError |= clSetKernelArg(GPUFilter, 9, sizeof(cl_float), (void*)&maskSize);
	if(GPUError) return false;

	if(clEnqueueNDRangeKernel( GPUCommandQueue, GPUFilter, 2, NULL, GPUGlobalWorkSize, GPULocalWorkSize, 0, NULL, NULL)) return false;


	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufCount, CL_TRUE, 0, sizeof(int), (void*)&count, 0, NULL, NULL);
	CheckError(GPUError);
	GPUError = clEnqueueReadBuffer(GPUCommandQueue, cmDevBufKeys, CL_TRUE, 0, 700*36*sizeof(Keys), (void*)&keys, 0, NULL, NULL);
	CheckError(GPUError);

	cout << "count: " << count << endl;
	for (int i =0 ; i < 36*350 ; i++)
	{
		if( keys[i].x != 0 ) 
		{
			cout << "i: " << i << endl;
			cout << " x: " << keys[i].x;
			cout << " y: " << keys[i].y;
			cout << " mag: " << keys[i].mag;
			cout << " orie: " << keys[i].orien;
			cout << " scale: " << keys[i].scale << endl;
		}
	}
	return true;
}


bool AssignOrientations::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b, IplImage* c , float sigma )
{
	return false;
}


bool AssignOrientations::filter(cl_command_queue GPUCommandQueue, float sigma = 0)
{
	return false;
}

bool AssignOrientations::filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b)
{
	return false;
}