def grab_annotations_data(nusc, my_scene, indx):

    # EECS 568, Winter 2020, Ford Team 1
    #
    # To bring this function into another function/script, please modify/run the following every time you make a change:
    # exec(open("grab_annotations_fcn.py").read())
    #
    # Inputs:
    #   nusc                - NuScenes instance
    #   my_scene            - scene instance using nusc.scene[instance_index]
    #   indx                - for-loop index through the samples in specified scene
    #
    # Outputs:
    #   ann_des_pose        - global x, y, and z positions of the annotations
    #   range_dist          - range distance (meters) to annotations from ego vehicle
    #   bearing             - bearing (radians) to annotations from ego vehicle
    #   xyz_diff            - difference in global x, y, and z positions between annotations and ego vehicle
    #   pose_recording_out  - global ego vehicle position in x, y, and z at this sample

    
    import numpy as np
    import math

    # Get the first sample token
    first_sample_token = my_scene['first_sample_token']
    
    # Get the sample associated with this token
    my_sample = nusc.get('sample', first_sample_token)
    
    # Create list of annotations that we want to save
    ann_desired = []
    for i in range(0, indx):
        if indx == 0:
            break
            
        # Get the next sample token
        next_sample_token = my_sample['next']
        
        # Get the sample associated with next sample token
        my_sample = nusc.get('sample', next_sample_token)
    
    # Setup
    range_dist = []
    bearing = []
    xyz_diff = []
    ann_des_pose = []
    perc_anns_desired = 0.2
    min_anns_suggested = 5
    
    # For loop through the first five annotations in selected sample
    if (not my_sample['anns']) or (len(my_sample['anns']) == 0):
        range_dist = np.array([math.nan])
        bearing = np.array([math.nan])
        xyz_diff = np.array([math.nan, math.nan, math.nan])
        ann_des_pose = np.array([math.nan, math.nan, math.nan])
    else:
        # Grab maximum 5 or 20% of annotations or minimum of that against total number in case if there are less than 5 annotations in one sample
        for i in range(0, min(max(min_anns_suggested, math.floor(perc_anns_desired*len(my_sample['anns']))),len(my_sample['anns']))):
            # Get the ith annotation instance
            ann_instance = nusc.get('sample_annotation', my_sample['anns'][i])
            ann_desired.append(ann_instance)
    
        # Get the range and bearing to the ego vehicle for each desired annotation
        for i in range(0, len(ann_desired)):
            # If LIDAR_TOP data exists in the sample
            if 'LIDAR_TOP' in my_sample['data']:
                # Get the recorded sample related to LIDAR_TOP
                lidar_sample_recording = nusc.get('sample_data', my_sample['data']['LIDAR_TOP'])

                # Obtain ego pose
                pose_recording = nusc.get('ego_pose', lidar_sample_recording['ego_pose_token'])

                # Save desired annotations' poses
                ann_des_pose.append(ann_desired[i]['translation'])

                # Calculate range distance and bearing to ego vehicle
                range_dist_calc = np.linalg.norm(np.array(pose_recording['translation']) - np.array(ann_desired[i]['translation']))
                xyz_diff_calc = np.array(ann_desired[i]['translation']) - np.array(pose_recording['translation'])
                bearing_calc = math.atan2(xyz_diff_calc[1], xyz_diff_calc[0])

                range_dist.append(range_dist_calc) # Range in meters
                bearing.append(bearing_calc) # Bearing in radians
                xyz_diff.append(xyz_diff_calc) # x y z difference in meters
                

    lidar_sample_recording = nusc.get('sample_data', my_sample['data']['LIDAR_TOP'])
    pose_recording_out = nusc.get('ego_pose', lidar_sample_recording['ego_pose_token'])['translation']


    # Output of main function
    return ann_des_pose, range_dist, bearing, xyz_diff, pose_recording_out
