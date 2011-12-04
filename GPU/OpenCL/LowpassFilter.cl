__kernel void ckConv(__global uchar* ucSource,__global uchar* ucDest, __global int* maskGlobal, 
                      __local int* maskLocal, int maskSize, 
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
			maskLocal[tmp] = maskGlobal[tmp];
		}
		barrier(CLK_LOCAL_MEM_FENCE);

		// Init summation registers to zero
		int fSum [3] = {0, 0, 0};
		
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
					fSum[0] +=  GetDataFromGlobalMemory(ucSource,localOffest,nChannels).x*maskLocal[maskOffset];
					fSum[1] +=  GetDataFromGlobalMemory(ucSource,localOffest,nChannels).y*maskLocal[maskOffset];
					fSum[2] +=  GetDataFromGlobalMemory(ucSource,localOffest,nChannels).z*maskLocal[maskOffset];
					++maskOffset;
				}
			}
			
			int sum = 0;
			for( int i = 0 ; i < maskSize ; i++)
			{
				sum += maskLocal[i];
			}
				
			fSum[0] = fSum[0] / sum;
			if( fSum[0] > 255 ) fSum[0] = 255;
			fSum[1] = fSum[1] / sum;
			if( fSum[1] > 255 ) fSum[1] = 255;
			fSum[2] = fSum[2] / sum;
			if( fSum[2] > 255 ) fSum[2] = 255;
			
			uchar4 pix;
			pix.x = (char)fSum[0];
			pix.y = (char)fSum[1];
			pix.z = (char)fSum[2];
			
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