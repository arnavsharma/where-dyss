def get_can_data(scene_name, data_root):

    # This py file has a function inside called 'get_can_data(scene_name, data_root)'.
    # It requires two inputs (both strings like 'blah') of the scene_name (e.g. 'scene_0565') and data_root (e.g. '../data/sets/nuscenes'). The can_bus data (as .json files) must be sitting in a can_bus folder in data/sets/nuscenes. The two dots before data are to go up a level. The can_bus data is kept in this folder in the repo but is ignored when pushing up to GitHub as it is a large sized folder than what GitHub would recommend.

    # To bring the internal function 'get_can_data' into the workspace, run the following code:
    # exec(open("../python-functions/can_data_fcn.py").read())

    # This will allow you to use get_can_data function as you please. An example of how it is used is located in python-scripts/test_script.py.

    # When you get the data as a variable name of your choice, the breakdown of the data is as follows:
    # a. Pick the CAN Message you want.
    # b. Pick the CAN Signal you want.

    # ii. veh_msgs:         utimes, fl_wheel_speed, fr_wheel_speed, rl_wheel_speed, rr_wheel_speed
    #   pose_msgs:      utimes, veh_speed, x, y, rot_quaternion_mat
    #   imu_msgs:         utimes, accel_x, accel_y, accel_z, rot_quaternion_mat, roll_rate, pitch_rate, yaw_rate
    #   veh_monitor_msgs:     utimes, swa_data, swa_rate_data, veh_speed, yaw_rate

    # For the data frequency (time-step):
    #   veh_msgs:           100 Hz
    #   pose_msgs:            50 Hz
    #   imu_msgs:           100 Hz
    #   vehicle_monitor_msgs:     2 Hz

    from nuscenes.can_bus.can_bus_api import NuScenesCanBus
    import numpy as np
    import scipy.io as sio
    import math
    import matplotlib.pyplot as plt

#    nusc_can = NuScenesCanBus(dataroot='../../../../../../../Volumes/Arnie SSD/data/sets/nuscenes')
    nusc_can = NuScenesCanBus(dataroot = data_root)
    #scene_name = 'scene-0574'
    

    ############# VEHICLE INFO MESSAGE ##################################
    # Obtain time array of vehicle info message
    veh_messages = nusc_can.get_messages(scene_name, 'zoe_veh_info')
    veh_utimes = np.array([m['utime'] for m in veh_messages])
    veh_msgs_utimes = (veh_utimes - min(veh_utimes)) / 1e6 # Units: sec

    # Obtain the four different wheel speed sensor data
    veh_fl_wheel_speed_data = np.array([m['FL_wheel_speed'] for m in veh_messages]) # Units: rpm
    veh_fr_wheel_speed_data = np.array([m['FR_wheel_speed'] for m in veh_messages]) # Units: rpm
    veh_rl_wheel_speed_data = np.array([m['RL_wheel_speed'] for m in veh_messages]) # Units: rpm
    veh_rr_wheel_speed_data = np.array([m['RR_wheel_speed'] for m in veh_messages]) # Units: rpm

    # Convert wheel speed data to linear velocity for each wheel
    veh_r_wheel = 0.305; # Units: m
    veh_msgs_fl_wheel_speed_data = veh_fl_wheel_speed_data * 2 * math.pi * veh_r_wheel / 60 # Units: mps
    veh_msgs_fr_wheel_speed_data = veh_fr_wheel_speed_data * 2 * math.pi * veh_r_wheel / 60 # Units: mps
    veh_msgs_rl_wheel_speed_data = veh_rl_wheel_speed_data * 2 * math.pi * veh_r_wheel / 60 # Units: mps
    veh_msgs_rr_wheel_speed_data = veh_rr_wheel_speed_data * 2 * math.pi * veh_r_wheel / 60 # Units: mps

    # Obtain steering wheel angle (swa) sensor data
    veh_msgs_swa_data = np.array([m['steer_corrected'] for m in veh_messages]) # Units: deg

    veh_msgs = {
                'utimes': veh_msgs_utimes,
                'fl_wheel_speed': veh_msgs_fl_wheel_speed_data,
                'fr_wheel_speed': veh_msgs_fr_wheel_speed_data,
                'rl_wheel_speed': veh_msgs_rl_wheel_speed_data,
                'rr_wheel_speed': veh_msgs_rr_wheel_speed_data,
                }


    ############# POSE MESSAGE ##################################
    # Obtain time array of pose message
    pose_messages = nusc_can.get_messages(scene_name, 'pose')
    pose_utimes = np.array([m['utime'] for m in pose_messages])
    pose_msgs_utimes = (pose_utimes - min(pose_utimes)) / 1e6 # Units: sec

    # Obtain vehicle speed; in the ego vehicle frame
    pose_msgs_veh_speed = np.array([m['vel'] for m in pose_messages]) # Units: mps

    # Obtain x position from southeast corner of the map
    pose_msgs_x = np.array([m['pos'][0] for m in pose_messages]) # Units: m

    # Obtain y position from southeast corner of the map
    pose_msgs_y = np.array([m['pos'][1] for m in pose_messages]) # Units: m

    # Obtain Quaternion Rotation matrix - outputs as an array; in the ego vehicle frame
    pose_msgs_rot_quaternion_mat = np.array([m['orientation'] for m in pose_messages]) # Units: dimension-less

    pose_msgs = {
                 'utimes': pose_msgs_utimes,
                 'veh_speed': pose_msgs_veh_speed,
                 'x': pose_msgs_x,
                 'y': pose_msgs_y,
                 'rot_quaternion_mat': pose_msgs_rot_quaternion_mat,
                }
    
    
    ############# IMU MESSAGE ##################################
    # Obtain time array of IMU message
    imu_messages = nusc_can.get_messages(scene_name, 'ms_imu')
    imu_utimes = np.array([m['utime'] for m in imu_messages])
    imu_msgs_utimes = (imu_utimes - min(imu_utimes)) / 1e6 # Units: sec

    # Obtain Acceleration in x direction
    imu_msgs_accel_x = np.array([m['linear_accel'][0] for m in imu_messages]) # Units: m/s/s

    # Obtain Acceleration in y direction
    imu_msgs_accel_y = np.array([m['linear_accel'][1] for m in imu_messages]) # Units: m/s/s

    # Obtain Acceleration in z direction
    imu_msgs_accel_z = np.array([m['linear_accel'][2] for m in imu_messages]) # Units: m/s/s

    # Obtain Quaternion Rotation matrix - outputs as an array
    imu_msgs_rot_quaternion_mat = np.array([m['q'] for m in imu_messages]) # Units: dimension-less

    # Obtain Roll Rate
    imu_msgs_roll_rate = np.array([m['rotation_rate'][0] for m in imu_messages]) # Units: rad/s

    # Obtain Pitch Rate
    imu_msgs_pitch_rate = np.array([m['rotation_rate'][1] for m in imu_messages]) # Units: rad/s

    # Obtain Yaw Rate
    imu_msgs_yaw_rate = np.array([m['rotation_rate'][2] for m in imu_messages]) # Units: rad/s

    imu_msgs = {
                'utimes': imu_msgs_utimes,
                'accel_x': imu_msgs_accel_x,
                'accel_y': imu_msgs_accel_y,
                'accel_z': imu_msgs_accel_z,
                'rot_quaternion_mat': imu_msgs_rot_quaternion_mat,
                'roll_rate': imu_msgs_roll_rate,
                'pitch_rate': imu_msgs_pitch_rate,
                'yaw_rate': imu_msgs_yaw_rate,
                }
                

    ############# VEHICLE MONITOR MESSAGE ##################################
    # Note this is different than the Vehicle Info message. This is recorded at a slower frequency.
    # Obtain time array of Vehicle Monitor message
    veh_monitor_messages = nusc_can.get_messages(scene_name, 'vehicle_monitor')
    veh_monitor_utimes = np.array([m['utime'] for m in veh_monitor_messages])
    veh_monitor_msgs_utimes = (veh_monitor_utimes - min(veh_monitor_utimes)) / 1e6 # Units: sec

    # Obtain steering wheel angle (swa) sensor data
    veh_monitor_msgs_swa_data = np.array([m['steering'] for m in veh_monitor_messages]) # Units: deg

    # Obtain steering wheel angle rate (swa_dot) sensor data
    veh_monitor_msgs_swa_rate_data = np.array([m['steering_speed'] for m in veh_monitor_messages]) # Units: deg/s

    # Obtain vehicle speed sensor data
    veh_monitor_msgs_veh_speed = np.array([m['vehicle_speed'] for m in veh_monitor_messages]) # Units: km/h

    # Obtain yaw rate sensor data
    veh_monitor_msgs_yaw_rate = np.array([m['yaw_rate'] for m in veh_monitor_messages]) # Units: deg/s

    veh_monitor_msgs = {
                        'utimes': veh_monitor_msgs_utimes,
                        'swa_data': veh_monitor_msgs_swa_data,
                        'swa_rate_data': veh_monitor_msgs_swa_rate_data,
                        'veh_speed': veh_monitor_msgs_veh_speed,
                        'yaw_rate': veh_monitor_msgs_yaw_rate,
                        }



    # Pass all structures into can_data_out
    can_data_out = {
                    'veh_msgs': veh_msgs,
                    'pose_msgs': pose_msgs,
                    'imu_msgs': imu_msgs,
                    'veh_monitor_msgs': veh_monitor_msgs,
                    }
    
    
    
    

    # Save the long_accel data into a mat file
    #sio.savemat('np_vector.mat', {'long_accel':data})

    # Plot mps wheel speeds and mps vehicle speed together
    #plt.plot(pose_x, pose_y)
    #plt.show()
    #nusc_can.plot_baseline_route(scene_name)
    
    return can_data_out
