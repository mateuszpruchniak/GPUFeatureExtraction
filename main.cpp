#include <oclUtils.h>
#include <iostream>
#include "cv.h"
#include "cxmisc.h"
#include "highgui.h"
#include <vector>
#include <string>
#include <algorithm>
#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include "GPUTransferManager.h"
#include "GPUImageProcessor.h"



using namespace std;




int main(int argc, const char** argv)
{



	IplImage* img = cvLoadImage("./img/30x30.bmp");
	

	GPUImageProcessor* GPU = new GPUImageProcessor(img->width,img->height,img->nChannels);


	
	GPU->AddProcessing( new Moments("./CL/IntegralImage.cl",GPU->GPUContext,GPU->Transfer,"ckIntegralImg") );

	GPU->Transfer->SendImage(img);
	GPU->Process();
	img = GPU->Transfer->ReceiveImage();



	cvNamedWindow("sobel", CV_WINDOW_AUTOSIZE); 
	cvShowImage("sobel", img );
	cvWaitKey(2);

	cout << "-------------------------\n\n" << endl;

   /* cvNamedWindow("sobel", CV_WINDOW_AUTOSIZE); 
    cvShowImage("sobel", img2 );
    cvWaitKey(2);*/



	getchar();
    return 0;

}



