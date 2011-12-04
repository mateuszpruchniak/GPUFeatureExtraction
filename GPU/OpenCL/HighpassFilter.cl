__kernel void ckGradient(__global uchar* ucSource,__global uchar* ucDest, __global int* maskGlobalV, __global int* maskGlobalH,
                      __local int* maskLocalH, __local int* maskLocalV, int maskSize, 
                      int ImageWidth, int ImageHeight, int channels,int maska)
{

		int nChannels = channels;
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;
		
		int tmp = get_local_id(0)+get_local_id(1);
		if( tmp < maskSize )
		{
			maskLocalH[tmp] = maskGlobalH[tmp]; 
			maskLocalV[tmp] = maskGlobalV[tmp];
		}

		barrier(CLK_LOCAL_MEM_FENCE);

	    // Init summation registers to zero
	    float fTemp = 0.0f; 
	    float fHSum [3] = {0.0f, 0.0f, 0.0f};
	    float fVSum [3] = {0.0f, 0.0f, 0.0f};
			
	    int r = (int)floor( (float)maska/2 );
		
		
	    if( get_global_id(0) > r && get_global_id(0) < ImageWidth-r && get_global_id(1)-1 > r && get_global_id(1)-1 < get_global_size(1)-r)
		{
			int maskOffset = 0;
			for(int j = -r ; j <= r; j++ ) //y
			{
				for(int i = -r ; i <= r; i++ ) //x
				{
					int x = iImagePosX + i;
					int y = iDevYPrime + j;
					int localOffest = Offset(x,y,ImageWidth);
					fVSum[0] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).x*maskLocalV[maskOffset];
					fVSum[1] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).y*maskLocalV[maskOffset];
					fVSum[2] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).z*maskLocalV[maskOffset];
					fHSum[0] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).x*maskLocalH[maskOffset];
					fHSum[1] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).y*maskLocalH[maskOffset];
					fHSum[2] +=  (float)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).z*maskLocalH[maskOffset];
					
					++maskOffset;
				}		
			}
			
			fTemp =  0.30f * sqrt((fHSum[0] * fHSum[0]) + (fVSum[0] * fVSum[0]));
			fTemp += 0.30f * sqrt((fHSum[1] * fHSum[1]) + (fVSum[1] * fVSum[1]));
			fTemp += 0.30f * sqrt((fHSum[2] * fHSum[2]) + (fVSum[2] * fVSum[2]));
			
			uchar4 pix;
			if (fTemp < (float)255 )
			{
				pix.x = (char)fTemp;
				pix.y = (char)fTemp;
				pix.z = (char)fTemp;
			}
			else
			{
				pix.x = (char)255;
				pix.y = (char)255;
				pix.z = (char)255;
			}
			
			// Write out to GMEM with restored offset
			if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
			{
				setData(ucDest,pix.x ,pix.y, pix.z, iDevGMEMOffset,nChannels);
			}

		} else 
		{
			uchar4 pix;
			pix.x = (char)0;
			pix.y = (char)0;
			pix.z = (char)0;
			
			// Write out to GMEM with restored offset
			if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
			{
				setData(ucDest,pix.x ,pix.y, pix.z, iDevGMEMOffset,nChannels);
			}
		}
}