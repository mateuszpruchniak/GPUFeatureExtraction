
__kernel void ckLUT(__global uchar* ucSource,__global uchar* ucDest, __global int* LUT,
                    int ImageWidth, int ImageHeight, int channels)
{
		
		
		int nChannels = channels;
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;
			
	    uchar4 input = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);
		input.x = LUT[input.x];
		input.y = LUT[input.y];
		input.z = LUT[input.z];
		
		// Write out to GMEM with restored offset
		if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
		{
			setData(ucDest,pix.x ,pix.y, pix.z, iDevGMEMOffset,nChannels);
		}
		
}
