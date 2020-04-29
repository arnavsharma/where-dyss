close all

% Car Plotting
L = 4.084; % length of Renault Zoe in meters
W = 1.730; % width of Renault Zoe in meters

Xc = 0; % center x point of car received from InEKF
Yc = 0; % center y point of car received from InEKF

% points are [RR, FR, FL, RL, RR] Extra RR to enclose and make a rectangle
X = [-L/2, L/2, L/2, -L/2, -L/2];
Y = [-W/2, -W/2, W/2, W/2, -W/2];

theta = 0; % radians - yaw received from InEKF; positive is CCW, which is what we want!

cth = cos(theta);
sth = sin(theta);

Xrot = X*cth - Y*sth;
Yrot = X*sth + Y*cth;

% Head Lights
left_front_light = [Xrot(3), Yrot(3)];
right_front_light = [Xrot(2), Yrot(2)];
x_front_light = [left_front_light(1), right_front_light(1)];
y_front_light = [left_front_light(2), right_front_light(2)];

% Brake Lights
% Just as an example
accel_x = [8, 9, 2, -2, -2, -2, 9, 5, -5, -5, 3, -3, 4, -2, -1]; % this would be data coming in
left_rear_light = [Xrot(4), Yrot(4)];
right_rear_light = [Xrot(1), Yrot(1)];
x_rear_light = [left_rear_light(1), right_rear_light(1)];
y_rear_light = [left_rear_light(2), right_rear_light(2)];

figure
hold on
plot(Xrot + Xc, Yrot + Yc, 'k', 'LineWidth', 1.5) % See if a thicker/thinner linewidth is necessary

for i = 1:length(accel_x)
    % Light positions change as car moves
    % Set up code to keep receating a new set of Xrot and Yrot
    % And then calculate light positions based on new Xrot and Yrot
    
    % Front Lights
    front_right_plot = scatter(x_front_light, y_front_light, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'y');
    
    
    % Brake Lights
    rear_light_plot = scatter(x_rear_light, y_rear_light, 'MarkerEdgeColor', 'k');
    
    axis equal
    xlim([-30, 30])
    ylim([-40, 40])
    
    if accel_x(i) < 0
        set(rear_light_plot, 'MarkerFaceColor', 'r')
    else
        set(rear_light_plot, 'MarkerFaceColor', 'w')
    end
    % For visualization, pause step
    pause(0.5)
end