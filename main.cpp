

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

#include "utils.h"


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

	char* img1_file = "C:\\box.jpg";
	char* img2_file = "C:\\scene.jpg";

	char* img_file_name = "C:\\scene.jpg";
	char* out_file_name  = "C:\\Users\\Mati\\Pictures\\scene.sift";;
	char* out_img_name = "C:\\Users\\Mati\\Pictures\\sceneOut.jpg";
	int display = 1;
	int intvls = SIFT_INTVLS;
	double sigma = SIFT_SIGMA;
	float contr_thr = 0.04;
	int curv_thr = SIFT_CURV_THR;
	int img_dbl = SIFT_IMG_DBL;
	int descr_width = SIFT_DESCR_WIDTH;
	int descr_hist_bins = SIFT_DESCR_HIST_BINS;
	IplImage* img;
	feature* features;
	int n = 0;


	//SIFTGPU* siftGPU = new SIFTGPU();

	//fprintf( stderr, "Finding SIFT features...\n" );
	//img = cvLoadImage( img_file_name, 1 );
	//if( ! img )
	//{
	//	fprintf( stderr, "unable to load image from %s", img_file_name );
	//	exit( 1 );
	//}

	//clock_t start, finish;
	//double duration = 0;
	//start = clock();

	//for(int i = 0 ; i < 1 ; i++ )
	//{
	//	n = siftGPU->_sift_features( img, &features, intvls, sigma, contr_thr, curv_thr,
	//						img_dbl, descr_width, descr_hist_bins );
	//}
	//finish = clock();
	//duration = (double)(finish - start) / CLOCKS_PER_SEC;
	//cout << "ExtractKeypointDescriptors: " << endl;
	//cout << duration << endl;

	//fprintf( stderr, "Found %d features.\n", n );



	//if( display )
	//{
	//	draw_features( img, features, n );
	//	cvNamedWindow( img_file_name, 1 );
	//	cvShowImage( img_file_name, img );
	//	cvWaitKey( 0 );
	//}

	//if( out_file_name != NULL )
	//	export_features( out_file_name, features, n );

	//if( out_img_name != NULL )
	//	cvSaveImage( out_img_name, img, NULL );


	SIFTGPU* siftGPU = new SIFTGPU();



	IplImage* img1, * img2, * stacked;
	struct feature* feat1, * feat2, * feat;
	struct feature** nbrs;
	struct kd_node* kd_root;
	CvPoint pt1, pt2;
	double d0, d1;
	int n1, n2, k, i, m = 0;


	img1 = cvLoadImage( img1_file, 1 );
	if( ! img1 )
		printf( "unable to load image from %s", img1_file );
	img2 = cvLoadImage( img2_file, 1 );
	if( ! img2 )
		printf( "unable to load image from %s", img2_file );

	stacked = stack_imgs( img1, img2 );

	fprintf( stderr, "Finding features in %s...\n", img1_file );
	n1 = siftGPU->sift_features( img1, &feat1 );
	fprintf( stderr, "Finding features in %s...\n", img2_file );
	n2 = siftGPU->sift_features( img2, &feat2 );
	kd_root = kdtree_build( feat2, n2 );
	for( i = 0; i < n1; i++ )
	{
		feat = feat1 + i;
		k = kdtree_bbf_knn( kd_root, feat, 2, &nbrs, KDTREE_BBF_MAX_NN_CHKS );
		if( k == 2 )
		{
			d0 = descr_dist_sq( feat, nbrs[0] );
			d1 = descr_dist_sq( feat, nbrs[1] );
			if( d0 < d1 * NN_SQ_DIST_RATIO_THR )
			{
				pt1 = cvPoint( cvRound( feat->x ), cvRound( feat->y ) );
				pt2 = cvPoint( cvRound( nbrs[0]->x ), cvRound( nbrs[0]->y ) );
				pt2.y += img1->height;
				cvLine( stacked, pt1, pt2, CV_RGB(255,0,255), 1, 8, 0 );
				m++;
				feat1[i].fwd_match = nbrs[0];
			}
		}
		free( nbrs );
	}

	fprintf( stderr, "Found %d total matches\n", m );
	cvNamedWindow( "Matches", 1 );
	cvShowImage( "Matches", stacked );
	cvWaitKey( 0 );


	/* 
	UNCOMMENT BELOW TO SEE HOW RANSAC FUNCTION WORKS

	Note that this line above:

	feat1[i].fwd_match = nbrs[0];

	is important for the RANSAC function to work.
	*/
	/*
	{
		CvMat* H;
		H = ransac_xform( feat1, n1, FEATURE_FWD_MATCH, lsq_homog, 4, 0.01,
			homog_xfer_err, 3.0, NULL, NULL );
		if( H )
		{
			IplImage* xformed;
			xformed = cvCreateImage( cvGetSize( img2 ), IPL_DEPTH_8U, 3 );
			cvWarpPerspective( img1, xformed, H, 
				CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS,
				cvScalarAll( 0 ) );
			cvNamedWindow( "Xformed", 1 );
			cvShowImage( "Xformed", xformed );
			cvWaitKey( 0 );
			cvReleaseImage( &xformed );
			cvReleaseMat( &H );
		}
	}
	*/

	cvReleaseImage( &stacked );
	cvReleaseImage( &img1 );
	cvReleaseImage( &img2 );
	kdtree_release( kd_root );
	free( feat1 );
	free( feat2 );
	return 0;





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


