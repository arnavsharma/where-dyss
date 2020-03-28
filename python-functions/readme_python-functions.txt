README for python-functions

1. can_data_fcn.py

This py file has a function inside called 'get_can_data(scene_name, data_root)'.
It requires two inputs (both strings like 'blah') of the scene_name (e.g. 'scene_0565') and data_root (e.g. '../data/sets/nuscenes'). The can_bus data (as .json files) must be sitting in a can_bus folder in data/sets/nuscenes. The two dots before data are to go up a level. The can_bus data is kept in this folder in the repo but is ignored when pushing up to GitHub as it is a large sized folder than what GitHub would recommend. 

To bring the internal function 'get_can_data' into the workspace, run the following code:
exec(open("../python-functions/can_data_fcn.py").read())

This will allow you to use get_can_data function as you please. An example of how it is used is located in python-scripts/test_script.py.

When you get the data as a variable name of your choice, the breakdown of the data is as follows:
a. Pick the CAN Message you want.
b. Pick the CAN Signal you want.

ii. veh_msgs: 		utimes, fl_wheel_speed, fr_wheel_speed, rl_wheel_speed, rr_wheel_speed
    pose_msgs:  	utimes, veh_speed, x, y, rot_quaternion_mat
    imu_msgs: 		utimes, accel_x, accel_y, accel_z, rot_quaternion_mat, roll_rate, pitch_rate, yaw_rate
    veh_monitor_msgs: 	utimes, swa_data, swa_rate_data, veh_speed, yaw_rate

For the data frequency (time-step):
	veh_msgs: 	      100 Hz
	pose_msgs: 	       50 Hz
	imu_msgs: 	      100 Hz
	vehicle_monitor_msgs: 	2 Hz