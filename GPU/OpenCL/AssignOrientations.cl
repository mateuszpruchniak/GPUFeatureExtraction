


float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}





__kernel void ckMagnOrien(__global float* ucSource, __global float* ucDestMagn, __global float* ucDestOrient,
                      int ImageWidth, int ImageHeight)
{
		
	    int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	    int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
		int GMEMOffset = mul24(pozY, ImageWidth) + pozX;
		
		ucDestMagn[GMEMOffset] = 0.0;
		ucDestOrient[GMEMOffset] = 0.0;


		if( pozX < ImageWidth-1 && pozY < ImageHeight-1 && pozX > 1 && pozY > 1 )
		{
			float dx = GetPixel(ucSource, pozX+1, pozY, ImageWidth, ImageHeight) - GetPixel(ucSource, pozX-1, pozY, ImageWidth, ImageHeight);
			float dy = GetPixel(ucSource, pozX, pozY+1, ImageWidth, ImageHeight) - GetPixel(ucSource, pozX, pozY-1, ImageWidth, ImageHeight);
			
			ucDestMagn[GMEMOffset] = (float)sqrt(dx*dx + dy*dy);

			ucDestOrient[GMEMOffset] = (float)atan(dy/dx);

		}
}






__kernel void AssignOrient(__global float* ucSourceExtrema, __global float* ucSourceMagnitude, __global float* ucSourceOrientation,
                      int ImageWidth, int ImageHeight)
{
	int pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	int pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
	int GMEMOffset = mul24(pozY, ImageWidth) + pozX;

	if( ucSourceExtrema[GMEMOffset] != 0.0 )
	{
		float hist[36];







	}





}