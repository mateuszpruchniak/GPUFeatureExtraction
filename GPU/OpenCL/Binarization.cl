__kernel void ckBin(__global uchar* ucSource,__global uchar* ucDest,unsigned int RThreshold,unsigned int GThreshold,unsigned int BThreshold,
                      int ImageWidth, int ImageHeight, int channels)
{

		int nChannels = channels;
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;
		
		

		uchar4 input = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);

		// threshold and clamp
		if ( input.x < BThreshold && input.y < GThreshold && input.z < RThreshold )
		{
			input.x = 10;
			input.y = 10;
			input.z = 10;
		}
		else
		{
			input.x = 255;
			input.y = 255;
			input.z = 255;
		}

		// Write out to GMEM with restored offset
	    if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
		{
			setData(ucDest,input.x ,input.y, input.z, iDevGMEMOffset,nChannels);
		}
}