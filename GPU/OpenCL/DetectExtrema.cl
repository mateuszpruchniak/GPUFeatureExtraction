



float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}



__kernel void ckDetect(__global float* down, __global float* middle, __global float* up, __global float* ucDest,
                      int ImageWidth, int ImageHeight, int channels)
{
		
		int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
		int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);


		// 00 01 02
		// 10 11 12
		// 20 21 22
		
		float mid00 = GetPixel(middle, pozX-1, pozY-1, ImageWidth, ImageHeight);
		float mid01 = GetPixel(middle, pozX, pozY-1, ImageWidth, ImageHeight);
		float mid12 = GetPixel(middle, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float mid10 = GetPixel(middle, pozX, pozY-1, ImageWidth, ImageHeight);
		float mid11 = GetPixel(middle, pozX, pozY, ImageWidth, ImageHeight);
		float mid12 = GetPixel(middle, pozX, pozY+1, ImageWidth, ImageHeight);
		float mid20 = GetPixel(middle, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float mid21 = GetPixel(middle, pozX+1, pozY, ImageWidth, ImageHeight);
		float mid22 = GetPixel(middle, pozX+1, pozY+1, ImageWidth, ImageHeight);

		float up00 = GetPixel(up, pozX-1, pozY-1, ImageWidth, ImageHeight);
		float up01 = GetPixel(up, pozX, pozY-1, ImageWidth, ImageHeight);
		float up12 = GetPixel(up, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float up10 = GetPixel(up, pozX, pozY-1, ImageWidth, ImageHeight);
		float up11 = GetPixel(up, pozX, pozY, ImageWidth, ImageHeight);
		float up12 = GetPixel(up, pozX, pozY+1, ImageWidth, ImageHeight);
		float up20 = GetPixel(up, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float up21 = GetPixel(up, pozX+1, pozY, ImageWidth, ImageHeight);
		float up22 = GetPixel(up, pozX+1, pozY+1, ImageWidth, ImageHeight);

		float down00 = GetPixel(down, pozX-1, pozY-1, ImageWidth, ImageHeight);
		float down01 = GetPixel(down, pozX, pozY-1, ImageWidth, ImageHeight);
		float down12 = GetPixel(down, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float down10 = GetPixel(down, pozX, pozY-1, ImageWidth, ImageHeight);
		float down11 = GetPixel(down, pozX, pozY, ImageWidth, ImageHeight);
		float down12 = GetPixel(down, pozX, pozY+1, ImageWidth, ImageHeight);
		float down20 = GetPixel(down, pozX+1, pozY-1, ImageWidth, ImageHeight);
		float down21 = GetPixel(down, pozX+1, pozY, ImageWidth, ImageHeight);
		float down22 = GetPixel(down, pozX+1, pozY+1, ImageWidth, ImageHeight);
















		//

		//// Write out to GMEM with restored offset
		//if((pozY <= ImageHeight) && (pozX <= ImageWidth))
		//{
		//	ucDest[iDevGMEMOffset] = 0.99;
		//}
}
