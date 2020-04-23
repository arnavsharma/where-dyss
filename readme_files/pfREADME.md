## Welcome to the Particle Filter README!

### Particle Filter Description

The particle filter is a widely used filter in robotics, autonomous vehicles, and other industries today. It is versatile, easy to understand, yet powerful enough to meet the needs of many problems.

We have assumed we do not know the input from the driver (steering, acceleration), therefore the model is built on a random walk model. The measurement sees range and bearing of each landmark as it comes in. We wanted to limit the number of landmarks used in the filter as a large number of landmarks will lock in the particles directly on top of each other and therefore will lead to sample impoverishment.

Please check the project paper and Matlab code (in */where-dyss/output/Matlab/PF_To_Python/*) to see the noise covariance matrices used for the motion model, measurement model, etc.

### Step-by-step Instructions
1. Skip to Step 10 if you want to just visualize the 'scene-0249' data the group presented at the end of the Winter 2020 semester in Python.
2. The following code in Step 2.iv will be run in a *normal* terminal window (not in a Python3 terminal). The starting directory will be */where-dyss/python-scripts*. Step 2.iv may take some time to run, so please be patient
3. `python3 pf_data_to_matlab.py`
    1. This will save the landmarks (annotations) position and ego vehicle position among other housekeeping items such as number of samples per scene, number of annotations per sample per scene, etc.
    2. The resulting .mat files will be saved in */where-dyss/python-scripts*. Please move them to */where-dyss/own_data/PF_To_Matlab/Variable_Landmarks*.
4. Open an instance of Matlab and navigate the current directory to */where-dyss/output/Matlab/PF_To_Python*. The .m files here (pf_run_me.m and particle_filter.m) will simulate the particle filter.
5. If you would like to not save an MP4 video of the particles being propagated and corrected **and** a JPG of the final estimated states path on top of ego_pose (ground truth), set `want_videos_jpg` to `0` in Line 22 of *pf_run_me.m*. Leave it set to `1` if you want to save MP4 videos of each scene. The videos and images will be saved in this directory. Kindly move them one level down into *Variable_Landmarks* folder.
6. If you would like to not save the .mat files for animation purposes in Python, set `want_mat_files` to `0` in Line 23 of *pf_run_me.m*. Leave it set to `1` if you want to save .mat files for each scene. As in the previous step, please kindly move the .mat files one level down into *Variable_Landmarks* folder.
7. The resulting directory if both save options are set to `1` will look like the following:
    
    ![pf .mat file directory](readme_files/pf_mat_file_directory.png)
    
8. Now that the data has been saved, we can visualize it in Python!
9. In a new Terminal window, navigate to */where-dyss/python-functions/* directory and start a python3 terminal session by running `python3`.
10. Run `exec(open("pf_fancy_map_img_creation.py).read())`
11. Then run `pf_fancy_map_img_creation()`
    1. In the start, the script will take a bit of time to run as it is indexing and reverse indexing the NuScenes data.
    2. Once indexing is complete, it will prompt you to enter in a scene number string (i.e. scene-0249). And then it'll start evaluating the scene!
    3. The .png images needed for a GIF animation will be saved in */where-dyss/output/Images/PF/*
12. Navigate to the */where-dyss/output/Images/PF/* directory in a normal Terminal session, and run the following in `convert -delay 50 -loop 0 <scene-entrystring_here>*.png <scene-entrystring_here>.gif` where `scene-entrystring_here` is for example 'scene-0249' without quotes. This will create a GIF of the data!
13. Here is a GIF of the result!

    ![scene-0249_gif_result](readme_files/scene-0249.gif )


### Quick Description of Python Files

The Python files here extract up to 20% of the semantic annotations sensed per sample (time-step) per scene. This data is then packaged in a quick 3D matrix to be sent to Matlab using .mat files. 

In */where-dyss/python-scripts/pf_data_to_matlab.py*, each sample is ran in a for-loop to utilize the Python function in */where-dyss/python-functions/grab_annotations_fcn.py*. There are very specific inputs needed in this Python function. Please read this function's description to better understand the format. Please read the *pf_data_to_matlab.py* file to see how the inputs are built to feed into the Python function.

### Quick Description of Matlab Files

The packaged .mat files are then run in Matlab as a for-loop through the scenes we picked. The PF class definition is located in */where-dyss/output/Matlab/PF/particle_filter.m*. To utilize this class, the code running the for-loop through scenes, samples, and annotations (for particle position correction) is in */where-dyss/output/Matlab/PF/pf_run_me.m*. 

Running this script above will output the particle filter as an MPEG-4 video file along with a JPEG of the estimated states (*x* and *y* position of vehicle) against the ego pose outputted by a LiDAR state estimation algorithm developed by NuScenes. Additionally, a .mat file of the particle positions at every time-step and the final array of estimated states is saved for plotting on top of the 'fancy map' in Python. 
