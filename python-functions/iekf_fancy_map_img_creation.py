def iekf_fancy_map_img_creation():

	# EECS 568, Winter 2020, Ford Team 1
	#
	# To bring this function into another function/script, please modify/run the following every time you make a change:
	# exec(open("iekf_fancy_map_img_creation.py").read())
	#
	# Use this script to plot all of the Invariant EKF data on the nuScenes Fancy Map and output the final path
	#
    # Inputs:
    #   None
    #
    # Outputs:
    #   Figures of the fancy map with IEKF performance

	# Since boot up takes a while, print a message
    print('\nThis may take a while, please wait . . .')

    # Embedded function to open desired .py files into function workspace
    def func_call(filename):
        exec(open(filename).read(), globals(), globals())
    
    # Initialize Everything
    func_call("./init_everything.py")

    # Bring in grab_annotations_fcn.py (grab_annotations_data function)
    func_call("./grab_annotations_fcn.py")

    # Convert IEKF data from Matlab to Python. This outputs the data in an array named "arrays"
    func_call("./convert_matlab_to_python.py")
    
    # Bring in plot_car_fcn.py (plot_car function)
    func_call("./plot_car_fcn.py")

    # Set up directory showing where final images will be saved to
    dir_to_save = '../output/Images/IEKF/concatenated_images/'

    # Define dataset
    nusc = NuScenes(version='v1.0-trainval', dataroot='../data/sets/nuscenes', verbose=False)

    # Which scene would you like to look at?
    print('\nWhich scene would you like to evaluate?\n','scene-0069, scene-0247, scene-0249, scene-0395,\n', 'scene-0396, scene-0480, scene-1017, scene-1018\n','Input must be in the format "scene-XXXX" (i.e. scene-0249)\n')
    scene_name_str = input()

    # List of desired scenes
    des_scene_tkns = [nusc.field2token('scene', 'name', 'scene-0069'), nusc.field2token('scene', 'name', 'scene-0247'), nusc.field2token('scene', 'name', 'scene-0249'), nusc.field2token('scene', 'name', 'scene-0395'), nusc.field2token('scene', 'name', 'scene-0396'), nusc.field2token('scene', 'name', 'scene-0480'), nusc.field2token('scene', 'name', 'scene-1017'), nusc.field2token('scene', 'name', 'scene-1018')]

    # Desired scene indexing numbers (Use this for normal use. Since it doesn't work on my machine, using hard coded version
    with open('../own_data/scene_indices.pickle', 'rb') as f:
        scenIndxDict = pickle.load(f)

    # Check to see if the token of that scene exists in the list of desired scenes
    scene_tkn = nusc.field2token('scene', 'name', scene_name_str)

    # If the scene token does not appear in the desired scenes list, try again
    if scene_tkn not in des_scene_tkns:
        print('Invalid entry. Please try again using the format "scene-XXXX" (i.e. scene-0249)')
        print('Come back into Python by running: python3 in Terminal')
        raise SystemExit

    else:
        arrays = convert_matlab_to_python('IEKF',scene_name_str[6:])
        print('\n', 'Evaluating ', scene_name_str, '. . .')

    # Determine scene indexing value
    if scene_name_str in scenIndxDict:
        scene_val = scenIndxDict[scene_name_str]

    my_scene = nusc.scene[scene_val]


    # Define maps to be used
    scene_map = nusc.get('log', my_scene['log_token'])['location']

    if scene_map == 'boston-seaport':
        nusc_map = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='boston-seaport')

    elif scene_map == 'singapore-queenstown':
        nusc_map = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='singapore-queenstown')

    elif scene_map == 'singapore-hollandvillage':
        nusc_map_singh = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='singapore-hollandvillage')

    elif scene_map == 'singapore-onenorth':
        nusc_map_singo = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='singapore-onenorth')

    else:
        print('Map does not exist. Please try another scene.')
        print('Restart Python by running: python3 in Terminal')
        raise SystemExit

    # Get ground truth data (ego pose data for practice)
    xyz_pose_all = []
    for i in range(0, my_scene['nbr_samples']):
        (ann_des_pose, range_dist, bearing, xyz_diff, pose_recording_out) = grab_annotations_data(nusc, my_scene, i)
        xyz_pose_all.append(pose_recording_out)
    xyz_pose_all = np.asarray(xyz_pose_all)
    x_pose_plot = xyz_pose_all[:, 0]
    y_pose_plot = xyz_pose_all[:, 1]

    # Get yaw data (theta in plot_car.py)
    yaw_data = arrays['yaw_plot']

    # Get velocity data
    veh_velocity = arrays['v_long_plot']

    # Get center of vehicle
    x_plot = arrays['x_plot']
    y_plot = arrays['y_plot']
    print(arrays)
    
    # Get ellipse data for covariance
    ELLIPSE = arrays['ELLIPSE']

    # Generate fancy map for the scene
    ego_poses = nusc_map.render_egoposes_on_fancy_map(nusc, scene_tokens=[my_scene['token']], verbose=False, out_path=None, render_egoposes=False, render_egoposes_range=False)

    # Plot the full ground truth line on fancy map for the scene (black line)
    plt.plot(x_pose_plot, y_pose_plot, linestyle = '-', linewidth = 4, c='k', zorder = 12)

    # Plot vehicle on fancy map
    for i in range(0, len(yaw_data)):
        (Xrot, Yrot) = plot_car(x_plot[i], y_plot[i], yaw_data[i])
        Xc = x_plot[i]
        Yc = y_plot[i]

        veh_pos = plt.plot((Xrot + Xc), (Yrot + Yc), linestyle = '-', linewidth = 5, c='r', zorder = 13)

        pos_line = plt.plot(x_plot[0:i], y_plot[0:i], linestyle = '-', linewidth = 5, c='r', zorder = 13)
        
        ellipse_cov = plt.plot(ELLIPSE[i*2,:], ELLIPSE[i*2+1,:], linestyle = '-', linewidth = 3, c='b', zorder = 13)

        # Save sample plot into specified directory and clear the map
        kurs = dir_to_save + scene_name_str + "_iekf_%02i.png" % i
        plt.savefig(kurs, format = 'png', bbox_inches = "tight")

        veh_pos[0].remove()
        pos_line[0].remove()
        ellipse_cov[0].remove()
        print('\nData Point ' + str(i) + ' of ' + str(len(yaw_data)-1))

    # Once program is finished running
    print('Evaluation complete!')
    print('To view the data as a .gif video, please run the following code in normal Terminal:')
    print('cd ../output/Images/IEKF/concatenated_images/')
    print('Before running the next line, recall which scene you had evaluated, and save the .gif with that name.')
    print('convert -delay 1 -loop 0 <scene-entrystring>*.png <scene-entrystring_here>.gif')
