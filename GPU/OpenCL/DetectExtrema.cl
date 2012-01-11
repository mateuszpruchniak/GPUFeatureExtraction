

/* width of border in which to ignore keypoints */
#define SIFT_IMG_BORDER 5

/* maximum steps of keypoint interpolation before failure */
#define SIFT_MAX_INTERP_STEPS 5

float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}

int is_extremum(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight )
{
	float val = GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight);
	int i, j, k;

	/* check for maximum */
	if( val > 0 )
	{
			for( j = -1; j <= 1; j++ )
				for( k = -1; k <= 1; k++ )
				{
					if( val < GetPixel(dataIn1, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
					if( val < GetPixel(dataIn2, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
					if( val < GetPixel(dataIn3, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
				}
	}
	/* check for minimum */
	else
	{
			for( j = -1; j <= 1; j++ )
				for( k = -1; k <= 1; k++ )
				{
					if( val > GetPixel(dataIn1, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
					if( val > GetPixel(dataIn2, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
					if( val > GetPixel(dataIn3, pozX+ j, pozY + k, ImageWidth, ImageHeight) )
						return 0;
				}
	}
	return 1;
}

/*
Computes the partial derivatives in x, y, and scale of a pixel in the DoG
scale space pyramid
*/
float* deriv_3D( __global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight )
{
	float dI[3] = { 0, 0 , 0 };
	float dx, dy, ds;

	dx = ( GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) - GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) ) / 2.0;
	dy = ( GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) - GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) ) / 2.0;
	ds = ( GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) - GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) ) / 2.0;

	dI[0] = dx;
	dI[1] = dy;
	dI[2] = ds;

	return dI;
}

/*
Computes the 3D Hessian matrix for a pixel in the DoG scale space pyramid.
	/ Ixx  Ixy  Ixs \ <BR>
	| Ixy  Iyy  Iys | <BR>
	\ Ixs  Iys  Iss /
*/
float* hessian_3D( __global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight )
{
	float v, dxx, dyy, dss, dxy, dxs, dys;

	v = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);

	dxx = ( GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) + 
			GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) - 2 * v );

	dyy = ( GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) +
			GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) - 2 * v );

	dss = ( GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) - 2 * v );

	dxy = ( GetPixel(dataIn2, pozX+1, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn2, pozX+1, pozY-1, ImageWidth, ImageHeight) -
			GetPixel(dataIn2, pozX-1, pozY+1, ImageWidth, ImageHeight) +
			GetPixel(dataIn2, pozX-1, pozY-1, ImageWidth, ImageHeight) ) / 4.0;

	dxs = ( GetPixel(dataIn3, pozX, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn3, pozX, pozY-1, ImageWidth, ImageHeight) -
			GetPixel(dataIn1, pozX, pozY+1, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX, pozY-1, ImageWidth, ImageHeight) ) / 4.0;

	dys = ( GetPixel(dataIn3, pozX+1, pozY, ImageWidth, ImageHeight) -
			GetPixel(dataIn3, pozX-1, pozY, ImageWidth, ImageHeight) -
			GetPixel(dataIn1, pozX+1, pozY, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX-1, pozY, ImageWidth, ImageHeight) ) / 4.0;

	float H[9];

	// 0 1 2
	// 3 4 5
	// 6 7 8

	H[0] = dxx;
	H[1] = dxy;
	H[2] = dxs;
	H[3] = dxy;
	H[4] = dyy;
	H[5] = dys;
	H[6] = dxs;
	H[7] = dys;
	H[8] = dss;

	return H;
}

void interp_step(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight,
						 float* xi, float* xr, float* xc )
{
	//CvMat* dD, * H, * H_inv, X;
	float x[3] = { 0, 0 , 0 };
	float *dD;
	float* H;

	dD = deriv_3D(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight);
	H = hessian_3D(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight);


	H_inv = cvCreateMat( 3, 3, CV_64FC1 );
	/*cvInvert( H, H_inv, CV_SVD );
	cvInitMatHeader( &X, 3, 1, CV_64FC1, x, CV_AUTOSTEP );
	cvGEMM( H_inv, dD, -1, NULL, 0, &X, 0 );

	cvReleaseMat( &dD );
	cvReleaseMat( &H );
	cvReleaseMat( &H_inv );*/

	*xi = x[2];
	*xr = x[1];
	*xc = x[0];
}


int interp_extremum(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight, int intvls, float contr_thr )
{
	
	float xi, xr, xc, contr;

	int i = 0;

	while( i < SIFT_MAX_INTERP_STEPS )
	{
		interp_step(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, &xi, &xr, &xc );
		/*if( ABS( xi ) < 0.5  &&  ABS( xr ) < 0.5  &&  ABS( xc ) < 0.5 )
			break;

		c += cvRound( xc );
		r += cvRound( xr );
		intvl += cvRound( xi );

		if( intvl < 1  ||
			intvl > intvls  ||
			c < SIFT_IMG_BORDER  ||
			r < SIFT_IMG_BORDER  ||
			c >= dog_pyr[octv][0]->width - SIFT_IMG_BORDER  ||
			r >= dog_pyr[octv][0]->height - SIFT_IMG_BORDER )
		{
			return 0;
		}*/

		i++;
	}

	/* ensure convergence of interpolation */
	/*if( i >= SIFT_MAX_INTERP_STEPS )
		return NULL;

	contr = interp_contr( dog_pyr, octv, intvl, r, c, xi, xr, xc );
	if( ABS( contr ) < contr_thr / intvls )
		return NULL;

	feat = new_feature();
	ddata = feat_detection_data( feat );
	feat->img_pt.x = feat->x = ( c + xc ) * pow( 2.0, octv );
	feat->img_pt.y = feat->y = ( r + xr ) * pow( 2.0, octv );
	ddata->r = r;
	ddata->c = c;
	ddata->octv = octv;
	ddata->intvl = intvl;
	ddata->subintvl = xi;*/

	return 1;
}

__kernel void ckDetect(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, __global float* ucDest, __global int* numberExtrema, __global float* keys,
                      int ImageWidth, int ImageHeight, int prelim_contr_thr, __global int* number, __global int* numberRej)
{
	int pozX = get_global_id(0);
	int pozY = get_global_id(1);
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
		
	//float mid00 = GetPixel(middle, pozX-1, pozY-1, ImageWidth, ImageHeight);


	if( pozX < ImageWidth-SIFT_IMG_BORDER && pozY < ImageHeight-SIFT_IMG_BORDER && pozX > SIFT_IMG_BORDER && pozY > SIFT_IMG_BORDER )
	{
		float pixel = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);
		if( pixel < 0 )
			pixel = -1 * pixel;

		if( pixel > prelim_contr_thr )
		{
			if( is_extremum( dataIn1, dataIn2, dataIn2, pozX, pozY, ImageWidth, ImageHeight) )
			{
				//int feat = interp_extremum( dataIn1, dataIn2, dataIn2, pozX, pozY, ImageWidth, ImageHeight, intvls, contr_thr);
				/*if( feat )
				{
					ddata = feat_detection_data( feat );
					if( ! is_too_edge_like( dog_pyr[ddata->octv][ddata->intvl],
						ddata->r, ddata->c, curv_thr ) )
					{
						cvSeqPush( features, feat );
					}
					else
						free( ddata );
					free( feat );
				}*/
				


			}
		}
	}

}
