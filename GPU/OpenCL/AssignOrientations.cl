
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



__kernel void AssignOrient(__global float* ucSourceExtrema, __global float* imgWeight, __global float* imgMask, __global float* ucSourceOrientation, 
						   __global int* count, __global float* keys,
						   __global float* ucDest, int ImageWidth, int ImageHeight, int scale, int scale2, float maskSize)
{
	int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
	float pi = 3.1415926535897932384626433832795;
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
	


	barrier(CLK_LOCAL_MEM_FENCE);



	if( ucSourceExtrema[GMEMOffset] == 1.0 )
	{


		int numberExtrema = atomic_add(count, (int)1);
		int numberPointInHist = 1;
		
		
		float histOrient[36];
		for(int i=0;i<36;i++)
			histOrient[i]=0.0;


		int r = (int)floor( (float)maskSize/2 );
		
		for(int j = -r ; j <= r; j++ ) //y
		{
			for(int i = -r ; i <= r; i++ ) //x
			{
				int x = pozX + i;
				int y = pozY + j;

				if( x < 0 || x >= ImageWidth || y < 0 || y >= ImageHeight)
					continue;

				int localOffest = Offset(x,y,ImageWidth);

				float sampleOrient = ucSourceOrientation[localOffest];

				if(sampleOrient <= -pi || sampleOrient > pi)
					continue;

				sampleOrient += pi;
				int sampleOrientDegrees = sampleOrient * 180 / pi;
				histOrient[(int)sampleOrientDegrees / 10] += imgWeight[localOffest];
				imgMask[localOffest] = 1.0;
			}
		}


		barrier(CLK_LOCAL_MEM_FENCE);
		

		float max_peak = histOrient[0];
		int max_peak_index = 0;

		for(int i=0;i<36;i++)
		{
			if(histOrient[i]>max_peak)
			{
				max_peak = histOrient[i];
				max_peak_index = i;
			}
		}



		float x1 = max_peak_index-1;
		float y1 = 0.0;
		float x2 = max_peak_index;
		float y2 = histOrient[max_peak_index];
		float x3 = max_peak_index+1;
		float y3 = 0.0;
				
		if(max_peak_index == 0)
		{
			y1 = histOrient[35];
			y3 = histOrient[1];
		}
		else if(max_peak_index == 35)
		{
			y1 = histOrient[35];
			y3 = histOrient[0];
		}
		else
		{
			y1 = histOrient[max_peak_index-1];
			y3 = histOrient[max_peak_index+1];
		}

		float b[3];
		float denom = (x1 - x2) * (x1 - x3) * (x2 - x3);
		b[0]  = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom;
		b[1]  = (x3*x3 * (y1 - y2) + x2*x2 * (y3 - y1) + x1*x1 * (y2 - y3)) / denom;
		b[2]  = (x2 * x3 * (x2 - x3) * y1 + x3 * x1 * (x3 - x1) * y2 + x1 * x2 * (x1 - x2) * y3) / denom;

		float x0 = -b[1]/(2*b[0]);


		if( x0 > 36.0 * 2.0 || x0 < 36.0 * 2.0 * -1 )
			x0=x2;

		while( x0 < 0 )
			x0 += 36;
				
		while(x0 >= 36)
			x0 -= 36;

		float x0_n = x0*(2*pi/36);
		x0_n -= pi;

		//Keypoint(xi*scale/2, yi*scale/2, mag, orien, i*m_numIntervals+j-1)

		keys[numberExtrema*5] = (float)pozX * scale / 2.0;
		keys[numberExtrema*5 + 1] = (float)pozY * scale / 2.0;
		keys[numberExtrema*5 + 2] = (float)histOrient[max_peak_index];
		keys[numberExtrema*5 + 3] = (float)x0_n;
		keys[numberExtrema*5 + 4] = (float)scale2;
		
		ucDest[GMEMOffset] = 1.0;
	}

}