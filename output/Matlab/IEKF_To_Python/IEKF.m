classdef IEKF < handle
    % Invariant EKF class for EECS 568, Winter 2020, Ford Team 1
    % The implementation follows the Lecture Slides provided by Prof.
    % Jadidi
    
    properties
        mu;                 % Pose Mean
        Sigma;              % Pose Sigma
        mu_pred;             % Mean after prediction step
        Sigma_pred;          % Sigma after prediction step
        mu_cart;
        sigma_cart;
    end
    
    methods
        function obj = IEKF(init)
            % Invariant EKF construct an instance of this class
            %
            %   Inputs:
            %       init - initialization parameters
            obj.mu = init.mu;
            obj.Sigma = init.Sigma;
        end
        
        function prediction(obj, u_noise)
            time_step = 0.01;
            % u is noisy inputs: [angular_vel, linear_accel]
            % New rotation matrix in global space
            Rnew = obj.mu(1:3,1:3) * obj.gamma_0Calc(u_noise(:,1) * time_step);
            % New velocity vector in global space
            vnew = obj.mu(1:3,4) + obj.mu(1:3,1:3) * obj.gamma_1Calc(u_noise(:,1) * time_step) * u_noise(:,2) * time_step ...
                + [0;0;-9.81] * time_step;
            % New transition matrix in global space
            pnew = obj.mu(1:3,5) + obj.mu(1:3,4) * time_step + obj.mu(1:3,1:3) * obj.gamma_2Calc(u_noise(:,1) * time_step) ...
                * u_noise(:,2) * time_step^2 + 0.5 * [0;0;-9.81] * time_step^2;
            
            % Create mu predicted
            obj.mu_pred = eye(5);
            obj.mu_pred(1:3,1:3) = Rnew;
            obj.mu_pred(1:3,4) = vnew;
            obj.mu_pred(1:3,5) = pnew;
            
            % Create Sigma predicted
            A_mat = zeros(9,9);
            A_mat(1:3,1:3) = -obj.skewSymmMat(u_noise(:,1));
            A_mat(4:6,4:6) = A_mat(1:3,1:3);
            A_mat(7:9,7:9) = A_mat(1:3,1:3);
            A_mat(4:6,1:3) = -obj.skewSymmMat(u_noise(:,2));
            A_mat(7:9,4:6) = eye(3);
            state_trans_matrix = expm(A_mat * time_step);
            obj.Sigma_pred = state_trans_matrix * obj.Sigma * state_trans_matrix' + blkdiag(diag([.00001^2, .00001^2, .00001^2, ...
                1000000^2, 1000000^2, 1000000^2, .1^2, .1^2, 10000^2]));

        end
        
        function correction(obj, observation)
            % Left-invariant observations
            gps_x = observation(1);
            gps_y = observation(2);
            gps_z = observation(3);
            
            
            b = [0;0;0;0;1];
            Y = [gps_x;gps_y;gps_z;0;1];
            
            H = [zeros(3,3), zeros(3,3), eye(3)];
            
            % Rotation matrix
            R = obj.mu_pred(1:3,1:3);
            R = blkdiag(R,zeros(2,2));
            
            N = R' * diag([.000001^2;.000001^2;.000001^2;0;0]) * R;
            N = N(1:3,1:3);
            
            S = H * obj.Sigma_pred * H' + N;
            
            % Kalman gain
            L = obj.Sigma_pred * H' * (S \ eye(size(S)));
            
            % Innovation
            nu = (obj.mu_pred \ eye(size(obj.mu_pred))) * (Y - [.00005;.00005;.00005;0;0]) - b;
            
            % Delta
            delta = L * [eye(3),zeros(3,1),zeros(3,1)] * nu;
            
            % Put delta into a 5x5 matrix to be multiplied by mu predicted
            % to calculate mu
            matrixForExpm = zeros(5,5);
            matrixForExpm(1:3,1:3) = obj.skewSymmMat(delta(1:3));
            matrixForExpm(1:3,4) = delta(4:6);
            matrixForExpm(1:3,5) = delta(7:9);
            
            obj.mu = obj.mu_pred * expm(matrixForExpm);
            obj.Sigma = (eye(9) - L * H) * obj.Sigma_pred * (eye(9) - L * H)' + L * N * L';

        end
        
        function out = skewSymmMat(obj, state)
            x = state(1);
            y = state(2);
            z = state(3);
            % construct a skew symmetric matrix of the state
            out = [...
                   0    -z       y; 
                   z     0      -x; 
                  -y     x       0];
        end
        
        function out = gamma_0Calc(obj,state)
            out = eye(3) + (sin(norm(state,2))/norm(state,2)) * obj.skewSymmMat(state) ...
                + (1-cos(norm(state,2)))/(norm(state,2)^2) * obj.skewSymmMat(state)^2;
        end
        
        function out = gamma_1Calc(obj,state)
            out = eye(3) + (1-cos(norm(state,2)))/(norm(state,2)^2) * ...
                obj.skewSymmMat(state) + (norm(state,2)-sin(norm(state,2)))...
                /(norm(state,2)^3) * obj.skewSymmMat(state)^2;
        end
        
        function out = gamma_2Calc(obj,state)
            out = 0.5 * eye(3) + (norm(state,2)-sin(norm(state,2)))/(norm(state,2)^3) * ...
                obj.skewSymmMat(state) + (norm(state,2)^2 + 2*cos(norm(state,2))-2)/(2*...
                norm(state,2)^4) * obj.skewSymmMat(state)^2;
        end
    end
end
