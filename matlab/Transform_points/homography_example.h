//Class to register registers IR image onto RGB one based on Thales cameras
//Transform matrix generated from Matlab
//tested on image sequence 4
//cb 10/5/12
//use:

#ifndef REGISTER_IR2RGB
#define REGISTER_IR2RGB
struct RegisterIR2RGB{
	cv::Size dstsize;
	RegisterIR2RGB(){ //constructor
		//source data from matlab
		double H_ir2rgbtformdata[3][3] = {   
			1.89003504682219,		0.0538324122312895,		0.00015750763780491, //T
			-0.0599317439468661,	1.96582761373326,	   -6.32895245205357e-005,
			1.5368308488851,	 -133.543605929011,			1.00408606426315
		};
		//matrix wrapper for above
		//note we need to transpose this matrix (THANKS MATLAB!)
		H_ir2rgbtform = cv::Mat(3,3,CV_64F,&H_ir2rgbtformdata).t();
		dstsize = cv::Size(1024,768);
		dstMatGpu_large = cv::Size(1024,900);
	}

	//CPU version, ~110ms runtime
	void reg(const cv::Mat& src, cv::Mat&  dst){
		cv::warpPerspective(src,dst,H_ir2rgbtform,dstsize);
	}

	//GPU version, ~20ms runtime
	void reg(const cv::gpu::GpuMat& src, cv::gpu::GpuMat& dst){
		//NPP won't let us put this within a 1024x788 window so drop it in a 
		//1024x900 window then adjust ROI down to 1024x768
		cv::gpu::warpPerspective(src,dst,H_ir2rgbtform,dstMatGpu_large);
		dst.adjustROI(0,768-900,0,0);
	}

private:
	double H_ir2rgbtformdata[3][3];
	cv::Mat H_ir2rgbtform;
	cv::Size dstMatGpu_large;

};

#endif
/* call with
RegisterIR2RGB ir2rgb;
ir2rgb.reg(src,dst);
*/