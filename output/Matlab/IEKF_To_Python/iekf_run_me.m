% Invariant Extended Kalman Filter script for EECS 568, Winter 2020, Ford Team 1
% 
% This script will run an Invariant EKF class object on incoming data from
% the inertial sensor (IMU) at 100 Hz and the ego pose (ground truth)
% created by a nuScenes LiDAR map-based localization algorithm at 50 Hz.
% Hence we are predicting twice and correcting once. The output estimated
% state (x,y) is superimposed on the ground truth data and is saved as a
% .png file. If you want to see the estimated pose along with covariance on
% cartesian live, please change the value in Line 18 to 1. 
%
% Once the .mat files are created, please move the .mat files into
% /where-dyss/output/Matlab/IEKF_To_Python/data/.
%
% Additionally, our prediction uses right-invariant data and in correction
% we have left-invariant observations.
% 
% If you would like to look at a different scene from the nuScenes dataset,
% please change the string in Line 35. Make sure you have total 4 digits in
% the string. For example, '0065', '0234', '1018', etc.

clear all; clc; close all;
addpath([cd, filesep, 'lib'])

%--------------------------------------------------------------
% Graphics
%--------------------------------------------------------------

watch_iekf = 0;
want_mat_files = 0;

%--------------------------------------------------------------
% Initializations
%--------------------------------------------------------------

% Bring in data for desired scene
scene_number = '0249';
data_struct = getNusceneData(scene_number);

if want_mat_files
    filename = strcat(scene_number, '_iekf_2py.mat');
end

initial_x = data_struct.Pose_Position(1, 1);
initial_y = data_struct.Pose_Position(1, 2);
initial_z = data_struct.Pose_Position(1, 3);
initial_phi = data_struct.Pose_RPY(1, 1); % roll
initial_theta = data_struct.Pose_RPY(1, 2); % pitch
initial_psi = data_struct.Pose_RPY(1, 3); % yaw
v_long = [data_struct.Pose_Velocity(1, 1) * cos(initial_psi), data_struct.Pose_Velocity(1, 1) * sin(initial_psi)];
initialStateMean = [initial_x initial_y initial_z initial_phi initial_theta initial_psi v_long]';
initialStateCov = 1*eye(9);

numSteps = size(data_struct.IMU_rot_rate, 1);

filter_name = "InEKF";
filter = filter_initialization(initialStateMean, initialStateCov, filter_name);

x_plot = initial_x;
y_plot = initial_y;
yaw_plot = initial_psi;
v_long_plot = sqrt(v_long(1)^2 + v_long(2)^2);

a = 0.0003;
gyro_noise = diag([a^2, a^2, a^2]);
gyro_noise_chol = chol(gyro_noise, 'lower');
accel_noise = diag([a^2, a^2, a^2]);
accel_noise_chol = chol(accel_noise, 'lower');

if watch_iekf
    figure()
end

if want_mat_files
    ELLIPSE = zeros(length(-pi:.01:pi),2);
end

for t = 2:numSteps
    %=================================================
    % data available to your filter at this time step
    %=================================================
    roll_rate = 0;data_struct.IMU_rot_rate(t, 1);
    pitch_rate = 0;data_struct.IMU_rot_rate(t, 2);
    yaw_rate = data_struct.IMU_rot_rate(t, 3);
    angular_vel_noisy = [roll_rate;pitch_rate;yaw_rate] + gyro_noise_chol*randn(3,1);
    
    accel_x = data_struct.IMU_Linear_Accel(t, 1);
    accel_y = data_struct.IMU_Linear_Accel(t, 2);
    accel_z = data_struct.IMU_Linear_Accel(t, 3);
    linear_accel_noisy = [accel_x;accel_y;accel_z] + accel_noise_chol*randn(3,1);
    
    motionCommandNoisy = [angular_vel_noisy, linear_accel_noisy];
    
    % For Mahalanobis Calculations
    if t == 2
        gps_x = initial_x;
        gps_y = initial_y;
        gps_z = initial_z;
        gps_phi = initial_phi; % roll
        gps_theta = initial_theta; % pitch
        gps_psi = initial_psi; % yaw
        gps_v_long = [v_long, 0]';
    end
     
    if mod(t, 2) == 1 % odd for-loop step
        gps_x = data_struct.Pose_Position(round(t/2), 1);
        gps_y = data_struct.Pose_Position(round(t/2), 2);
        gps_z = data_struct.Pose_Position(round(t/2), 3);
        gps_phi = data_struct.Pose_RPY(round(t/2), 1); % roll
        gps_theta = data_struct.Pose_RPY(round(t/2), 2); % pitch
        gps_psi = data_struct.Pose_RPY(round(t/2), 3); % yaw
        observation_gps = [gps_x gps_y gps_z gps_phi gps_theta gps_psi]';
    end
    
    %=================================================
    %TODO: update your filter here based upon the
    %      motionCommand and observation
    %=================================================
    
    switch filter_name
        case "InEKF"
            filter.prediction(motionCommandNoisy)
            if mod(t, 2) ~= 1 % even for-loop step
                filter.mu = filter.mu_pred;
                filter.Sigma = filter.Sigma_pred;
            end
            if mod(t, 2) == 1 % odd for-loop step
                filter.correction(observation_gps)
            end
            
            lieTocartesian(filter);
    end

    x_plot(t) = filter.mu_cart(1,1);
    y_plot(t) = filter.mu_cart(2,1);
    yaw_plot(t) = filter.mu_cart(4,1);
    v_long_plot(t) = sqrt(filter.mu(1,4)^2 + filter.mu(2,4)^2);
    
    if watch_iekf
        scatter(x_plot(t),y_plot(t),20,'k', 'o')
        hold on
        if mod(t, 2) ~= 1
            ELLIPSE = ellipse_plotter(filter, 1);
        end
        xlim([415, 445])
        ylim([1630, 1700])
        
        drawnow
        hold off
        pause(0.01)
    end
    
    if mod(t, 2) ~= 1
        ELLIPSE(:,2*t-1:2*t) = ellipse_plotter(filter, 0);
    else
        ELLIPSE(:,2*t-1:2*t) = ELLIPSE(:,2*t-3:2*t-2);
    end
    
    % 3 covariance
    for i = 1:9
        three_cov(i,1) = 3*sqrt(filter.sigma_cart(i,i));
    end
%     three_cov = [3*sqrt(filter.sigma_cart(7,7));3*sqrt(filter.sigma_cart(8,8));3*sqrt(filter.sigma_cart(3,3))];
    diff = [0;0;(gps_psi - yaw_plot(t));0;0;0;(gps_x - x_plot(t));(gps_y - y_plot(t));0];
%     diff = [(gps_x - x_plot(t));(gps_y - y_plot(t));(gps_psi - yaw_plot(t))];
    result_val = (diff)' * (filter.sigma_cart \ diff);
    
    output_maha(1:3,t-1) = diff([3,7,8]);
    output_maha(4,t-1) = result_val;
    output_maha(5:7,t-1) = three_cov([3,7,8]);
end

if want_mat_files
    save(filename,'x_plot','-v7.3')
    save(filename,'y_plot','-append','-nocompression')
    save(filename,'yaw_plot','-append','-nocompression')
    save(filename,'v_long_plot','-append','-nocompression')
    save(filename,'ELLIPSE','-append','-nocompression')
end

figure()
plot(data_struct.Pose_Position(:, 1), data_struct.Pose_Position(:, 2), 'k', 'LineWidth', 4)
hold on
plot(x_plot, y_plot,  '-', 'color','r','LineWidth', 1.5)
legend('Ground Truth','Estimated','location','southeast')
title('Pose in Global Space')
png_filename = strcat(scene_number, '_iekf_final.png');
saveas(gcf,png_filename)

% Mahalanobis Distance
figure; set(gca, 'fontsize', 14);
hold on; grid on
plot(output_maha(4,:), 'linewidth', 2)
plot(16.92*ones(1,length(x_plot)),'r', 'linewidth', 2)
legend('Chi-square Staistics','p = 0.05 w/ 9 DOF', 'fontsize', 14, 'location', 'best')
png_filename = strcat(scene_number, '_iekf_maha.png');
saveas(gcf,png_filename)

figure; set(gca, 'fontsize', 14)
subplot(3,1,1)
plot(output_maha(2,:), 'linewidth', 2)
hold on; grid on
ylabel('X', 'fontsize', 14)
plot(output_maha(6,:),'r', 'linewidth', 2)
plot(-1*output_maha(6,:),'r', 'linewidth', 2)
legend('Deviation from Ground Truth','3rd Sigma Contour', 'fontsize', 14, 'location', 'best')
subplot(3,1,2)
plot(output_maha(3,:), 'linewidth', 2)
hold on; grid on
plot(output_maha(7,:),'r', 'linewidth', 2)
plot(-1*output_maha(7,:),'r', 'linewidth', 2)
% plot(3*ones(1,length(results)),'r')
ylabel('Y', 'fontsize', 14)
subplot(3,1,3)
plot(output_maha(1,:), 'linewidth', 2)
hold on; grid on
plot(output_maha(5,:),'r', 'linewidth', 2)
plot(-1*output_maha(5,:),'r', 'linewidth', 2)
% plot(3*ones(1,length(results)),'r')
ylabel('yaw', 'fontsize', 14)
xlabel('Iterations', 'fontsize', 14)
png_filename = strcat(scene_number, '_iekf_cov.png');
saveas(gcf,png_filename)
