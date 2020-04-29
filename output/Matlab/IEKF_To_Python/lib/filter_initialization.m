function filter = filter_initialization(initialStateMean,initialStateCov, filter_name)
switch filter_name
        
    case "InEKF"
        init.mu = eye(5);
        init.mu(1,5) = initialStateMean(1);
        init.mu(2,5) = initialStateMean(2);
        init.mu(3,5) = initialStateMean(3);
        init.mu(1,4) = initialStateMean(7);
        init.mu(2,4) = initialStateMean(8);
        phi = initialStateMean(4);
        theta = initialStateMean(5);
        psi = initialStateMean(6);
        init.mu(1,1) = cos(psi) * cos(theta);
        init.mu(1,2) = cos(psi)*sin(theta)*sin(phi)-sin(psi)*cos(phi);
        init.mu(1,3) = cos(psi)*sin(theta)*cos(phi)+sin(psi)*sin(phi);
        init.mu(2,1) = sin(psi) * cos(theta);
        init.mu(2,2) = sin(psi)*sin(theta)*sin(phi) + cos(psi)*cos(phi);
        init.mu(2,3) = sin(psi)*sin(theta)*cos(phi) - cos(psi)*sin(phi);
        init.mu(3,1) = -sin(theta);
        init.mu(3,2) = cos(theta)*sin(phi);
        init.mu(3,3) = cos(theta)*cos(phi);
        
        init.Sigma = initialStateCov;
        filter = InEKF(init);
end
end