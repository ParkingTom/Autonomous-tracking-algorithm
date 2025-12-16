# Code availability
Autonomous_tracking_algorithm.m script processes videos to track and find the sample gate for the umbilical artery. It starts by loading the video and extracting individual frames. Then, the average color for each pixel across all frames are calculated to identify and remove grayscale (B-mode) pixels, leaving only the color Doppler signals. The algorithm then calculates the differences between consecutive frames to detect the pulsatile region of the umbilical artery. Using these differences, the code segments the umbilical artery by filtering out noise and movement artifacts, and further refines this segmentation through mathematical operations to ensure only the relevant part of the artery is segmented. Next, the algorithm identifies the centroid of the primary region in each frame. It uses standard deviation threshold to ensure that the sample gate is placed when movements are minimized. Finally, it shows the sample gate on the identified artery. The processed video is displayed, showing the tracked sample gate over time.

This algorithm was utilized for optimization of the thresholds. Additionally, offline evaluation of the identified sample gate by the autonomous tracking algorithm was compared with the sample gate of a sonographer.

# Software availability
This package is supported for macOS and Windows. The package has been tested on the following systems by using Matlab 2023b:

macOS: Sonoma (14.4.1)

Windows: Win 10

MATLAB Image processing Toolbox Version 11.3 is required to run this code.

# Sample availability
One example video "Sample.mp4" was collected from the umbilical cord of the pregnant woman. The video can be directly loaded obtaining the sample gate throughout the video.
