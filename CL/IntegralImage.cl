

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
		uchar4 curr4 = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);

		if( iImageX > 0 )
		{
			
			uchar4 prev4 = GetDataFromGlobalMemory(ucSource,localOffest-1,nChannels);
			
			//sprawdzenie czy piksele naleza do segmentu
			uint result = 0;
			if( curr4.x == 0 ) result = 1;
			if( prev4.x == 0 ) result += 1;

			SumTable[iDevGMEMOffset] = result;
		} else 
		{
			uint result = 0;
			if( curr4.x == 0 ) result = 1;
			SumTable[iDevGMEMOffset] = result;
		}

		barrier(CLK_GLOBAL_MEM_FENCE);
		int offset = 2;
		for(offset = 2; offset < ImageWidth; offset <<= 1){

            if( iImageX-offset > 0 )
			{

				barrier(CLK_GLOBAL_MEM_FENCE);
				uint curr = SumTable[iDevGMEMOffset];
				uint prev = SumTable[iDevGMEMOffset-offset];
				uint result = prev + curr;
				barrier(CLK_GLOBAL_MEM_FENCE);
				SumTable[iDevGMEMOffset] = result;
				barrier(CLK_GLOBAL_MEM_FENCE);
			}

        }
	}
}

