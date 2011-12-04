__kernel void ckErode(__global uchar* ucSource,__global uchar* ucDest,
                      int maskSize, int ImageWidth, int ImageHeight, int channels,int maska)
{

		int nChannels = channels;
	    unsigned int isZero = 0;
	    int iImagePosX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int iDevYPrime = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		int iDevGMEMOffset = mul24(iDevYPrime, ImageWidth) + iImagePosX;

	    int fMinimalEstimate [3] = {256, 256, 256};
		int tmp [3] = {256, 256, 256};
			
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
					tmp[0] = (int)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).x;
					tmp[1] = (int)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).y;
					tmp[2] = (int)GetDataFromGlobalMemory(ucSource,localOffest,nChannels).z;
					fMinimalEstimate[0] = fMinimalEstimate[0] < tmp[0] ? fMinimalEstimate[0] : tmp[0];					
					fMinimalEstimate[1] = fMinimalEstimate[1] < tmp[1] ? fMinimalEstimate[1] : tmp[1];						
					fMinimalEstimate[2] = fMinimalEstimate[2] < tmp[2] ? fMinimalEstimate[2] : tmp[2];	
					++maskOffset;
				}		
			}
			
			uchar4 pix;
			pix.x = (char)fMinimalEstimate[0];
			pix.y = (char)fMinimalEstimate[1];
			pix.z = (char)fMinimalEstimate[2];
			
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