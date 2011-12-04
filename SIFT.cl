



__kernel void ckBuildPyramid(__global uchar* ucSource, int ImageWidth, int ImageHeight, int channels)
{
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;

	    






		// Write out to GMEM with restored offset
		if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
		{
			setData(ucSource,1 ,100,200, iDevGMEMOffset,channels);
		}
		
}

