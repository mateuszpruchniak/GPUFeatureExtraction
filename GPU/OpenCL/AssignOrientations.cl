


float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}





__kernel void ckMagnOrien(__global float* ucSource, __global float* ucDestMagn, __global float* ucDestOrient,
                      int ImageWidth, int ImageHeight)
{
		
	    int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
		int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
		
		ucDestMagn[GMEMOffset] = 0.0;
		ucDestOrient[GMEMOffset] = 0.0;


		if( pozX < ImageWidth-1 && pozY < ImageHeight-1 && pozX > 1 && pozY > 1 )
		{
			float dx = GetPixel(ucSource, pozX+1, pozY, ImageWidth, ImageHeight) - GetPixel(ucSource, pozX-1, pozY, ImageWidth, ImageHeight);
			float dy = GetPixel(ucSource, pozX, pozY+1, ImageWidth, ImageHeight) - GetPixel(ucSource, pozX, pozY-1, ImageWidth, ImageHeight);
			
			ucDestMagn[GMEMOffset] = (float)sqrt(dx*dx + dy*dy);

			ucDestOrient[GMEMOffset] = (float)atan(dy/dx);

		}
}




//m_extrema[i][j-1],imgWeight,imgMask

__kernel void AssignOrient(__global float* ucSourceExtrema, __global float* imgWeight, __global float* imgMask, __global float* ucSourceOrientation, 
							__global float* ucDest, int ImageWidth, int ImageHeight, float maskSize)
{
	int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
	float pi = 3.1415926535897932384626433832795;
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;

	if( ucSourceExtrema[GMEMOffset] != 0.0 )
	{
		float hist[36];
		for(int i=0;i<36;i++)
			hist[i]=0.0;


		int r = (int)floor( (float)maskSize/2 );
		

		for(int j = -r ; j <= r; j++ ) //y
		{
			for(int i = -r ; i <= r; i++ ) //x
			{
				int x = pozX + i >= 0 && pozX + i <= ImageWidth  ? pozX + i : 0;
				int y = pozY + j >= 0 && pozY + j <= ImageHeight ? pozY + j : 0;
				int localOffest = Offset(x,y,ImageWidth);

				float sampleOrient = ucSourceOrientation[localOffest];

				if(sampleOrient <= -pi || sampleOrient > pi)
					continue;

				sampleOrient += pi;
				int sampleOrientDegrees = sampleOrient * 180 / pi;
				hist[(int)sampleOrientDegrees / (360/36)] += imgWeight[localOffest];
				imgMask[localOffest] = 1.0;
			}
		}


		// We've computed the histogram. Now check for the maximum
		float max_peak = hist[0];
		int max_peak_index = 0;
		for(int i=0;i<36;i++)
		{
			if(hist[i]>max_peak)
			{
				max_peak=hist[i];
				max_peak_index = i;
			}
		}


		// List of magnitudes and orientations at the current extrema
		//vector<float> orien;
		//vector<float> mag;


		for(int k=0; k < 36; k++)
		{
			// Do we have a good peak?
			if(hist[k]> 0.8*max_peak)
			{
				// Three points. (x2,y2) is the peak and (x1,y1)
				// and (x3,y3) are the neigbours to the left and right.
				// If the peak occurs at the extreme left, the "left
				// neighbour" is equal to the right most. Similarly for
				// the other case (peak is rightmost)
				float x1 = k-1;
				float y1;
				float x2 = k;
				float y2 = hist[k];
				float x3 = k+1;
				float y3;

				if(k==0)
				{
					y1 = hist[36-1];
					y3 = hist[1];
				}
				else if(k==36-1)
				{
					y1 = hist[36-1];
					y3 = hist[0];
				}
				else
				{
					y1 = hist[k-1];
					y3 = hist[k+1];
				}

				// Next we fit a downward parabola aound
				// these three points for better accuracy

				// A downward parabola has the general form
				//
				// y = a * x^2 + bx + c
				// Now the three equations stem from the three points
				// (x1,y1) (x2,y2) (x3.y3) are
				//
				// y1 = a * x1^2 + b * x1 + c
				// y2 = a * x2^2 + b * x2 + c
				// y3 = a * x3^2 + b * x3 + c
				//
				// in Matrix notation, this is y = Xb, where
				// y = (y1 y2 y3)' b = (a b c)' and
				// 
				//     x1^2 x1 1
				// X = x2^2 x2 1
				//     x3^2 x3 1
				//
				// OK, we need to solve this equation for b
				// this is done by inverse the matrix X
				//
				// b = inv(X) Y

				float b =[3];
				float 

				CvMat *X = cvCreateMat(3, 3, CV_32FC1);
				CvMat *matInv = cvCreateMat(3, 3, CV_32FC1);

				cvSetReal2D(X, 0, 0, x1*x1);
				cvSetReal2D(X, 1, 0, x1);
				cvSetReal2D(X, 2, 0, 1);

				cvSetReal2D(X, 0, 1, x2*x2);
				cvSetReal2D(X, 1, 1, x2);
				cvSetReal2D(X, 2, 1, 1);

				cvSetReal2D(X, 0, 2, x3*x3);
				cvSetReal2D(X, 1, 2, x3);
				cvSetReal2D(X, 2, 2, 1);

				// Invert the matrix
				cvInv(X, matInv);

				b[0] = cvGetReal2D(matInv, 0, 0)*y1 + cvGetReal2D(matInv, 1, 0)*y2 + cvGetReal2D(matInv, 2, 0)*y3;
				b[1] = cvGetReal2D(matInv, 0, 1)*y1 + cvGetReal2D(matInv, 1, 1)*y2 + cvGetReal2D(matInv, 2, 1)*y3;
				b[2] = cvGetReal2D(matInv, 0, 2)*y1 + cvGetReal2D(matInv, 1, 2)*y2 + cvGetReal2D(matInv, 2, 2)*y3;

				float x0 = -b[1]/(2*b[0]);

				// Anomalous situation
				if(fabs(x0)>2*36)
					x0=x2;

				while(x0<0)
					x0 += 36;
				while(x0>= 36)
					x0-= 36;

				// Normalize it
				float x0_n = x0*(2*M_PI/36);

				assert(x0_n>=0 && x0_n<2*M_PI);
				x0_n -= M_PI;
				assert(x0_n>=-M_PI && x0_n<M_PI);

				orien.push_back(x0_n);
				mag.push_back(hist[k]);
			}
		}

		// Save this keypoint into the list
		m_keyPoints.push_back(Keypoint(xi*scale/2, yi*scale/2, mag, orien, i*m_numIntervals+j-1));




		ucDest[GMEMOffset] = 1.0;

	}





}