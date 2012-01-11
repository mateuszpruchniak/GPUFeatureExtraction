

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
#include "SIFT.h"
#include "stdafx.h"
#include "sift2.h"




using namespace std;




// The main function!
int main()
{
	//// Create an instance of SIFT
	//SIFT *sift = new SIFT("C:\\fela.jpg", 4, 2);
	//sift->DoSift();
	////sift->ShowAbsSigma();		// Display the sigma table
	////sift->ShowKeypoints();		// Show the keypoints
	////cvWaitKey(0);				// Wait for a keypress

	//SIFT *sift2 = new SIFT("C:\\opel2.jpg", 4, 2);
	//sift2->DoSift();				// Find keypoints
	//sift2->ShowAbsSigma();		// Display the sigma table
	//sift2->ShowKeypoints();		// Show the keypoints
	////cvWaitKey(0);				// Wait for a keypress

	//sift2->FindMatches(sift->m_keyDescs);

	//// Cleanup and exit
	//delete sift;
	//delete sift2;

	char* img_file_name = "C:\\scene2.jpg";
	char* out_file_name  = "C:\\Users\\Mati\\Pictures\\scene2.sift";;
	char* out_img_name = "C:\\Users\\Mati\\Pictures\\sceneOut2.jpg";
	int display = 1;
	int intvls = SIFT_INTVLS;
	double sigma = SIFT_SIGMA;
	double contr_thr = SIFT_CONTR_THR;
	int curv_thr = SIFT_CURV_THR;
	int img_dbl = SIFT_IMG_DBL;
	int descr_width = SIFT_DESCR_WIDTH;
	int descr_hist_bins = SIFT_DESCR_HIST_BINS;
	IplImage* img;
	feature* features;
	int n = 0;


	SIFTGPU* siftGPU = new SIFTGPU();

	fprintf( stderr, "Finding SIFT features...\n" );
	img = cvLoadImage( img_file_name, 1 );
	if( ! img )
	{
		fprintf( stderr, "unable to load image from %s", img_file_name );
		exit( 1 );
	}

	clock_t start, finish;
	double duration = 0;
	start = clock();

	for(int i = 0 ; i < 2 ; i++ )
	{
		n = siftGPU->_sift_features( img, &features, intvls, sigma, contr_thr, curv_thr,
							img_dbl, descr_width, descr_hist_bins );
	}
	finish = clock();
	duration = (double)(finish - start) / CLOCKS_PER_SEC;
	cout << "ExtractKeypointDescriptors: " << endl;
	cout << duration << endl;

	fprintf( stderr, "Found %d features.\n", n );



	if( display )
	{
		draw_features( img, features, n );
		cvNamedWindow( img_file_name, 1 );
		cvShowImage( img_file_name, img );
		cvWaitKey( 0 );
	}

	if( out_file_name != NULL )
		export_features( out_file_name, features, n );

	if( out_img_name != NULL )
		cvSaveImage( out_img_name, img, NULL );



	return 0;
}



//
//
//int main(int argc, const char** argv)
//{
//
//
//	IplImage* img = cvLoadImage("./img/car.jpg");
//	
//
//	GPUImageProcessor* GPU = new GPUImageProcessor(img->width,img->height,img->nChannels);
//
//
//	
//	GPU->AddProcessing( new Feature("./CL/SIFT.cl",GPU->GPUContext,GPU->Transfer,"ckBuildPyramid") );
//
//
//	GPU->Transfer->CreateBuffers();
//	GPU->Transfer->SendImage(img);
//	GPU->Process();
//	img = GPU->Transfer->ReceiveImage();
//
//	cout << "-------------------------\n\n" << endl;
//
//    cvNamedWindow("sobel", CV_WINDOW_AUTOSIZE); 
//    cvShowImage("sobel", img );
//    cvWaitKey(2);
//
//
//
//	getchar();
//    return 0;
//
//}
//


