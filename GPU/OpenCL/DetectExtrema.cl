


#define CURVATURE_THRESHOLD		5.0


float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}



__kernel void ckDetect(__global float* down, __global float* middle, __global float* up, __global float* ucDest,
                      int ImageWidth, int ImageHeight, __global int* number, __global int* numberRej)
{


		bool justSet = false;
		int pozX = get_global_id(0);
		int pozY = get_global_id(1);
		int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
		float dxx, dyy, dxy, trH, detH;
		float curvature_ratio, curvature_threshold;

		float contrastThreshold = 0.03;

		ucDest[GMEMOffset] = 0.0;

		// 00 01 02
		// 10 11 12
		// 20 21 22

		curvature_threshold = (CURVATURE_THRESHOLD+1)*(CURVATURE_THRESHOLD+1)/CURVATURE_THRESHOLD;
		
		if( pozX < ImageWidth-1 && pozY < ImageHeight-1 && pozX > 1 && pozY > 1 )
		{


			float mid00 = GetPixel(middle, pozX-1, pozY-1, ImageWidth, ImageHeight);
			float mid01 = GetPixel(middle, pozX, pozY-1, ImageWidth, ImageHeight);
			float mid02 = GetPixel(middle, pozX+1, pozY-1, ImageWidth, ImageHeight);
			float mid10 = GetPixel(middle, pozX-1, pozY, ImageWidth, ImageHeight);
			float mid11 = GetPixel(middle, pozX, pozY, ImageWidth, ImageHeight);
			float mid12 = GetPixel(middle, pozX+1, pozY, ImageWidth, ImageHeight);
			float mid20 = GetPixel(middle, pozX-1, pozY+1, ImageWidth, ImageHeight);
			float mid21 = GetPixel(middle, pozX, pozY+1, ImageWidth, ImageHeight);
			float mid22 = GetPixel(middle, pozX+1, pozY+1, ImageWidth, ImageHeight);

			float up00 = GetPixel(up, pozX-1, pozY-1, ImageWidth, ImageHeight);
			float up01 = GetPixel(up, pozX, pozY-1, ImageWidth, ImageHeight);
			float up02 = GetPixel(up, pozX+1, pozY-1, ImageWidth, ImageHeight);
			float up10 = GetPixel(up, pozX-1, pozY, ImageWidth, ImageHeight);
			float up11 = GetPixel(up, pozX, pozY, ImageWidth, ImageHeight);
			float up12 = GetPixel(up, pozX+1, pozY, ImageWidth, ImageHeight);
			float up20 = GetPixel(up, pozX-1, pozY+1, ImageWidth, ImageHeight);
			float up21 = GetPixel(up, pozX, pozY+1, ImageWidth, ImageHeight);
			float up22 = GetPixel(up, pozX+1, pozY+1, ImageWidth, ImageHeight);

			float down00 = GetPixel(down, pozX-1, pozY-1, ImageWidth, ImageHeight);
			float down01 = GetPixel(down, pozX, pozY-1, ImageWidth, ImageHeight);
			float down02 = GetPixel(down, pozX+1, pozY-1, ImageWidth, ImageHeight);
			float down10 = GetPixel(down, pozX-1, pozY, ImageWidth, ImageHeight);
			float down11 = GetPixel(down, pozX, pozY, ImageWidth, ImageHeight);
			float down12 = GetPixel(down, pozX+1, pozY, ImageWidth, ImageHeight);
			float down20 = GetPixel(down, pozX-1, pozY+1, ImageWidth, ImageHeight);
			float down21 = GetPixel(down, pozX, pozY+1, ImageWidth, ImageHeight);
			float down22 = GetPixel(down, pozX+1, pozY+1, ImageWidth, ImageHeight);


			// Check for a maximum
			if (mid11 > mid00 &&
				mid11 > mid01 &&
				mid11 > mid02 &&
				mid11 > mid10 &&
				mid11 > mid12 &&
				mid11 > mid20 &&
				mid11 > mid21 &&
				mid11 > mid22 &&
				mid11 > up00 &&
				mid11 > up01 &&
				mid11 > up02 &&
				mid11 > up10 &&
				mid11 > up11 &&
				mid11 > up12 &&
				mid11 > up20 &&
				mid11 > up21 &&
				mid11 > up22 &&
				mid11 > down00 &&
				mid11 > down01 &&
				mid11 > down02 &&
				mid11 > down10 &&
				mid11 > down11 &&
				mid11 > down12 &&
				mid11 > down20 &&
				mid11 > down21 &&
				mid11 > down22 )
			{			
				ucDest[GMEMOffset] = 1.0;
				justSet = true;
				atomic_add(number, (int)1);
			}
			// Check if it's a minimum
			else if (
				mid11 < mid00 &&
				mid11 < mid01 &&
				mid11 < mid02 &&
				mid11 < mid10 &&
				mid11 < mid12 &&
				mid11 < mid20 &&
				mid11 < mid21 &&
				mid11 < mid22 &&
				mid11 < up00 &&
				mid11 < up01 &&
				mid11 < up02 &&
				mid11 < up10 &&
				mid11 < up11 &&
				mid11 < up12 &&
				mid11 < up20 &&
				mid11 < up21 &&
				mid11 < up22 &&
				mid11 < down00 &&
				mid11 < down01 &&
				mid11 < down02 &&
				mid11 < down10 &&
				mid11 < down11 &&
				mid11 < down12 &&
				mid11 < down20 &&
				mid11 < down21 &&
				mid11 < down22 )
			{
				ucDest[GMEMOffset] = 1.0;
				justSet = true;
				atomic_add(number, (int)1);
			}

			// The contrast check
			if(justSet && mid11 < contrastThreshold && mid11> -contrastThreshold)
			{
				ucDest[GMEMOffset] = 0.0;
				atomic_sub(number, (int)1);
				atomic_add(numberRej, (int)1);
				justSet=false;
			}

			//The edge check
			if(justSet)
			{
				dxx = (GetPixel(middle, pozX, pozY-1, ImageWidth, ImageHeight) +
						GetPixel(middle, pozX, pozY+1, ImageWidth, ImageHeight) -
						2.0*GetPixel(middle, pozX, pozY, ImageWidth, ImageHeight));

				dyy = (GetPixel(middle, pozX-1, pozY, ImageWidth, ImageHeight) +
						GetPixel(middle, pozX+1, pozY, ImageWidth, ImageHeight) -
						2.0* GetPixel(middle, pozX, pozY, ImageWidth, ImageHeight));

				dxy = (GetPixel(middle, pozX-1, pozY-1, ImageWidth, ImageHeight) +
						GetPixel(middle, pozX+1, pozY+1, ImageWidth, ImageHeight) -
						GetPixel(middle, pozX-1, pozY+1, ImageWidth, ImageHeight) - 
						GetPixel(middle, pozX+1, pozY-1, ImageWidth, ImageHeight)) / 4.0;


				trH = dxx + dyy;
				detH = dxx*dyy - dxy*dxy;

				curvature_ratio = trH*trH/detH;

				if(detH<0 || curvature_ratio>curvature_threshold)
				{
					ucDest[GMEMOffset] = 0.0;
					atomic_sub(number, (int)1);
					atomic_add(numberRej, (int)1);
					justSet=false;
				}
			}
		}


}