# Get pictures of ego_poses for each scene we are interested in

# Initialize all of the packages we need
exec(open("../python-functions/init_everything.py").read())

# Bring in grab_data_fcn.py (grab_sensor_data function)
exec(open("../python-functions/grab_annotations_fcn.py").read())

# Define dataset
nusc = NuScenes(version='v1.0-trainval', dataroot='../data/sets/nuscenes', verbose=False)

# Define map: Start at boston-seaport
nusc_map_bost = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='boston-seaport')

nusc_map_singq = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='singapore-queenstown')

nusc_map_singh = NuScenesMap(dataroot='../data/sets/nuscenes', map_name='singapore-hollandvillage')

# Generate ego pose map for scene-0069
ego_poses_scene_0069 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[66]['token']], verbose=False, out_path=None, render_egoposes=False, render_egoposes_range=False)

# Get ego poses from grab_annotations_data function
xyz_pose_all = []
for i in range(0, nusc.scene[66]['nbr_samples']):
    (range_dist, bearing, xyz_diff, pose_recording_out) = grab_annotations_data(nusc, nusc_scene[66], i)
    xyz_pose_all.append(pose_recording_out)
#### WORK ON THE ABOVE SECTION

x_pose_plot = []
y_pose_plot = []
for i in range(0, nusc.scene[66]['nbr_samples']):
    x_pose_plot.append(xyz_pose_all[i][0][0])
    y_pose_plot.append(xyz_pose_all[i][0][1])
    
# Plot the pose line
plt.plot(x_pose_plot, y_pose_plot, linestyle = '-', linewidth = 3, c='k')

# Plot ego pose mape for scene-0069
plt.savefig('scene-0069.png', bbox_inches = "tight")

# Generate ego pose map for scene-0247
ego_poses_scene_0247 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[196]['token']], verbose=False)

plt.savefig('scene-0247.png', bbox_inches = "tight")

# Generate ego pose map for scene-0249
ego_poses_scene_0249 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[198]['token']], verbose=False)

plt.savefig('scene-0249.png', bbox_inches = "tight")

# Generate ego pose map for scene-0395
ego_poses_scene_0395 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[311]['token']], verbose=False)

plt.savefig('scene-0395.png', bbox_inches = "tight")

# Generate ego pose map for scene-0396
ego_poses_scene_0396 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[312]['token']], verbose=False)

plt.savefig('scene-0396.png', bbox_inches = "tight")

# Generate ego pose map for scene-0480
ego_poses_scene_0480 = nusc_map_bost.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[390]['token']], verbose=False)

plt.savefig('scene-0480.png', bbox_inches = "tight")

## Change map to singapore-queenstown


# Generate ego pose map for scene-1017
ego_poses_scene_1017 = nusc_map_singq.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[775]['token']], verbose=False)

plt.savefig('scene-1017.png', bbox_inches = "tight")

# Generate ego pose map for scene-1018
ego_poses_scene_1018 = nusc_map_singq.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[776]['token']], verbose=False)

plt.savefig('scene-1018.png', bbox_inches = "tight")

## Change the map to singapore-hollandvillage

# Generate ego pose map for scene-1048
ego_poses_scene_1048 = nusc_map_singh.render_egoposes_on_fancy_map(nusc, scene_tokens=[nusc.scene[788]['token']], verbose=False)

plt.savefig('scene-1048.png', bbox_inches = "tight")

