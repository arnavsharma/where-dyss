def pf_fancy_map_img_creation():

    # EECS 568, Winter 2020, Ford Team 1
    #
    # To bring this function into another function/script, please modify/run the following every time you make a change:
    # exec(open("pf_fancy_map_img_creation.py").read())
    #
    # Use this script to plot all of the Particle Filter points on the NuScenes Fancy Map and output the final path
    #

    # Since boot up takes a while, print a message
    print('This may take a while, please wait . . .')

    # Embedded function to open desired .py files into function workspace
    def func_call(filename):
        exec(open(filename).read(), globals(), globals())
    
    # Initialize Everything
    func_call("./init_everything.py")

    # Bring in grab_annotations_fcn.py (grab_annotations_data function)
    func_call("./grab_annotations_fcn.py")

    # Convert Particle Filter points from Matlab to Python. This outputs the data in an array named "arrays"
    func_call("./convert_matlab_to_python.py")

    # Set up directory showing where final images will be saved to
    dir_to_save = '../output/Images/PF/'

    # Define dataset
    nusc = NuScenes(version='v1.0-trainval', dataroot='../data/sets/nuscenes', verbose=False)

    # Which scene would you like to look at?
    print('Which scene would you like to look at?\n','scene-0069, scene-0247, scene-0249, scene-0395,\n', 'scene-0396, scene-0480, scene-1017, scene-1018\n','Input must be in the format "scene-XXXX" (i.e. scene-0249)\n')
    scene_name_str = input()

    # List of desired scenes
    des_scene_tkns = [nusc.field2token('scene', 'name', 'scene-0069'), nusc.field2token('scene', 'name', 'scene-0247'), nusc.field2token('scene', 'name', 'scene-0249'), nusc.field2token('scene', 'name', 'scene-0395'), nusc.field2token('scene', 'name', 'scene-0396'), nusc.field2token('scene', 'name', 'scene-0480'), nusc.field2token('scene', 'name', 'scene-1017'), nusc.field2token('scene', 'name', 'scene-1018')]

    # Desired scene indexing numbers
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
        arrays = convert_matlab_to_python(scene_name_str)
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
        print('Come back into Python by running: python3 in Terminal')
        raise SystemExit


    # Get ground truth data
    xyz_pose_all = []
    for i in range(0, my_scene['nbr_samples']):
        (ann_des_pose, range_dist, bearing, xyz_diff, pose_recording_out) = grab_annotations_data(nusc, my_scene, i)
        xyz_pose_all.append(pose_recording_out)
    xyz_pose_all = np.asarray(xyz_pose_all)
    x_pose_plot = xyz_pose_all[:, 0]
    y_pose_plot = xyz_pose_all[:, 1]

    # Get the number of annotated landmarks per sample in the specified scene from .mat file
    ann_land = []
    num_ann = arrays['numAnnPerSampPerScene']

    for i in range(0, len(num_ann)):
        conv_array_to_int = int(num_ann[i])
        ann_land.append(conv_array_to_int)

    # Get coordinates for all landmarks in each sample in the specified scene from .mat file
    xyz_landmarks = []
    land = arrays['ann_des_pose_out']

    # Get final particle filter path data
    current_data_string_final = 'x'
    xy_final = arrays[current_data_string_final]
    x_pf_final = []
    y_pf_final = []

    # Generate fancy map for the scene
    ego_poses = nusc_map.render_egoposes_on_fancy_map(nusc, scene_tokens=[my_scene['token']], verbose=False, out_path=None, render_egoposes=False, render_egoposes_range=False)

    # Plot the full ground truth line on fancy map for the scene (black line)
    plt.plot(x_pose_plot, y_pose_plot, linestyle = '-', linewidth = 4, c='k', zorder = 12)

    # Find landmarks needed, generate Particle Filter, and see how it performs compared to the ground truth
    for i in range(0, my_scene['nbr_samples']):
        
        # Determine how many landmarks will be used for the particle filter in each sample.
        landmarks_used = ann_land[i]
        
        # Find the x and y coordinates of the annotated landmarks used for Particle Filter
        x_land = []
        y_land = []
        for j in range(0, landmarks_used):
            x_land.append(land[(3*i), j])
            y_land.append(land[(3*i+1), j])
       
        # Plot the landmarks used for Particle Filter on fancy map (blue triangles)
        land_scatter = plt.scatter(x_land, y_land, s=250, c='b', marker='^', zorder=13)
            
        # Get Particle Filter particle data
        current_data_string = 'p_x_' + str(i+1)
        xy = arrays[current_data_string]
        x_pf = xy[:, 0]
        y_pf = xy[:, 1]
        
        # Generate Particle Filter prediction line from particle data
        if i == 0 or i == 1:
            x_pf_final.append(xy_final[0, 0])
            y_pf_final.append(xy_final[0, 1])
        else:
            x_pf_final.append(xy_final[i-1, 0])
            y_pf_final.append(xy_final[i-1, 1])
            
        # Plot Particle Filter particles on fancy map (white circles)
        pf_scatter = plt.scatter(x_pf, y_pf, s=150, c='w', marker='o', edgecolor='k', zorder=15)
            
        # Plot Particle Filter prediction line on fancy map (white line)
        pred_line = plt.plot(x_pf_final, y_pf_final, linestyle = '-', linewidth = 4, c='w', zorder = 14)
        
        # Save sample plot into specified directory and clear the map
        kurs = dir_to_save + scene_name_str + "pfn_%02i.png" % i
        plt.savefig(kurs, format = 'png', bbox_inches = "tight")
        
        land_scatter.remove()
        pf_scatter.remove()
        pred_line[0].remove()
        

    # Get final particle filter path data
    current_data_string_final = 'x'
    xy_final = arrays[current_data_string_final]
    x_pf_final = []
    y_pf_final = []
    x_pf_final = xy_final[:, 0]
    y_pf_final = xy_final[:, 1]

    # Overlay the ego pose ground truth and final particle filter performace over the ego pose fancy map
    plt.plot(x_pf_final, y_pf_final, linestyle = '-', linewidth = 4, c='w', zorder = 13)

    # Save final plot
    kurs = dir_to_save + scene_name_str + "pfn_final.png"
    plt.savefig(kurs, format = 'png', bbox_inches = "tight")

    print('Evaluation complete!')
    print('To view the data as a .gif video, please run the following code in normal Terminal:')
    print('cd ../output/Images/PF')
    print('Before running the next line, recall which scene you had evaluated, and save the .gif with that name.')
    print('convert -delay 50 -loop 0 <scene-entrystring>*.png <scene-entrystring_here>.gif')
