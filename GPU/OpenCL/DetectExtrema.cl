

/* width of border in which to ignore keypoints */
#define SIFT_IMG_BORDER 5



/** default number of sampled intervals per octave */
#define SIFT_INTVLS 3

/** default threshold on keypoint contrast |D(x)| */
#define SIFT_CONTR_THR 0.04

/** default threshold on keypoint ratio of principle curvatures */
#define SIFT_CURV_THR 10

/** default sigma for initial gaussian smoothing */
#define SIFT_SIGMA		1.6

/** default number of sampled intervals per octave */
#define SIFT_INTVLS		3

/* absolute value */
#define ABS(x) ( ( (x) < 0 )? -(x) : (x) )




float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}


/*
Determines whether a pixel is a scale-space extremum by comparing it to it's
3x3x3 pixel neighborhood.

@return Returns 1 if the specified pixel is an extremum (max or min) among
	it's 3x3x3 pixel neighborhood.
*/
int is_extremum(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight )
{
	float val = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);
	
	if( val > 0.0 )
	{
		
				if( val < GetPixel(dataIn1, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;

				if( val < GetPixel(dataIn1, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;

				if( val < GetPixel(dataIn1, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn1, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn2, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val < GetPixel(dataIn3, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
	}
	else 
	{
				if( val > GetPixel(dataIn1, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX-1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX-1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX-1, pozY+1, ImageWidth, ImageHeight) )
					return 0;

				if( val > GetPixel(dataIn1, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX, pozY+1, ImageWidth, ImageHeight) )
					return 0;

				if( val > GetPixel(dataIn1, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX+1, pozY-1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX+1, pozY, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn1, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn2, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
				if( val > GetPixel(dataIn3, pozX+1, pozY+1, ImageWidth, ImageHeight) )
					return 0;
	}

	
	
	return 1;
}

/*
Computes the partial derivatives in x, y, and scale of a pixel in the DoG
scale space pyramid
*/
void deriv_3D( __global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight, float* dI )
{
	float dx, dy, ds;
	dx = ( GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) - GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) ) / 2.0;
	dy = ( GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) - GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) ) / 2.0;
	ds = ( GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) - GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) ) / 2.0;
	dI[0] = dx;
	dI[1] = dy;
	dI[2] = ds;
}

/*
Computes the 3D Hessian matrix for a pixel in the DoG scale space pyramid.
	/ Ixx  Ixy  Ixs \ <BR>
	| Ixy  Iyy  Iys | <BR>
	\ Ixs  Iys  Iss /
*/
void hessian_3D( __global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight, float H[][3] )
{
	float v, dxx, dyy, dss, dxy, dxs, dys;

	v = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);

	dxx = ( GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight) + 
			GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) - 2 * v );

	dyy = ( GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) +
			GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) - 2 * v );

	dss = ( GetPixel(dataIn3, pozX, pozY, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX, pozY, ImageWidth, ImageHeight) - 2 * v );

	dxy = ( GetPixel(dataIn2, pozX+1, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn2, pozX-1, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn2, pozX+1, pozY-1, ImageWidth, ImageHeight) +
			GetPixel(dataIn2, pozX-1, pozY-1, ImageWidth, ImageHeight) ) / 4.0;

	dxs = ( GetPixel(dataIn3, pozX+1, pozY, ImageWidth, ImageHeight) -
			GetPixel(dataIn3, pozX-1, pozY, ImageWidth, ImageHeight) -
			GetPixel(dataIn1, pozX+1, pozY, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX-1, pozY, ImageWidth, ImageHeight) ) / 4.0;

	dys = ( GetPixel(dataIn3, pozX, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn3, pozX, pozY-1, ImageWidth, ImageHeight) -
			GetPixel(dataIn1, pozX, pozY+1, ImageWidth, ImageHeight) +
			GetPixel(dataIn1, pozX, pozY-1, ImageWidth, ImageHeight) ) / 4.0;



	H[0][0] = dxx;
	H[0][1] = dxy;
	H[0][2] = dxs;
	H[1][0] = dxy;
	H[1][1] = dyy;
	H[1][2] = dys;
	H[2][0] = dxs;
	H[2][1] = dys;
	H[2][2] = dss;
}





/*
Performs one step of extremum interpolation.  Based on Eqn. (3) in Lowe's
paper.
*/
void interp_step(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight,
						 float* xi, float* xr, float* xc )
{
	
	float dD[3] = { 0, 0 , 0 };
	float H[3][3];
	float H_inv[3][3];

	deriv_3D(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, dD);
	hessian_3D(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, H);

	float a = H[0][0];
	float b = H[0][1];
	float c = H[0][2];
	float d = H[1][0];
	float e = H[1][1];
	float f = H[1][2];
	float g = H[2][0];
	float h = H[2][1];
	float k = H[2][2];

	float det = a*(e*k - f*h) + b*(f*g - k*d) + c*(d*h - e*g);
	float det_inv = 1.0 / det;

	H_inv[0][0] = (e*k - f*h)*det_inv;
	H_inv[0][1] = (c*h - b*k)*det_inv;
	H_inv[0][2] = (b*f - c*e)*det_inv;

	H_inv[1][0] = (f*g - d*k)*det_inv;
	H_inv[1][1] = (a*k - c*g)*det_inv;
	H_inv[1][2] = (c*d - a*f)*det_inv;

	H_inv[2][0] = (d*h - e*g)*det_inv;
	H_inv[2][1] = (g*b - a*h)*det_inv;
	H_inv[2][2] = (a*e - b*d)*det_inv;

	*xc = (-1)*( H_inv[0][0]*dD[0] + H_inv[1][0]*dD[1] + H_inv[2][0]*dD[2]);
	*xr = (-1)*( H_inv[0][1]*dD[0] + H_inv[1][1]*dD[1] + H_inv[2][1]*dD[2]);
	*xi = (-1)*( H_inv[0][2]*dD[0] + H_inv[1][2]*dD[1] + H_inv[2][2]*dD[2]);
}



/*
Calculates interpolated pixel contrast.  Based on Eqn. (3) in Lowe's paper.

@param Returns interpolated contrast.
*/
float interp_contr(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight, float xi, float xr, float xc )
{
	float dD[3] = { 0, 0, 0 };
	deriv_3D(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, dD);
	float res = xc*dD[0] + xr*dD[1] + xi*dD[2];

	return GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight) + res * 0.5;
}


float interp_extremum(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, int pozX, int pozY, int ImageWidth, int ImageHeight, 
	int intvls, float contr_thr, int intvl, float* xi, float* xr, float* xc )
{
	
	float contr;

	int i = 0;
	int siftMaxInterpSteps = 5;

	while( i < siftMaxInterpSteps )
	{
		interp_step(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, xi, xr, xc );
		
		if( ABS(*xi) <= 0.58 && ABS(*xr) <= 0.58 && ABS(*xc) <= 0.58 )
			break;
		
		pozX += (int)*xc;
		pozY += (int)*xr;
		intvl += (int)*xi;

		if( intvl < 1  ||
			intvl > intvls  ||
			pozX < SIFT_IMG_BORDER  ||
			pozY < SIFT_IMG_BORDER  ||
			pozX >= ImageWidth - SIFT_IMG_BORDER  ||
			pozY >= ImageHeight - SIFT_IMG_BORDER )
		{
			return 0;
		}
		i++;
	}

	/* ensure convergence of interpolation */
	if( i >= siftMaxInterpSteps )
		return 0;

	contr = interp_contr(dataIn1, dataIn2, dataIn3, pozX, pozY, ImageWidth, ImageHeight, *xi, *xr, *xc );
	if( (float)ABS( contr ) < (float)contr_thr / (float)intvls )
		return 0;

	return 1;
}

/*
Determines whether a feature is too edge like to be stable by computing the
ratio of principal curvatures at that feature.  Based on Section 4.1 of
Lowe's paper.

@return Returns 0 if the feature at (r,H[0][2]) in dog_img is sufficiently
	corner-like or 1 otherwise.
*/
 int is_too_edge_like(__global float* dataIn2, int pozX, int pozY, int ImageWidth, int ImageHeight, int curv_thr )
{
	float d, dxx, dyy, dxy, tr, det;

	/* principal curvatures are computed using the trace and det of Hessian */
	d = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);
	dxx = GetPixel(dataIn2, pozX+1, pozY, ImageWidth, ImageHeight)  + GetPixel(dataIn2, pozX-1, pozY, ImageWidth, ImageHeight) - 2 * d;
	dyy = GetPixel(dataIn2, pozX, pozY+1, ImageWidth, ImageHeight) + GetPixel(dataIn2, pozX, pozY-1, ImageWidth, ImageHeight) - 2 * d;
	dxy = ( GetPixel(dataIn2, pozX+1, pozY+1, ImageWidth, ImageHeight) - GetPixel(dataIn2, pozX-1, pozY+1, ImageWidth, ImageHeight) -
			GetPixel(dataIn2, pozX+1, pozY-1, ImageWidth, ImageHeight) + GetPixel(dataIn2, pozX-1, pozY-1, ImageWidth, ImageHeight) ) / 4.0;
	tr = dxx + dyy;
	det = dxx * dyy - dxy * dxy;

	/* negative determinant -> curvatures have different signs; reject feature */
	if( det <= 0 )
		return 1;

	if( tr * tr / det < ( curv_thr + 1.0 )*( curv_thr + 1.0 ) / curv_thr )
		return 0;
	return 1;
}

__kernel void ckDetect(__global float* dataIn1, __global float* dataIn2, __global float* dataIn3, __global float* ucDest, __global int* numberExtrema, __global float* keys,
                      int ImageWidth, int ImageHeight, float prelim_contr_thr, int intvl, int octv, __global int* number, __global int* numberRej)
{
	int pozX = get_global_id(0);
	int pozY = get_global_id(1);
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;

	float xc;
	float xr;
	float xi;

	int numberExt = 0;

	if( pozX < ImageWidth-SIFT_IMG_BORDER && pozY < ImageHeight-SIFT_IMG_BORDER && pozX > SIFT_IMG_BORDER && pozY > SIFT_IMG_BORDER )
	{
		
		float pixel = GetPixel(dataIn2, pozX, pozY, ImageWidth, ImageHeight);
		
		if( ABS(pixel) > prelim_contr_thr )
		{
			ucDest[GMEMOffset] = 0.1;

			if( is_extremum( dataIn1, dataIn2, dataIn2, pozX, pozY, ImageWidth, ImageHeight) == 1 )
			{

				float feat = interp_extremum( dataIn1, dataIn2, dataIn2, pozX, pozY, ImageWidth, ImageHeight, SIFT_INTVLS, SIFT_CONTR_THR, intvl, &xi, &xr, &xc);
				if( feat )
				{
					if( is_too_edge_like( dataIn2, pozX, pozY, ImageWidth, ImageHeight, SIFT_CURV_THR ) != 1 )
					{
						numberExt = atomic_add(number, (int)1);
						ucDest[GMEMOffset] = 1.0;

						float intvl2 = intvl + xi;

						float	scx = (float)( pozX + xc ) * pow( 2.0, (float)octv );
						float	scy = (float)( pozY + xr ) * pow( 2.0, (float)octv );
						float	x = (float)pozX;
						float	y = (float)pozY;
						float	subintvl = xi;
						float	intvl = (float)intvl;
						float	octv = (float)octv;
						float	scl = (SIFT_SIGMA * pow( 2.0, (float)(octv + intvl2 / SIFT_INTVLS) )) / 2.0;
						float	scl_octv = SIFT_SIGMA * pow( 2.0, (float)(intvl2 / SIFT_INTVLS) );
						float	ori = 0;


						keys[numberExt*10] = scx / 2.0;
						keys[numberExt*10+1] = scy / 2.0;
						keys[numberExt*10+2] = x;
						keys[numberExt*10+3] = y;
						keys[numberExt*10+4] = subintvl;
						keys[numberExt*10+5] = intvl;
						keys[numberExt*10+6] = octv;
						keys[numberExt*10+7] = scl;
						keys[numberExt*10+8] = scl_octv;
						keys[numberExt*10+9] = ori;

						

						
						


						// obliczamy mag i orient









					}
				}
				
			} else {
				//ucDest[GMEMOffset] = 0.5;
				//atomic_add(numberRej, (int)1);
			}
		}
	} else {
		
	}

}
