#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <boost/filesystem.hpp>
using namespace boost::filesystem;

//Calum Blair 24/1/12
//quick demo to show how to use boost to iterate through a folder
//of images in a sequence

//header
class FileSequence{
public:
	cv::Mat getNext(void);
	void setFolder(boost::filesystem::path);
	FileSequence(boost::filesystem::path);
	bool done;
private:
	bool initialised;
	boost::filesystem::directory_iterator iter_end_of_dir;
	boost::filesystem::directory_iterator file_iter;
	cv::Mat frame;
};

//code
using namespace std;
using namespace cv;
using namespace boost::filesystem;

FileSequence::FileSequence(boost::filesystem::path src_path){
	bool initialised  = false;
	setFolder(src_path);

}

void FileSequence::setFolder(boost::filesystem::path src_path){
	file_iter = boost::filesystem::directory_iterator(src_path);
	done = false;
	initialised = true;
}

cv::Mat FileSequence::getNext(void) 
{
	if (!initialised)
		throw("not initalised, call setFolder first");

	path current_file;
	if (file_iter != iter_end_of_dir){
		current_file = file_iter->path();
		cout << "input " << current_file.string() << endl;
		frame = imread(current_file.string());
		//if dumping detections etc.:
		//path outfile = outputpath /	current_file->stem();
		//outfile.replace_extension(".txt");
		//cout <<" output  "<< outfile <<endl;
		//*fp= fopen((outfile.string()).c_str(),"w");
		//if (!fp)
		//	throw( "error, couldn't open output file");
		//return true;
		file_iter++;
		return frame;
	}
	else 
	{
		cout << "all files processed" <<endl;
		done = true;
		return Mat(0,0,0);
	
	}
}

int main(int argc, char** argv){
	if (argc!=2)
		cout << "call with ./getNextFile.exe path_to_folder_with_images" <<endl;
	path src_path = string(argv[1]);

	FileSequence imagesequence(src_path);

	//files.setFolder(src_path);
	cvNamedWindow("img",0);
	Mat frame;
	while (!imagesequence.done){
		frame = imagesequence.getNext();
		try {
			imshow("img",frame);
		}
		catch (const Exception& e)
			{break;}
		cvWaitKey(50);
	}
	return 0;
}
