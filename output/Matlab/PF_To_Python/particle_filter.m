classdef particle_filter < handle
    % Particle filter class for EECS 568, Winter 2020, Ford Team 1
    % The implementation follows the Sample Importance Resampling (SIR)
    % filter a.k.a bootstrap filter.
    %
    % Modified version of Maani Ghaffari Jadidi's original version
    
    properties
        f;              % process model
        h;              % measurement model
        x;              % state vector
        Sigma;          % state covariance
        Q;              % motion noise covariance
        LQ;             % Cholesky factor of Q
        R;              % measurement noise covariance
        p;              % particles
        n;              % number of particles
        Neff;           % effective number of particles
    end
    
    methods
        function obj = particle_filter(system, init)
            % particle_filter construct an instance of this class
            %
            %   Inputs:
            %       system          - system and noise models
            %       init            - initialization parameters
            obj.f = system.f;
            obj.Q = system.Q;
            obj.LQ = chol(obj.Q, 'lower');
            obj.h = system.h;
            obj.R = system.R;
            obj.n = init.n;
            
            % initialize particles into a 10-by-10 even grid
            obj.p = [];
            wu = 1/obj.n; % uniform weights
            x_grid = linspace(init.minX, init.maxX, 10);
            y_grid = linspace(init.minY, init.maxY, 10);
            [XGridval, YGridval] = meshgrid(x_grid, y_grid);
            XGridval = XGridval(:);
            YGridval = YGridval(:);
            for i = 1:obj.n
                obj.p.x(1,i) = XGridval(i);
                obj.p.x(2,i) = YGridval(i);
                obj.p.w(i,1) = wu;
            end
        end
        
        function sample_motion(obj)
            % A simple random walk motion model
            for i = 1:obj.n
                % sample noise
                w = obj.LQ * randn(2,1);
                % propagate the particle!
                obj.p.x(:,i) = obj.f(obj.p.x(:,i), w);
            end
        end
        
        function importance_measurement(obj, z, zbearing, l)
            % compute important weight for each particle based on the 
            % obtained range and bearing measurements
            %
            %   Inputs:
            %       z          - measurement of range
            %       zbearing   - measurement of bearing
            %       l          - landmark global position
            w = zeros(obj.n,1); % importance weights
            for i = 1:obj.n
                 % compute innovation statistics
                 measur = [z; zbearing];
                 v = measur - obj.h(obj.p.x(:,i), l(:));
                 w(i) = mvnpdf(v, 0, obj.R);
            end
            % update and normalize weights
            obj.p.w = obj.p.w .* w; % since we used motion model to sample
            obj.p.w = obj.p.w ./ sum(obj.p.w);
            % compute effective number of particles
            obj.Neff = 1 / sum(obj.p.w.^2);
        end
        
        function resampling(obj)
            % low variance resampling
            W = cumsum(obj.p.w);          
            r = rand / obj.n ;
            j = 1;
            for i = 1:obj.n
                u = r + (i-1) / obj.n;
                while u > W(j)
                    j = j + 1;
                end
                obj.p.x(:,i) = obj.p.x(:,j);
                obj.p.w(i) = 1/obj.n;
            end
        end
    end
end