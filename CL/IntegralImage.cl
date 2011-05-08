
#pragma OPENCL EXTENSION cl_khr_fp64: enable

void sum(__global double* data,int iImageX,int iImageY,int iDevGMEMOffset,int ImageWidth,int ImageHeight)
{

	for(int offset = 2; offset < ImageWidth; offset <<= 1)
	{
        if( iImageX-offset >= 0 )
		{
			barrier(CLK_GLOBAL_MEM_FENCE);
			double curr = data[iDevGMEMOffset];
			double prev = data[iDevGMEMOffset-offset];
			double result = prev + curr;
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
			double curr = data[iDevGMEMOffset];
			double prev = data[offsPrev];
			double result = prev + curr;
			barrier(CLK_GLOBAL_MEM_FENCE);
			data[iDevGMEMOffset] = result;	
		}
    }
}

__kernel void ckIntegralImg(__global uchar* ucSource,__global double* SumTable00,__global double* SumTable01,__global double* SumTable10,
		__global double* SumTable11,__global double* SumTable20,__global double* SumTable02,
		__global double* SumTable12,__global double* SumTable21,__global double* SumTable30,__global double* SumTable03,
		int ImageWidth, int ImageHeight, int channels)
{
	
	if( get_global_id(0) < ImageWidth && get_global_id(1) < ImageHeight )
	{
		int nChannels = channels;
		int iImageX = get_global_id(0) >= ImageWidth  ? ImageWidth-1  : get_global_id(0);
		int iImageY = get_global_id(1) >= ImageHeight ? ImageHeight-1 : get_global_id(1);
		int iDevGMEMOffset = mul24(iImageY, ImageWidth) + iImageX;

		uchar4 curr4 = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset,nChannels);
		double result = 0;

		if( iImageX > 0 )
		{
			uchar4 prev4 = GetDataFromGlobalMemory(ucSource,iDevGMEMOffset-1,nChannels);
			//sprawdzenie czy piksele naleza do segmentu
			result = 0.0;
			if( curr4.x == 0 ) result = 1.0;
			if( prev4.x == 0 ) result += 1.0;
		} else 
		{
			result = 0;
			if( curr4.x == 0 ) result = 1.0;
		}

		barrier(CLK_GLOBAL_MEM_FENCE);
		SumTable00[iDevGMEMOffset] = result;
		SumTable01[iDevGMEMOffset] = result*iImageY;
		SumTable10[iDevGMEMOffset] = result*iImageX;
		SumTable11[iDevGMEMOffset] = result*iImageY*iImageX;
		SumTable12[iDevGMEMOffset] = result*iImageX*iImageY*iImageY;
		SumTable21[iDevGMEMOffset] = result*iImageY*iImageX*iImageX;
		SumTable20[iDevGMEMOffset] = result*iImageX*iImageX;
		SumTable02[iDevGMEMOffset] = result*iImageY*iImageY;
		SumTable30[iDevGMEMOffset] = result*iImageX*iImageX*iImageX;
		SumTable03[iDevGMEMOffset] = result*iImageY*iImageY*iImageY;




		sum(SumTable00,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable01,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable10,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable11,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable20,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable02,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable12,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable21,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable30,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		sum(SumTable03,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		


	} // if( get_global_id(0) < ImageWidth && get_global_id(1) < ImageHeight )
}

double GetGeoMoments(__global double* data,int iImageX,int iImageY,int iDevGMEMOffset,int ImageWidth,int ImageHeight)
{
	int tlx = 0;
	int tly = 0;
	int brx = 49;
	int bry = 49;

	int offA = Offset(tlx,tly,ImageWidth);
	int offB = Offset(brx,tly,ImageWidth);
	int offC = Offset(tlx,bry,ImageWidth);
	int offD = Offset(brx,bry,ImageWidth);

	return data[offA] + data[offD] - data[offB] - data[offC];
}


//A----B
//|    |
//|    |
//C----D


//int Offset(int x, int y, int ImageWidth)
//{
//	int offset = mul24( (int)y, ImageWidth ) + x;
//	return offset;
//}

__kernel void ckInvMoments(__global double* SumTable00,__global double* SumTable01,__global double* SumTable10,
		__global double* SumTable11,__global double* SumTable20,__global double* SumTable02,
		__global double* SumTable12,__global double* SumTable21,__global double* SumTable30,__global double* SumTable03,
		int ImageWidth, int ImageHeight, int channels)
{

	int tlx = 0;
	int tly = 0;
	int brx = 0;
	int bry = 0;

	if( get_global_id(0) < ImageWidth && get_global_id(1) < ImageHeight )
	{
		int nChannels = channels;
		int iImageX = get_global_id(0) >= ImageWidth  ? ImageWidth-1  : get_global_id(0);
		int iImageY = get_global_id(1) >= ImageHeight ? ImageHeight-1 : get_global_id(1);
		int iDevGMEMOffset = mul24(iImageY, ImageWidth) + iImageX;
		
		

		double m00 = GetGeoMoments(SumTable00,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m01 = GetGeoMoments(SumTable01,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m10 = GetGeoMoments(SumTable10,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m11 = GetGeoMoments(SumTable11,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m20 = GetGeoMoments(SumTable20,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m02 = GetGeoMoments(SumTable02,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m12 = GetGeoMoments(SumTable12,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m21 = GetGeoMoments(SumTable21,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m03 = GetGeoMoments(SumTable03,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);
		double m30 = GetGeoMoments(SumTable30,iImageX,iImageY,iDevGMEMOffset,ImageWidth,ImageHeight);

		double mi00 = m00;
		double mi20 = m20 - m10 * m10 / m00;
		double mi02 = m02 - m01 * m01 / m00;
		double mi12 = m12 - 2*m01*m11/m00 - m01*m02/m00 + 2*m01*m01 / m00*m00;
		double mi21 = m21 - 2*m10*m11/m00 - m01*m20/m00 + 2*m10*m10 / m00*m00;
		double mi30 = m30 - 3*m10*m20/m00 + 2*m10*m10*m10/m00*m00;
		double mi03 = m03 - 3*m01*m02/m00 + 2*m01*m01*m01/m00*m00;

		double eta00 = m00;
		double eta20 = mi20/m00;
		double eta02 = mi02/m00;
		double eta21 = mi21 / pow(m00,1.5);
		double eta12 = mi12 / pow(m00,1.5);
		double eta30 = mi30 / pow(m00,1.5);
		double eta03 = mi03 / pow(m00,1.5);



		double M1 = eta20 + eta02;
		double M2 = (eta30 + eta12)*(eta30 + eta12) + (eta03 + eta21)*(eta03 + eta21);
		double M3 = (eta30 + 3*eta12)*(eta30 + eta12)*((eta30 + eta12)*(eta30 + eta12) - 3*(eta03 + eta21)*(eta03 + eta21))+
				 (3*eta21-eta03)*(eta03+eta21)*(3*(eta30+eta12)*(eta30+eta12) - (eta03 + eta21)*(eta03 + eta21));

		SumTable00[iDevGMEMOffset] = M3;
	}
}


