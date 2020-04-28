function output = getNusceneData(scene_number)

% scene_number='1000';

%.json scene files must be in the filepath
% filepath is /where-dyss/data/sets/nuscenes/can_bus/
currDir = pwd;
output_Matlab_str_indx = strfind(currDir, '/output/Matlab/');
dirToAdd = strcat(currDir(1:output_Matlab_str_indx), 'data/sets/nuscenes/can_bus');
addpath(dirToAdd)
% Input: scene_number

% Read data from .json using scene number
[Hz100_veh_info, Hz100_imu, Hz100_SAF, Pose]= Dataread(scene_number);

% Lined up values
%using u_time_lineup to calculate index the u_times first align
[u_time_VI, u_time_imu, u_time_SAF, u_time_Pose]=u_time_lineup(Hz100_veh_info, Hz100_imu, Hz100_SAF, Pose);
%using adjust_dataset to align the start and end points - F_ for final
[F_veh_info, F_imu, F_SAF, F_Pose]=Adjust_dataset(u_time_VI, u_time_imu, u_time_SAF, u_time_Pose,Hz100_veh_info, Hz100_imu, Hz100_SAF, Pose);

%cleaning up workspace
clear Hz100_veh_info Hz100_imu Hz100_SAF veh_info imu SAF Pose
clear u_time_VI u_time_imu u_time_SAF u_time_Pose

% Vehicle Information Data
%(1)FL_WSS, (2)FR_WSS, (3)RL_WSS, (4)RR_WSS, (5)Left_Solar, (6)Long_Accel,
%(7)Mean_Eff_Torque, (8)Odom, (9)Odom_speed, (10)pedal_cc, (11) Regen
%(12)requestedTorqueAfterProc, (13)right_solar, (14)steer_corrected
%(15)steer_offset_can, (16)steer_raw, (17)Transverse Accel, (18)u_time
VI_FL_WSS=F_veh_info(:,1);  %FL WSS
VI_FR_WSS=F_veh_info(:,2);  %FR WSS
VI_RL_WSS=F_veh_info(:,3);  %RL WSS
VI_RR_WSS=F_veh_info(:,4);  %RR WSS
VI_Long_accel=F_veh_info(:,6);  %Longitudinal Accel
VI_Steer_Ang=F_veh_info(:,14);  %Steering Angle Corrected
VI_Transverse_Accel=F_veh_info(:,16); %Transverse Accel

% IMU data and IMU_RPY
%CHECK THE Q and ROT RATE
%(1-3)Linear_Accel[x,y,z] (4-7)q[qw,qx,qy,qz](check)
%(8-10)rot_rate[yaw,pitch,roll] (11)u_time
IMU_Linear_Accel=F_imu(:,1:3);
IMU_q=F_imu(:,4:7);
IMU_rot_rate=F_imu(:,8:10);
IMU_RPY=quaternion_to_euler(IMU_q);

% Steering Feedback Angle data
%(1)u_time (2)SFA
SAF_SAF=F_SAF(:,2);

% Pose data
%(1-3)Accel, (4-7)Orientation, (8-10)Position, (11-13)Rotation_Rate
%(14)u_time (15)Velocity
Pose_Accel=F_Pose(:,1:3);
Pose_Orientation=F_Pose(:,4:7);
Pose_RPY=quaternion_to_euler(Pose_Orientation);
Pose_Position=F_Pose(:,8:10);
Pose_Rot_Rate=F_Pose(:,11:13);
Pose_Velocity=F_Pose(:,15:17);

% Save data to output structure
output.F_imu = F_imu;
output.F_Pose = F_Pose;
output.F_SAF = F_SAF;
output.F_veh_info = F_veh_info;
output.IMU_Linear_Accel = IMU_Linear_Accel;
output.IMU_q = IMU_q;
output.IMU_rot_rate = IMU_rot_rate;
output.IMU_RPY = IMU_RPY;
output.output_Matlab_str_indx = output_Matlab_str_indx;
output.Pose_Accel = Pose_Accel;
output.Pose_Orientation = Pose_Orientation;
output.Pose_RPY = Pose_RPY;
output.Pose_Position = Pose_Position;
output.Pose_Rot_Rate = Pose_Rot_Rate;
output.Pose_Velocity = Pose_Velocity;
output.SAF_SAF = SAF_SAF;
output.scene_number = scene_number;
output.VI_FL_WSS = VI_FL_WSS;
output.VI_FR_WSS = VI_FR_WSS;
output.VI_Long_accel = VI_Long_accel;
output.VI_RL_WSS = VI_RL_WSS;
output.VI_RR_WSS = VI_RR_WSS;
output.VI_Steer_Ang = VI_Steer_Ang;
output.VI_Transverse_Accel = VI_Transverse_Accel;

% START OF NESTED FUNCTIONS
% Dataread function to read the data from json files
function [veh_info, imu, SAF, Pose]=Dataread(scene_number)

veh_info_name = strcat('scene-',scene_number,'_zoe_veh_info.json');
veh_info_read = jsondecode(fileread(veh_info_name));
veh_info_struct= (struct2cell(veh_info_read))';
veh_info=cell2mat(veh_info_struct); %Vehicle Info in .mat


%IMU Info in .mat
imu=IMUread(scene_number);
%Function to convert IMU Info in .mat
    function imu=IMUread(scene_number)
        %Converting IMU to Mat
        imu_name = strcat('scene-',scene_number,'_ms_imu.json');
        imu_read = jsondecode(fileread(imu_name));
        D=(struct2cell(imu_read))';
        
        %Linear_Accel
        Linear_Accel=zeros(length(D),length({D,1}));
        imu_size=length(D{1,1});
        for i=1:length(D)
            Val=D{i,1};
            for j=1:imu_size
                Linear_Accel(i,j)= Val(j);
            end
        end
        
        %Q
        Q=zeros(length(D),length({D,2}));
        imu_size=length(D{1,2});
        for i=1:length(D)
            Val=D{i,2};
            for j=1:imu_size
                Q(i,j)= Val(j);
            end
        end
        
        %Rotation Rate
        Rot_rate=zeros(length(D),length({D,3}));
        imu_size=length(D{1,3});
        for i=1:length(D)
            Val=D{i,3};
            for j=1:imu_size
                Rot_rate(i,j)= Val(j);
            end
        end
        
        %u_time_imu
        u_time_imu=zeros(length(D),1);
        %         imu_size=length(D{1,4});
        for i=1:length(D)
            Val=D{i,4};
            u_time_imu(i)= Val;
        end
        
        imu=[Linear_Accel,Q,Rot_rate,u_time_imu];
        %  imu=[Linear_Accel,Q,Rot_rate];
    end

%Steering Angle Feedback in .mat
SAF_name = strcat('scene-',scene_number,'_steeranglefeedback.json');
SAF_read = jsondecode(fileread(SAF_name));
SAF_struct= (struct2cell(SAF_read))';
SAF=cell2mat(SAF_struct);

%Pose in .mat
Pose=Poseread(scene_number);
%Function to convert Pose Info in .mat
    function Pose=Poseread(scene_number)
        Pose_name = strcat('scene-',scene_number,'_Pose.json');
        Pose_read = jsondecode(fileread(Pose_name));
        D=(struct2cell(Pose_read))';
        
        %Accel
        Accel=zeros(length(D),length({D,1}));
        Pose_size=length(D{1,1});
        for i=1:length(D)
            Val=D{i,1};
            for j=1:Pose_size
                Accel(i,j)= Val(j);
            end
        end
        
        %Orientation
        Orientation=zeros(length(D),length({D,2}));
        Pose_size=length(D{1,2});
        for i=1:length(D)
            Val=D{i,2};
            for j=1:Pose_size
                Orientation(i,j)= Val(j);
            end
        end
        
        %Position
        Pos=zeros(length(D),length({D,3}));
        Pose_size=length(D{1,3});
        for i=1:length(D)
            Val=D{i,3};
            for j=1:Pose_size
                Pos(i,j)= Val(j);
            end
        end
        
        %Rot_Rate
        Rot_Rate=zeros(length(D),length({D,4}));
        Pose_size=length(D{1,4});
        for i=1:length(D)
            Val=D{i,4};
            for j=1:Pose_size
                Rot_Rate(i,j)= Val(j);
            end
        end
        
        %u_time_imu
        u_time_Pose=zeros(length(D),1);
        for i=1:length(D)
            Val=D{i,5};
            u_time_Pose(i)= Val;
        end
        
        %Velocity
        Velocity=zeros(length(D),length({D,6}));
        Pose_size=length(D{1,6});
        for i=1:length(D)
            Val=D{i,6};
            for j=1:Pose_size
                Velocity(i,j)= Val(j);
            end
        end
        
        Pose=[Accel,Orientation,Pos,Rot_Rate,u_time_Pose,Velocity];

    end
end

% Line up timing function to figure out figure out index start point
function [u_time_VI, u_time_imu, u_time_SAF, u_time_Pose]=u_time_lineup(veh_info, imu, SAF, Pose)

%Pulling u_time from each information tab, assigning C,D,E,F to respective
%variables for easy coding

u_time_C=veh_info(:,18);
u_time_D=imu(:,11);
u_time_E=SAF(:,1);
u_time_F=Pose(:,14);

%max_u_time in the first row between the datasheets
max_u_time_start=max([u_time_C(1), u_time_D(1),u_time_E(1), u_time_F(1)]);

C_index=0;
for C_i=1:length(u_time_C)
    x=(u_time_C(C_i)-max_u_time_start);
    if (x >= -5000) && (x <= 5000)
        C_index=C_i;
    else
    end
end

D_index=0;
for D_i=1:length(u_time_D)
    x=(u_time_D(D_i)-max_u_time_start);
    if  (x >= -5000) && (x <= 5000)
        D_index=D_i;
    else
    end
end

E_index=0;
for E_i=1:length(u_time_E)
    x=(u_time_E(E_i)-max_u_time_start);
    if  (x >= -5000) && (x <= 5000)
        E_index=E_i;
    else
    end
end

F_index=0;
for F_i=1:length(u_time_F)
    x=(u_time_F(F_i)-max_u_time_start);
    if  (x >= -15000) && (x <= 15000)
        F_index=F_i;
    else
    end
end

u_time_VI=C_index;
u_time_imu=D_index;
u_time_SAF=E_index;
u_time_Pose=F_index;
end

% Adjusting start point, trim the extra length, return new dataset
function [F_veh_info, F_imu, F_SAF, F_Pose]=Adjust_dataset(u_time_VI, u_time_imu, u_time_SAF, u_time_Pose,veh_info, imu, SAF, Pose)
%N for New -> re-indexing to new start index
N_veh_info=veh_info(u_time_VI:end,:);
N_imu=imu(u_time_imu:end,:);
N_SAF=SAF(u_time_SAF:end,:);
N_Pose=Pose(u_time_Pose:end,:);

%Find length based on the adjusted start index
O_index_len=min([length(N_veh_info),length(N_imu),length(N_SAF)]); %minimum length between the other 3
Pose_len_i=length(N_Pose); %since Pose is the shortest, reference length
Pose_comp=fix(O_index_len/2); %round down smallest index length of other 3 and divide it by 2. 
%Trim the length
if Pose_comp <= Pose_len_i %Pose Comp if Pose_length
    index_len=Pose_comp; %index length
else
    index_len=Pose_len_i; 
end

O_len_i=index_len*2;
F_veh_info=N_veh_info(1:O_len_i,:);
F_imu=N_imu(1:O_len_i,:);
F_SAF=N_SAF(1:O_len_i,:);
F_Pose=N_Pose(1:index_len,:);

end

% Function to convert quaternion to Euler
function out_RPY=quaternion_to_euler(q)
out_RPY=zeros(length(q),3);
    
    for i=1:length(q)
     
    w=q(i,1);
    x=q(i,2);
    y=q(i,3);
    z=q(i,4);
    
    t0 = +2.0 * (w * x + y * z);
    t1 = +1.0 - 2.0 * (x * x + y * y);
    roll = atan2(t0, t1);
    
    t2 = +2.0 * (w * y - z * x);
    if t2 > +1.0
        t2 = +1.0;
    elseif t2 <-1.0
        t2=-1.0;
    else
    end
    pitch = asin(t2);
    
    t3 = +2.0 * (w * z + x * y);
    t4 = +1.0 - 2.0 * (y * y + z * z);
    yaw = atan2(t3, t4);
    
    out_RPY(i,1) = roll;
    out_RPY(i,2) = pitch;
    out_RPY(i,3) = yaw;
    end
end

end