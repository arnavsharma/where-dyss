## Welcome to the Particle Filter README!

### How to Use Python Files

The Python files here extract up to 5 semantic annotations per sample (time-step) per scene. This data is then packaged in a quick 3D matrix to be sent to Matlab using .mat files. 

In */where-dyss/python-scripts/pf_data_to_matlab.py*, each sample is ran in a for-loop to utilize the Python function in */where-dyss/python-functions/grab_annotations_fcn.py*. There are very specific inputs needed in this Python function. Please read this function's description to better understand the format. Please read the *pf_data_to_matlab.py* file to see how the inputs are built to feed into the Python function.

### How to use Matlab Files

The packaged .mat files are then run in Matlab as a for-loop through the scenes we picked. The PF class definition is located in */where-dyss/output/Matlab/PF/particle_filter.m*. To utilize this class, the code running the for-loop through scenes, samples, and annotations (for particle position correction) is in */where-dyss/output/Matlab/PF/pf_run_me.m*. 

Running this script above will output the particle filter as an MPEG-4 video file along with a JPEG of the estimated states (*x* and *y* position of vehicle) against the ego pose outputted by a LiDAR state estimation algorithm developed by NuScenes. Additionally, a .mat file of the particle positions at every time-step and the final array of estimated states is saved for plotting on top of the 'fancy map' in Python. 
