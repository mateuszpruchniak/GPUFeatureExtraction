
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
							__global float* ucDest, int ImageWidth, int ImageHeight, float maskSize)
{
	int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
	float pi = 3.141592653;
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
	
	if( ucSourceExtrema[GMEMOffset] != 0.0 )
	{
		float histOrient[36];
		for(int i=0;i<36;i++)
			histOrient[i]=0.0;

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
				histOrient[(int)sampleOrientDegrees / 10] += imgWeight[localOffest];
				imgMask[localOffest] = 1.0;
			}
		}


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

		for(int k = 0; k < 36; k++)
		{
			
			if(histOrient[k]> 0.8 * max_peak)
			{
				float x1 = k-1;
				float y1 = 0.0;
				float x2 = k;
				float y2 = histOrient[k];
				float x3 = k+1;
				float y3 = 0.0;
				
				if(k == 0)
				{
					y1 = histOrient[35];
					y3 = histOrient[1];
				}
				else if(k == 35)
				{
					y1 = histOrient[35];
					y3 = histOrient[0];
				}
				else
				{
					y1 = histOrient[k-1];
					y3 = histOrient[k+1];
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


			}
		}

		ucDest[GMEMOffset] = 1.0;
	}

}


//		//List of magnitudes and orientations at the current extrema
//		/*vector<float> orien;
//		vector<float> mag;*/
//
//
//		
//
//

//
//				
//
//				//// Normalize it
//				//float x0_n = x0*(2*M_PI/36);
//
//				/*assert(x0_n>=0 && x0_n<2*M_PI);
//				x0_n -= M_PI;
//				assert(x0_n>=-M_PI && x0_n<M_PI);
//
//				orien.push_back(x0_n);
//				mag.push_back(hist_orient[k]);
//				*/
//
//			//}
//		//}
//
//		//ucDest[GMEMOffset] = 1.0;
//
////	//}
////
////
////}
////
////
