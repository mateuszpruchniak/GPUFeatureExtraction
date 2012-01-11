

/* width of border in which to ignore keypoints */
#define SIFT_IMG_BORDER 5


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

				


			}
		}
	}

}
