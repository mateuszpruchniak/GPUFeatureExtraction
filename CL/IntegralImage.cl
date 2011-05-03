
void sum(__global int* data,int iImageX,int iImageY,int iDevGMEMOffset,int ImageWidth,int ImageHeight)
{

	for(int offset = 2; offset < ImageWidth; offset <<= 1)
	{
        if( iImageX-offset >= 0 )
		{
			barrier(CLK_GLOBAL_MEM_FENCE);
			int curr = data[iDevGMEMOffset];
			int prev = data[iDevGMEMOffset-offset];
			int result = prev + curr;
			barrier(CLK_GLOBAL_MEM_FENCE);
			data[iDevGMEMOffset] = result;	
		}
    }

	for(int offset = 1; offset < ImageHeight; offset <<= 1)
	{
        if( iImageY-offset >= 0 )
		{
			int offsPrev = Offset(iImageX,iImageY-offset,ImageWidth);
			barrier(CLK_GLOBAL_MEM_FENCE);
			int curr = data[iDevGMEMOffset];
			int prev = data[offsPrev];
			int result = prev + curr;
			barrier(CLK_GLOBAL_MEM_FENCE);
			data[iDevGMEMOffset] = result;	
		}
    }
}

__kernel void ckIntegralImg(__global uchar* ucSource,__global int* SumTable00,__global int* SumTable01,__global int* SumTable10,
							int ImageWidth, int ImageHeight, int channels)
{
	
	if( get_global_id(0) < ImageWidth && get_global_id(1) < ImageHeight )
	{
		int nChannels = channels;
		int iImageX = get_global_id(0) >= ImageWidth  ? ImageWidth-1  : get_global_id(0);
		int iImageY = get_global_id(1) >= ImageHeight ? ImageHeight-1 : get_global_id(1);
		int iDevGMEMOffset = mul24(iImageY, ImageWidth) + iImageX;

		uchar4 curr4 = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);
		int result = 0;

		if( iImageX > 0 )
		{
			uchar4 prev4 = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset-1,nChannels);
			//sprawdzenie czy piksele naleza do segmentu
			result = 0;
			if( curr4.x == 0 ) result = 1;
			if( prev4.x == 0 ) result += 1;
		} else 
		{
			result = 0;
			if( curr4.x == 0 ) result = 1;
		}

		barrier(CLK_GLOBAL_MEM_FENCE);
		SumTable00[iDevGMEMOffset] = result;
		SumTable01[iDevGMEMOffset] = result*iImageX;
		SumTable10[iDevGMEMOffset] = result*iImageY;

		sum(SumTable00,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable01,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable10,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);


	}
}

