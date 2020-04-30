# EECS 568, Winter 2020, Ford Team 1
#
# This script will find the respective indices of the desired scenes and save it into a pickle file to be imported into other scripts/functions.

from nuscenes.nuscenes import NuScenes
import numpy as np
import scipy.io as sio
import pandas as pd
import math
import os
import pickle

nusc = NuScenes(version='v1.0-trainval', dataroot='../../../../../../../../../Volumes/Arnie SSD/data/sets/nuscenes', verbose = True)

numScenes = 850

# Desired Scenes
desired_scenes = ['scene-0069', 'scene-0247', 'scene-0249', 'scene-0395', 'scene-0480', 'scene-1017', 'scene-1018', 'scene-1048', 'scene-0396']

sceneIndxDict = {}

# Find the respective indices
for i in range(0, len(desired_scenes)):
    for j in range(0, numScenes):
        # Load the index j scene
        my_scene = nusc.scene[j]
        # If my_scene has the same name as the desired scene in loop
        if my_scene['name'] == desired_scenes[i]:
            sceneIndxDict[desired_scenes[i]] = j
            
# Save sceneIndxDict into a pickle file
with open('scene_indices.pickle', 'wb') as f:
    pickle.dump(sceneIndxDict, f)
