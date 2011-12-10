/*!
 * \file Filter.h
 * \brief Abstract class for all filters.
 *
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */

#pragma once

#include <cv.h>
#include <highgui.h>
#include <sstream>
#include <oclUtils.h>
#include <stdio.h>
#include "../GPUTransferManager.h"
 

using namespace std;

/*!
 * \class Filter
 * \brief Abstract class for all filters.
 * \author Mateusz Pruchniak
 * \date 2010-05-05
 */
class Filter
{
	protected:


		/*!
		 * Work-group size - dim X.
		 */
        int iBlockDimX;                    

		/*!
		 * Work-group size - dim Y.
		 */
        int iBlockDimY;                    

		/*!
		 * Error code, only 0 is allowed.
		 */
        cl_int GPUError;

		/*!
		 * Pointer to instance of class GPUTransferManager.
		 */
        GPUTransferManager* GPUTransfer;

		/*!
		 * Loaded .cl file, which contain code responsible for image processing.
		 */
        char* SourceOpenCLFilter;

        /*!
		 * Kernel name.
		 */
		char* kernelName;

        /*!
		 * Kernel code length.
		 */
        size_t szKernelLengthSum;

		/*!
		 * Program is formed by a set of kernels, functions and declarations, and it's represented by an cl_program object.
		 */
        cl_program GPUProgram;              

		/*!
		 * Kernels are essentially functions that we can call from the host and that will run on the device
		 */
        cl_kernel GPUFilter;               

		/*!
		 * Global size of NDRange.
		 */
        size_t GPUGlobalWorkSize[2];

        /*!
		 * !!!!!!!!!!!!!!!
		 */
		size_t shrRoundUp(int group_size, int global_size);

		/*!
		 * !!!!!!!!!!!!!!!
		 */
		char* oclLoadProgSource(const char* cFilename, const char* cPreamble, size_t* szFinalLength);

    public:

		/*!
		* Default constructor. Nothing doing.
		*/
		Filter(void);


        /*!
		 * Constructor, loads the source code (.cl files)
		 */
		Filter(char* ,char* );

		/*!
		 * Destructor.
		 */
        virtual ~Filter();

		/*!
		 * Virtual methods, processing image. Launching the Kernel.
		 */
		virtual bool filter(cl_command_queue GPUCommandQueue, float sigma = 0) = 0;

		/*!
		 * Virtual methods, processing image. Launching the Kernel.
		 */
		virtual bool filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b ) = 0;

		/*!
		 * Virtual methods, processing image. Launching the Kernel.
		 */
		virtual bool filter(cl_command_queue GPUCommandQueue, IplImage* a, IplImage* b,IplImage* c  ) = 0;
        
		/*!
		 * Check error code.
		 */
        void CheckError(int);

        /*!
		 * Initialize filter.
		 */
        virtual bool onInit(cl_context ,GPUTransferManager* );

};

