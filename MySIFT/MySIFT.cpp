

#include "stdafx.h"

#include "SIFT.h"
#include "sift2.h"

#include <cv.h>
#include <highgui.h>

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


// The main function!
int main()
{
	// Create an instance of SIFT
	//SIFT *sift = new SIFT("C:\\scene.jpg", 4, 2);
	//sift->DoSift();
	//sift->ShowAbsSigma();		// Display the sigma table
	//sift->ShowKeypoints();		// Show the keypoints
	//cvWaitKey(0);				// Wait for a keypress


	//SIFT *sift2 = new SIFT("C:\\scene2.jpg", 4, 2);
	//sift2->DoSift();				// Find keypoints
	//sift2->ShowAbsSigma();		// Display the sigma table
	//sift2->ShowKeypoints();		// Show the keypoints
	//cvWaitKey(0);				// Wait for a keypress

	//sift2->FindMatches(sift->m_keyDescs);

	IplImage* img;
	feature* features;
	int n = 0;

	fprintf( stderr, "Finding SIFT features...\n" );
	img = cvLoadImage( img_file_name, 1 );
	if( ! img )
	{
		fprintf( stderr, "unable to load image from %s", img_file_name );
		exit( 1 );
	}
	n = _sift_features( img, &features, intvls, sigma, contr_thr, curv_thr,
						img_dbl, descr_width, descr_hist_bins );
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




	// Cleanup and exit
	//delete sift;
	//delete sift2;
	return 0;
}



