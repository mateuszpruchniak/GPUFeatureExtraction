
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
	float pi = 3.1415926535897932384626433832795;
	float pozX = get_global_id(0) > ImageWidth  ? ImageWidth  : get_global_id(0);
	float pozY = get_global_id(1) > ImageHeight ? ImageHeight : get_global_id(1);
		
	int GMEMOffset = pozY * ImageWidth + pozX;
	
	pozX += 0.5;
	pozY += 0.5;

	if( pozX < ImageWidth-2 && pozY < ImageHeight-2 && pozX > 1 && pozY > 1 )
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

	//for(float ii=1.5;ii<width-1.5;ii++)
	//{
	//	for(float jj=1.5;jj<height-1.5;jj++)
	//	{
	//		// "inbetween" change
	//		double dx = (cvGetReal2D(m_gList[i][j], jj, ii+1.5) + cvGetReal2D(m_gList[i][j], jj, ii+0.5))/2 - (cvGetReal2D(m_gList[i][j], jj, ii-1.5) + cvGetReal2D(m_gList[i][j], jj, ii-0.5))/2;
	//		double dy = (cvGetReal2D(m_gList[i][j], jj+1.5, ii) + cvGetReal2D(m_gList[i][j], jj+0.5, ii))/2 - (cvGetReal2D(m_gList[i][j], jj-1.5, ii) + cvGetReal2D(m_gList[i][j], jj-0.5, ii))/2;

	//		unsigned int iii = ii+1;
	//		unsigned int jjj = jj+1;
	//		assert(iii<=width && jjj<=height);

	//		// Set the magnitude and orientation
	//		cvSetReal2D(imgInterpolatedMagnitude[i][j-1], jjj, iii, sqrt(dx*dx + dy*dy));
	//		cvSetReal2D(imgInterpolatedOrientation[i][j-1], jjj, iii, (atan2(dy,dx)==M_PI)? -M_PI:atan2(dy,dx) );
	//	}
	//}
}



