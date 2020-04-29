## Welcome to the Invariant EKF README!

### Invariant EKF Description

The invariant extended Kalman filter (IEKF) has been a recent discovery in the probabilistic methods space. It is up and coming and has many advantages compared to other filters. One advantage is the ability to use Lie Groups/Algebra - a modern breakthrough in mathematics.

In this IEKF, we have considered using the inertial measurement unit (IMU) at 100 Hz for state and covariance prediction. The ego pose data (pseudo-GPS) from a LiDAR map-based localization algorithm developed by nuScenes by Aptiv is utilized in the correction step.

Please check the project paper and MATLAB code (in */where-dyss/output/Matlab/IEKF_To_Python/*) to see the noise covariance matrices used in the prediction and correction steps.

### Step-by-step Instructions
1. Skip to Step 6 if you want to just visualize the 'scene-0249' data the group presented at the end of the Winter 2020 semester in Python.
2. The following code will all be run in MATLAB and then be visualized in a fancy manner in Python. Make sure to navigate to the */where-dyss/output/Matlab/IEKF_To_Python/* directory to start.
3. Open *iekf_run_me.m*
    1. Set Line 33 value to `1` if you would like to watch the IEKF plot live the estimated states and covariance ellipse. The final path the vehicle takes is automatically displayed after the filter runs regardless of this setting. The Mahalanobis and 3-Covariance plots are displayed as well.
    2. Set Line 34 value to `1` if you would like to save the data in .mat files to then be viewed in Python. They will be saved in this current directory, so please move them to */where-dyss/output/Matlab/IEKF_To_Python/data/*.
    3. Set Line 41 to your own desired scene number (in order to view the data on a Fancy Map in Python, please select one of our evaluated scenes as described in [dataREADME](.dataREADME.md). Make sure it is a string with length 4.
    4. If you would like to use the Mahalanobis calculations, please uncomment Lines 98-107, 163-174, and 194-227.
4. To check out more how the IEKF is designed and built, please take a look at the other functions in the current MATLAB directory including the IEKF.m class.
5. To view the data on a Fancy Map in Python, navigate to */where-dyss/python-functions/* and open a new Terminal in this folder. Type in `python3` to begin a Python3 terminal session. 
6. Bring the *iekf_fancy_map_img_creation.py* into the python workspace by running the following code: `exec(open("iekf_fancy_map_img_creation.py").read())`. Run the actual function by running `iekf_fancy_map_img_creation()`.
    1. In the start, the script will take a bit of time to run as it is indexing and reverse indexing the nuScenes data.
    2. Once indexing is complete, it will prompt you to enter in a scene number string (i.e. scene-0249). And then it'll start evaluating the scene!
    3. The .png images needed for a GIF animation will be saved in */where-dyss/output/Images/IEKF/concatenated_images/*
7. Navigate to the */where-dyss/output/Images/IEKF/concatenated_images/* directory in a normal Terminal session, and run the following in `convert -delay 1 -loop 0 <scene-entrystring_here>*.png <scene-entrystring_here>.gif` where `scene-entrystring_here` is for example 'scene-0249' without quotes. This will create a GIF of the data!
8. Here is a GIF of the result!

    ![scene-0249_gif_result](./scene-0249_iekf.gif )


### Quick Description of MATLAB Files

The getNusceneDataset.m function is a very powerful function in gathering all the necessary CAN bus data into a usable MATLAB structure object. It even has the capabilities of lining up the signals based on the ctime of each signal. This is crucial for a successful run of the IEKF filter. Due to the IMU data coming in at 100 Hz and the pseudo-GPS coming in at 50 Hz, we decided to predict twice using IMU and correct once using psuedo-GPS. 

Additionally, a Lie-to-Cartesian script is run to be able to view the covariance ellipse on the map. 

As seen in the paper, it is crucial to note that there are 9 dimensions in this setup. Therefore the covariance matrix is set up to be 9x9.
