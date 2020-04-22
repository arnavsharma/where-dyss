# EECS 568, Winter 2020, Ford Team 1
# Script to save necessary data into .mat files for Particle Filter in Matlab


from nuscenes.nuscenes import NuScenes
import scipy.io as sio
import pickle
import numpy as np

nusc = NuScenes(version='v1.0-trainval', dataroot='../data/sets/nuscenes', verbose = True)
# If you have nusc saved in a .pickle file, import it here in Line 12. We have provided one but commented it out in case of errors if it is not transferrable to other machines due to directory setup.
#with open('../own_data/nusc.pickle', 'rb') as f:
#    nusc = pickle.load(f)


# Bring in scene index data
with open('../own_data/scene_indices.pickle', 'rb') as f:
    scenIndxDict = pickle.load(f)
    
# Desired Scenes
desired_scenes = ['scene-0069', 'scene-0247', 'scene-0249', 'scene-0395', 'scene-0480', 'scene-1017', 'scene-1018', 'scene-1048', 'scene-0396']

scene_indx_array = [scenIndxDict[desired_scenes[element]] for element in range(0, len(desired_scenes))]

# For loop through the different scenes to grab the data
# First bring in the python function that can extract the data
exec(open("../python-functions/grab_annotations_fcn.py").read())

# Determine largest number of samples and annotations to build a 3D matrix of the data to be packaged into .mat files
largest_nbr_samples = 0
largest_nbr_ann = 0
numSamplesPerScene = []
for i in range(0, len(scene_indx_array)):
    my_scene = nusc.scene[scene_indx_array[i]]
    numSamplesPerScene.append(my_scene['nbr_samples'])
    largest_nbr_samples = max(largest_nbr_samples, my_scene['nbr_samples'])
    for j in range(0, my_scene['nbr_samples']):
        (ann_des_pose, range_dist, bearing, xyz_diff, pose_recording_out) = grab_annotations_data(nusc, my_scene, j)
        largest_nbr_ann = max(largest_nbr_ann, len(ann_des_pose))
    
numSamplesPerScene = np.asarray(numSamplesPerScene)


# Set up zero 3D matrices to save data - easiest way for now
ann_des_pose_out_size = (len(scene_indx_array), largest_nbr_ann, largest_nbr_samples*3)
ann_des_pose_out = np.zeros(ann_des_pose_out_size)
range_dist_out_size = (len(scene_indx_array), largest_nbr_ann, largest_nbr_samples)
range_dist_out = np.zeros(range_dist_out_size)
pose_recording_out_size = (len(scene_indx_array), 3, largest_nbr_samples)
pose_recording_out = np.zeros(pose_recording_out_size)
bearing_out_size = (len(scene_indx_array), largest_nbr_ann, largest_nbr_samples)
bearing_out = np.zeros(bearing_out_size)

numAnnPerSampPerScene = np.zeros((len(scene_indx_array), largest_nbr_samples))

# For loop through the scenes and samples to fill in the zero matrices above
for i in range(0, len(scene_indx_array)):
    my_scene = nusc.scene[scene_indx_array[i]]
    
    for j in range(0, my_scene['nbr_samples']):
        # Call to grab_annotations_data function - read comments in that file to get a better understanding of how to use it and use the outputs
        (ann_des_pose, range_dist, bearing, xyz_diff, pose_recording) = grab_annotations_data(nusc, my_scene, j)
        
        # Make the list of arrays into a matrix
        ann_des_pose = np.asarray(ann_des_pose)
        if ann_des_pose.shape[0] == 1:
            # Fill in x, y, and z every block of 3 columns
            ann_des_pose_out[i][0, 3*j:3*j+3] = ann_des_pose
            if np.isnan(sum(ann_des_pose)):
                # If no annotation exists for the particular sample
                numAnnPerSampPerScene[i][j] = 0
            else:
                numAnnPerSampPerScene[i][j] = ann_des_pose.shape[0]
        else:
            ann_des_pose_out[i][0:ann_des_pose.shape[0], 3*j:3*j+3] = ann_des_pose

            numAnnPerSampPerScene[i][j] = ann_des_pose.shape[0]
    
        if range_dist:
            # Make the list of arrays into a matrix
            range_dist = np.asarray(range_dist)
            if range_dist.shape[0] > 0:
                range_dist_out[i][0:len(range_dist), j] = range_dist

        if pose_recording:
            # Make the list of arrays into a matrix
            pose_recording = np.asarray(pose_recording)
            pose_recording_out[i][0:len(pose_recording), j] = pose_recording
            
        if bearing:
            # Make the list of arrays into a matrix
            bearing = np.asarray(bearing)
            if bearing.shape[0] > 0:
                bearing_out[i][0:len(bearing), j] = bearing
            
    # Save each scene's data into its own .mat file with the scene name added at the front
    filename = desired_scenes[i] + '_data.mat'
    sio.savemat(filename, {'ann_des_pose_out':ann_des_pose_out[i], 'numSamplesPerScene':numSamplesPerScene[i], 'numAnnPerSampPerScene':numAnnPerSampPerScene[i], 'range_dist_out':range_dist_out[i], 'pose_recording_out':pose_recording_out[i], 'bearing_out':bearing_out[i]})
