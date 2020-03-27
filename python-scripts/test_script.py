from nuscenes.nuscenes import NuScenes
import numpy as np
import scipy.io as sio
import math
import os

# Enter desired Scene Name below:
scene_name = 'scene-0574'

# Enter location of can_data below:
data_root = '../data/sets/nuscenes/'

# Open the can_data_fcn.py file into memory
exec(open("../python-functions/can_data_fcn.py").read())

# Use the function inside can_data_fcn.py to get the data
can_data_out = get_can_data(scene_name, data_root)

# To read, for example, the time vector of VEHICLE INFO MESSAGE:
print(can_data_out['veh_msgs']['utimes'])
