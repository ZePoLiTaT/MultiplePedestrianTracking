#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/highgui/highgui.hpp"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
#include <fstream>

using namespace cv;
using namespace std;

// static void help()
// {
//     printf(
//             "\nDemonstrate the use of the HoG descriptor using\n"
//             "  HOGDescriptor::hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());\n"
//             "Usage:\n"
//             "./peopledetect (<image_filename> | <image_list>.txt)\n\n");
// }

typedef struct _trackState
{
	Rect track;
	unsigned int lastTrackedFrame;
}TrackState;

double calculateDistance(Rect &detection, Rect &track)
{
	Point detectionCenter = Point((detection.x + detection.width) / 2.0f, (detection.y + detection.height) / 2.0f);
	Point trackCenter = Point((track.x + track.width) / 2.0f, (track.y + track.height) / 2.0f);
	Point difference = detectionCenter - trackCenter;

	return cv::sqrt( difference.x*difference.x + difference.y*difference.y );
}

void showinfo(vector<TrackState> &state, unsigned int frameNumber, ostream &out)
{
	Point detectionCenter;

	for (size_t i = 0; i < state.size(); i++)
	{
		if (state[i].lastTrackedFrame == frameNumber)
		{
			detectionCenter = Point((state[i].track.x + state[i].track.width) / 2.0f, (state[i].track.y + state[i].track.height) / 2.0f);

			out << " " << frameNumber 
				<< "," << i
				<< "," << state[i].track.x
				<< "," << state[i].track.y
				<< "," << state[i].track.width
				<< "," << state[i].track.height
				<< endl;
		}
		/*else
		{
			std::cout << "FN: " << frameNumber << " ID:" << i << " UNTRACKED "<<endl;
		}*/
	}
}

void match(vector<Rect> &detections, vector<TrackState> &state, unsigned int frame, double pixelThreshold = 10.0, unsigned int frameThreshold = 25)
{
	int TRACK_N = state.size();
	int DET_N = detections.size();

	vector<double> distances;
	vector<double>::iterator minElement;
	size_t minIndex;

	vector<bool> matched(DET_N);

	// Try to find a match for each element tracked
	for (size_t i = 0; i < TRACK_N; i++)
	{
		// If the current position lost track a long time ago, then just ignore it
		if ((frame - state[i].lastTrackedFrame) > frameThreshold)
			continue;

		distances.clear();
		distances.resize(DET_N);
		for (size_t j = 0; j < DET_N; j++)
		{
			// If the detection was already assigned to a track, then ignore it
			if (matched[j])
			{
				distances[j] = 100000;
			}
			else //Otherwise, calculate the euclidean distance between the last track and the detection
			{
				distances[j] = calculateDistance(detections[j], state[i].track);
			}
		}

		// The detection within less than a given threshold is the match of the current track
		minElement = std::min_element(distances.begin(), distances.end());
		if (minElement != distances.end() && *minElement < pixelThreshold)
		{
			// Extract the index from the iterator
			minIndex = minElement - distances.begin();
			matched[minIndex] = true;

			// Update the tracking state
			state[i].track = detections[minIndex];
			state[i].lastTrackedFrame = frame;
		}

	}

	// Add as new tracks the unmatched elements
	for (size_t i = 0; i < matched.size(); i++)
	{
		if (!matched[i])
		{
			TrackState newTrack = { detections[i], frame};

			state.push_back(newTrack);
		}
	}
}

int main(int argc, char** argv)
{
    Mat img;
    FILE* f = 0;
	ofstream fout;
    char _filename[1024];

    if( argc == 2 )
    {
        printf("Usage: peopledetect (<image_filename> | <image_list>.txt <track_output.txt>)\n");
        return 0;
    }
    img = imread(argv[1]);

    if( img.data )
    {
        strcpy(_filename, argv[1]);
    }
    else
    {
        f = fopen(argv[1], "rt");
        if(!f)
        {
            fprintf( stderr, "ERROR: the specified file could not be loaded\n");
            return -1;
        }


		fout.open(argv[2], ios::out);
    }

	//Tracker variables
	vector<TrackState> state;
	

    HOGDescriptor hog;
    hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
    namedWindow("people detector", 1);

    for(int frameNumber=0;;++frameNumber)
    {
        char* filename = _filename;
        if(f)
        {
            if(!fgets(filename, (int)sizeof(_filename)-2, f))
                break;
            //while(*filename && isspace(*filename))
            //  ++filename;
            if(filename[0] == '#')
                continue;
            int l = (int)strlen(filename);
            while(l > 0 && isspace(filename[l-1]))
                --l;
            filename[l] = '\0';
            img = imread(filename);
        }
        //printf("%s:\n", filename);
        if(!img.data)
            continue;

        fflush(stdout);
        vector<Rect> found, found_filtered;
        double t = (double)getTickCount();
        // run the detector with default parameters. to get a higher hit-rate
        // (and more false alarms, respectively), decrease the hitThreshold and
        // groupThreshold (set groupThreshold to 0 to turn off the grouping completely).
        hog.detectMultiScale(img, found, 0, Size(8,8), Size(32,32), 1.05, 2);
        t = (double)getTickCount() - t;
        //printf("tdetection time = %gms\n", t*1000./cv::getTickFrequency());
        size_t i, j;
        for( i = 0; i < found.size(); i++ )
        {
            Rect r = found[i];
            for( j = 0; j < found.size(); j++ )
                if( j != i && (r & found[j]) == r)
                    break;
            if( j == found.size() )
                found_filtered.push_back(r);
        }


        for( i = 0; i < found_filtered.size(); i++ )
        {
            Rect r = found_filtered[i];
            // the HOG detector returns slightly larger rectangles than the real objects.
            // so we slightly shrink the rectangles to get a nicer output.
            r.x += cvRound(r.width*0.1);
            r.width = cvRound(r.width*0.8);
            r.y += cvRound(r.height*0.07);
            r.height = cvRound(r.height*0.8);

            rectangle(img, r.tl(), r.br(), cv::Scalar(0,255,0), 3);

        }

		match(found_filtered, state, frameNumber);
		//showinfo(state, frameNumber, cout);
		showinfo(state, frameNumber, fout);

		imshow("people detector", img);

		/*if (frameNumber > 145)
		{
		int c = waitKey(0) & 255;
		if (c == 'q' || c == 'Q' || !f)
		break;
		}*/

    }
    if(f)
        fclose(f);

	fout.close();
    return 0;
}
