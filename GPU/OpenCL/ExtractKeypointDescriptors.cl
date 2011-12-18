
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
		
	float pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	float pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
	int GMEMOffset = pozY * ImageWidth + pozX;
		
	

	pozX += 0.5;
	pozY += 0.5;

	if( pozX < ImageWidth-2 && pozY < ImageHeight-2 && pozX > 0 && pozY > 0 )
	{

		//float dx = (GetPixel(m_gList[i][j], pozY, pozX+1.5, ImageWidth, ImageHeight) + GetPixel(m_gList[i][j], pozY, pozX+0.5, ImageWidth, ImageHeight))/2 - (GetPixel(m_gList[i][j], pozY, pozX-1.5, ImageWidth, ImageHeight) + GetPixel(m_gList[i][j], pozY, pozX-0.5, ImageWidth, ImageHeight))/2;

		imgInterpolatedMagnitude[GMEMOffset] = 1.0;
		
	}
		//// Do the calculations
		//for(float pozX=1.5;pozX<width-1.5;pozX++)
		//{
		//	for(float pozY=1.5;pozY<height-1.5;pozY++)
		//	{
		//		// "inbetween" change
		//		int tmp = pozY;
		//		cout << tmp << endl;
		//		double dx = (GetPixel(m_gList[i][j], pozY, pozX+1.5) + GetPixel(m_gList[i][j], pozY, pozX+0.5))/2 - (GetPixel(m_gList[i][j], pozY, pozX-1.5) + GetPixel(m_gList[i][j], pozY, pozX-0.5))/2;
		//		double dy = (GetPixel(m_gList[i][j], pozY+1.5, pozX) + GetPixel(m_gList[i][j], pozY+0.5, pozX))/2 - (GetPixel(m_gList[i][j], pozY-1.5, pozX) + GetPixel(m_gList[i][j], pozY-0.5, pozX))/2;

		//		unsigned int pozXi = pozX+1;
		//		unsigned int pozYj = pozY+1;
		//		assert(pozXi<=width && pozYj<=height);

		//		// Set the magnitude and orientation
		//		cvSetReal2D(imgInterpolatedMagnitude[i][j-1], pozYj, pozXi, sqrt(dx*dx + dy*dy));
		//		cvSetReal2D(imgInterpolatedOrientation[i][j-1], pozYj, pozXi, (atan2(dy,dx)==M_PI)? -M_PI:atan2(dy,dx) );
		//	}
		//}


}



