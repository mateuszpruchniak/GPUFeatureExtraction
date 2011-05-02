

// warto zastanowic sie nad wykorzystaniem tutaj pamieci lokalnej !!!

__kernel void ckIntegralImg(__global uchar* ucSource,__global uint* SumTable,int ImageWidth, int ImageHeight, int channels)
{
	
	if( get_global_id(0) < ImageWidth && get_global_id(1) < ImageHeight )
	{
		int nChannels = channels;
		int iImageX = get_global_id(0) >= ImageWidth  ? ImageWidth-1  : get_global_id(0);
		int iImageY = get_global_id(1) >= ImageHeight ? ImageHeight-1 : get_global_id(1);
		int iDevGMEMOffset = mul24(iImageY, ImageWidth) + iImageX;


	
		uint localOffest = Offset(iImageX,iImageY,ImageWidth);

		


		// Write out to GMEM with restored offset
		//if( iImageY > 20 && iImageY < 30 && iImageX > 20 && iImageX < 30)
		
		uchar4 curr = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);
		SumTable[iDevGMEMOffset] = (uint)curr.x;
	}
}

