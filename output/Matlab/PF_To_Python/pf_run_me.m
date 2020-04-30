% Particle Filter script for EECS 568, Winter 2020, Ford Team 1
% 
% This script will generate MPEG-4 video files of the particles for each
% desired scene as listed starting in Line 18. JPEG files of the ground
% truth (aka ego_pose at 2 Hz as provided by nuScenes) superimposed with the
% estimated states by the particles are generated. These already generated
% files can be found in \where-dyss\output\Matlab\PF.
%
% Additionally, this script will save the particle states (x and y
% position) and the estimated states into a .mat file to be read in Python
% for plotting on top of the 'fancy' map as an animation and final result.
% Change this setting in Lines 22 and 23 appropriately.


clc; clear; close all
addpath('../../../own_data/PF_To_Matlab/Variable_Landmarks')

desired_scenes = ["scene-0069", "scene-0247", "scene-0249", "scene-0395", ...
    "scene-0480", "scene-1017", "scene-1018", "scene-1048", ...
    "scene-0396"];

want_videos_jpg = 1;
want_mat_files = 1;

for scene_array_indx = 1:length(desired_scenes)
    % Load the respective mat file
    scene_data_file = strcat(desired_scenes(scene_array_indx), '_data.mat');
    load(scene_data_file)
    
    % Saving the data to a mat file to be used in Python for fancy maps
    if want_mat_files
        filename = strcat(desired_scenes(scene_array_indx), '_2py.mat');
    end
    
    % There is no knowledge of the target motion, hence, we
    % assume a random walk motion model.
    
    % LiDAR measurements (range and bearing) with added Gaussian noise
    R = diag([(0.02/10)^2, (0.05/10)^2]);
    % Cholesky factor of covariance for sampling
    L = chol(R, 'lower');
    z = [];
    zbearing = [];
    for i = 1:numSamplesPerScene
        % sample from a zero mean Gaussian with covariance R
        noise = L * randn(2,1);
        z(:,i) = range_dist_out(:,i) + noise(1);
        zbearing(:,i) = bearing_out(:,i) + noise(2);
    end
    
    % Build the system
    sys = [];
    sys.f = @(x,w) [x(1); x(2)] + w;
    sys.h = @(x,l)  [sqrt((x(1)-l(1))^2 + (x(2)-l(2))^2); atan2(l(2)-x(2),l(1)-x(1))];
    sys.Q = 9 * eye(2);
    sys.R = diag([(1.2)^2 ,(0.7)^2]);
    
    % Initialization!
    init = [];
    init.n = 100;
    ego_pose_x = pose_recording_out(1,1:numSamplesPerScene);
    ego_pose_y = pose_recording_out(2,1:numSamplesPerScene);
    init.x(1,1) = min(ego_pose_x) - 5;
    init.x(2,1) = min(ego_pose_y) - 5;
    init.minX = init.x(1,1);
    init.minY = init.x(2,1);
    init.maxX = max(ego_pose_x) + 5;
    init.maxY = max(ego_pose_y) + 5;
    init.Sigma = 20 * eye(2);
    
    filter = particle_filter(sys, init);
    x = nan(2,1);     % state
    
    % Incremental visualization
    green = [0.2980 .6 0];
    
    fsize = 20; % font size
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultLegendInterpreter','latex');
    
    h = figure; hold on
    % Plotting ego_pose to get an idea of the ground truth
    plot(ego_pose_x, ego_pose_y, '-', 'linewidth', 2)
    grid on, axis auto equal, axis([min(ego_pose_x)-40 max(ego_pose_x)+40 min(ego_pose_y)-40 max(ego_pose_y)+40])
    xlabel('$x_1$', 'fontsize', fsize, 'Interpreter','latex')
    ylabel('$x_2$', 'fontsize', fsize, 'Interpreter','latex')
    set(gca, 'fontsize', fsize)
    % Plot initial particles that are evenly spread across a selected
    % region
    hp = plot(filter.p.x(1,:), filter.p.x(2,:),'.','Color', [green, .25]);
    % Plot initial landmarks of all categories/attributes as black squares
    hl = scatter(ann_des_pose_out(1:numAnnPerSampPerScene(1),1), ann_des_pose_out(1:numAnnPerSampPerScene(1),2));
    set(hl,'Marker','s')
    set(hl,'MarkerEdgeColor','k')
    set(hl,'MarkerFaceColor','k')
    
    if want_mat_files
        p_x_var_name = strcat('p_x_', num2str(1));
        assignin('base',p_x_var_name,filter.p.x)
        save(filename,p_x_var_name,'-v7.3')
    end
    
    if want_videos_jpg
        % Create the video writer with 2 fps
        writerObj = VideoWriter(desired_scenes(scene_array_indx), 'MPEG-4');
        writerObj.FrameRate = 2;
        open(writerObj);
        F(1) = getframe(gcf);
        writeVideo(writerObj, F(1));
    end
    
    % Main loop; iterate over the measurements
    for i = 2:size(z,2)
        filter.sample_motion();
        for j = 1:numAnnPerSampPerScene(i)
            filter.importance_measurement(z(j,i), zbearing(j,i), ann_des_pose_out(j,3*(i-1)+1:3*i-1));
        end
        
        % Resample particles if number of efficient particles goes below
        % specified threshold and if there are annotations saved
        if numAnnPerSampPerScene(i) ~= 0
            if filter.Neff < filter.n/3
                filter.resampling();
            end
        end
        wtot = sum(filter.p.w);
        if wtot > 0
            x(1,i) = sum(filter.p.x(1,:)' .* filter.p.w) / wtot;
            x(2,i) = sum(filter.p.x(2,:)' .* filter.p.w) / wtot;
        else
            warning('Total weight is zero or nan!')
            disp(wtot)
            x(:,i) = nan(2,1);
        end
        
        if want_mat_files
            % Save particles to .mat file
            p_x = filter.p.x;
            p_x_var_name = strcat('p_x_', num2str(i));
            assignin('base',p_x_var_name,filter.p.x)
            save(filename,p_x_var_name,'-append','-nocompression')
        end
        
        % Show particles
        set(hp,'XData',filter.p.x(1,:))
        set(hp,'YData',filter.p.x(2,:))
        
        % Show landmarks
        set(hl,'XData',ann_des_pose_out(1:j,3*(i-1)+1))
        set(hl,'YData',ann_des_pose_out(1:j,3*i-1))
        
        title(desired_scenes(scene_array_indx))
        
        if want_videos_jpg
            % Save frame and write to video object
            F(i) = getframe(gcf);
            writeVideo(writerObj, F(i));
        end
        
        drawnow
        % Pause value should be 0.5s but for development purposes, it has
        % been set to 0.1s.
        pause(0.1)
        
        
    end
    if want_videos_jpg
        close(writerObj);
    end
    close(h)
    
    % plotting outcome of Particle Filter on top of ground truth
    figure; hold on, grid on
    plot(ego_pose_x, ego_pose_y, '-', 'linewidth', 1)
    plot(x(1,:), x(2,:), '-k', 'linewidth', 1)
    grid on, axis equal tight
    axis([min(ego_pose_x)-40 max(ego_pose_x)+40 min(ego_pose_y)-40 max(ego_pose_y)+40])
    xlabel('$x_1$', 'fontsize', fsize, 'Interpreter','latex')
    ylabel('$x_2$', 'fontsize', fsize, 'Interpreter','latex')
    set(gca, 'fontsize', fsize)
    legend('GPS Position','PF Est. Position')
    title(desired_scenes(scene_array_indx))
    if want_videos_jpg
        png_filename = strcat(desired_scenes(scene_array_indx), '_pf_final.png');
        saveas(gcf,png_filename)
    end
    
    if want_mat_files
        % Append estimated state to .mat file
        x = x(:,2:end);
        save(filename,'x','-append','-nocompression')
        % Append annotations information to .mat file
        save(filename,'numAnnPerSampPerScene','-append','-nocompression')
        save(filename,'ann_des_pose_out','-append','-nocompression')
        save(filename,'numSamplesPerScene','-append','-nocompression')
    end
    
    clc; clearvars -except scene_array_indx desired_scenes want_videos_jpg want_mat_files; close all
    
end
