# Code availability
Autonomous_tracking_algorithm.m script processes videos to track and find the centroid of the umbilical artery. It starts by loading the video and extracting its frames, then calculates the average color for each pixel across all frames to identify and remove grayscale (B-mode) pixels, leaving only the color Doppler regions. The code then calculates the differences between consecutive frames to detect the pulsatile region of the umbilical artery. Using these differences, the code segments the umbilical artery by filtering out noise and movement artifacts, and further refines this segmentation through mathematical operations to ensure only the relevant part of the artery is segmented.

Next, the algorithm identifies the centroid of the primary region in each frame. It uses standard deviation threshold to ensure that the sample gate is placed when movements are minimized. Finally, it marks the identified artery in the video frames with a colored overlay, making it easier to see and track. The processed video is then displayed, showing the tracked artery over time. This process involves advanced image processing techniques, but at its core, it's about detecting changes in color and motion to isolate and highlight the umbilical artery in a video.

This algorithm was utilized for optimization of the thresholds and offline evaluation of the autonomous tracking algorithm compared with a sonographer's sample gate.

# Software availability
This package is supported for macOS and Windows. The package has been tested on the following systems by using Matlab 2023b:

macOS: Sonoma (14.4.1)

Windows: Win 10

# Sample video availability
One example video "Sample.mp4" was collected from the umbilical cord of the pregnant woman. The video can be directly loaded obtaining the sample gate throughout the video.
