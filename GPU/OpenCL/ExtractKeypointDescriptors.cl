
float GetPixel(__global float* dataIn, int x, int y, int ImageWidth, int ImageHeight )
{
	int X = x > ImageWidth  ? ImageWidth  : x;
	int Y = y > ImageHeight ? ImageHeight : y;
	int GMEMOffset = mul24(Y, ImageWidth) + X;

	return dataIn[GMEMOffset];
}


__kernel void ckExtract(__global float* m_gList, __global float* imgInterpolatedMagnitude, __global float* imgInterpolatedOrientation,
						   int ImageWidth, int ImageHeight)
{
	float pi = 3.141592653;
	float pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	float pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
	int GMEMOffset = pozY * ImageWidth + pozX;
	
	pozX += 0.5;
	pozY += 0.5;

	if( pozX < ImageWidth-2 && pozY < ImageHeight-2 && pozX > 0 && pozY > 0 )
	{

		float dx = (GetPixel(m_gList,pozX+1.5, pozY,  ImageWidth, ImageHeight) + GetPixel(m_gList,pozX+0.5, pozY,  ImageWidth, ImageHeight))/2 - (GetPixel(m_gList,pozX-1.5, pozY,  ImageWidth, ImageHeight) + GetPixel(m_gList,pozX-0.5, pozY,  ImageWidth, ImageHeight))/2;
		float dy = (GetPixel(m_gList,pozX, pozY+1.5,  ImageWidth, ImageHeight) + GetPixel(m_gList,pozX, pozY+0.5,  ImageWidth, ImageHeight))/2 - (GetPixel(m_gList,pozX, pozY-1.5,  ImageWidth, ImageHeight) + GetPixel(m_gList,pozX, pozY-0.5,  ImageWidth, ImageHeight))/2;

		int pozXi = pozX+1;
		int pozYj = pozY+1;

		GMEMOffset = pozYj * ImageWidth + pozXi;
		imgInterpolatedMagnitude[GMEMOffset] = sqrt(dx*dx + dy*dy);
		imgInterpolatedOrientation[GMEMOffset] = (atan2(dy,dx)==pi) ? -pi : atan2(dy,dx);


	} else 
	{
		imgInterpolatedMagnitude[GMEMOffset] = 0;
		imgInterpolatedOrientation[GMEMOffset] = 0;
	}


}



