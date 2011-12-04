/*!
 * \file Filter.cpp
 * \brief Abstract class for all filters
 *
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#include "Filter.h"

Filter::Filter(void)
{
	cout << "void" << endl;
}

Filter::Filter(char* source, char* KernelName)
{
    iBlockDimX = 16;
    iBlockDimY = 16;
    size_t szKernelLength;
	size_t szKernelLengthFilter;
	char* SourceOpenCLShared;
	char* SourceOpenCL;
	kernelName = KernelName;


    // Load OpenCL kernel
	SourceOpenCLShared = oclLoadProgSource("C:\\Users\\Mati\\Desktop\\Dropbox\\MGR\\GPUFeatureExtraction\\GPU\\OpenCL\\GPUCode.cl", "// My comment\n", &szKernelLength);
	

	SourceOpenCL = oclLoadProgSource(source, "// My comment\n", &szKernelLengthFilter);
	//strncat (SourceOpenCL, SourceOpenCLFilter,szKernelLengthFilter );
	szKernelLengthSum = szKernelLength + szKernelLengthFilter;
	char* sourceCL = new char[szKernelLengthSum];
	strcpy(sourceCL,SourceOpenCLShared);
	strcat (sourceCL, SourceOpenCL);
	SourceOpenCLFilter = sourceCL;


}

bool Filter::onInit(cl_context GPUContext ,GPUTransferManager* transfer)
{
	GPUTransfer = transfer;

	cout << "onInit" << endl;

	// creates a program object for a context, and loads the source code specified by the text strings in
	//the strings array into the program object. The devices associated with the program object are the
	//devices associated with context.
	GPUProgram = clCreateProgramWithSource( GPUContext , 1, (const char **)&SourceOpenCLFilter, &szKernelLengthSum, &GPUError);
	CheckError(GPUError);

	// Build the program with 'mad' Optimization option
	char *flags = "";

	cout << szKernelLengthSum << endl;
	GPUError = clBuildProgram(GPUProgram, 0, NULL, flags, NULL, NULL);
	cout << GPUError << endl;
	CheckError(GPUError);
	cout << kernelName << endl;

	GPUFilter = clCreateKernel(GPUProgram, kernelName, &GPUError);

	return true;
}

size_t Filter::shrRoundUp(int group_size, int global_size)
{
	int r = global_size % group_size;
	if(r == 0)
	{
		return global_size;
	} else
	{
		return global_size + group_size - r;
	}
}



char* Filter::oclLoadProgSource(const char* cFilename, const char* cPreamble, size_t* szFinalLength)
{
    // locals
    FILE* pFileStream = NULL;
    size_t szSourceLength;


	pFileStream = fopen(cFilename, "rb");
	if(pFileStream == 0)
	{
		return NULL;
	}
    size_t szPreambleLength = strlen(cPreamble);

    // get the length of the source code
    fseek(pFileStream, 0, SEEK_END);
    szSourceLength = ftell(pFileStream);
    fseek(pFileStream, 0, SEEK_SET);

    // allocate a buffer for the source code string and read it in
    char* cSourceString = (char *)malloc(szSourceLength + szPreambleLength + 1);
    memcpy(cSourceString, cPreamble, szPreambleLength);
    if (fread((cSourceString) + szPreambleLength, szSourceLength, 1, pFileStream) != 1)
    {
        fclose(pFileStream);
        free(cSourceString);
        return 0;
    }

    // close the file and return the total length of the combined (preamble + source) string
    fclose(pFileStream);
    if(szFinalLength != 0)
    {
        *szFinalLength = szSourceLength + szPreambleLength;
    }
    cSourceString[szSourceLength + szPreambleLength] = '\0';

    return cSourceString;
}

Filter::~Filter()
{
    cout << "~Filter" <<endl;
	
    if(GPUProgram)clReleaseProgram(GPUProgram);

    if(GPUFilter)clReleaseKernel(GPUFilter);
	
}


void Filter::CheckError(int code)
{
    switch(code)
    {
    case CL_SUCCESS:
        return;
        break;
    default:
         cout << "OTHERS ERROR" << endl;
    }

    //getchar();
}
