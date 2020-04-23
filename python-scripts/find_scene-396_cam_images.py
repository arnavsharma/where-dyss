from nuscenes.nuscenes import NuScenes
import numpy as np
import scipy.io as sio
import math
import os
import pickle
import matplotlib.pyplot as plt

nusc = NuScenes(version='v1.0-trainval', dataroot='/Volumes/Apollo/data/sets/nuscenes', verbose = True)

# Enter desired Scene Name below:
scene_name = 'scene-0396'

# Find the index of this scene:
with open('../own_data/scene_indices.pickle', 'rb') as f:
    scenIndxDict = pickle.load(f)
    
scenIndx = scenIndxDict[scene_name]
my_scene = nusc.scene[scenIndx]

my_sample = nusc.get('sample', my_scene['first_sample_token'])

cam_front_token = my_sample['data']['CAM_FRONT']

cam_front_data = nusc.get('sample_data', cam_front_token)

for i in range(0, my_scene['nbr_samples']):
    print(i*0.5)
    nusc.render_sample_data(cam_front_data['token'])
    
    if i < my_scene['nbr_samples'] - 1:
        my_sample = nusc.get('sample', my_sample['next'])
        cam_front_token = my_sample['data']['CAM_FRONT']
        cam_front_data = nusc.get('sample_data', cam_front_token)
    
    plt.show()
    plt.pause(0.5)
    plt.close()
