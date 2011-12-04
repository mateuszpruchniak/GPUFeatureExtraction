

__kernel void ckDetect(__global float* ucSource, __global float* ucSource2, __global float* ucSource3, __global float* ucDest,
                      int ImageWidth, int ImageHeight, int channels)
{
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;
		

















		

		// Write out to GMEM with restored offset
		if((iDevYPrime <= ImageHeight) && (iImagePosX <= ImageWidth))
		{
			ucDest[iDevGMEMOffset] = 0.99;
		}
}
