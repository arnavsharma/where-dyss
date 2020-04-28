function ELLIPSE = ellipse_plotter(filter, to_plot)
G1 = [0, 0, 0, 0, 0;
      0, 0,-1, 0, 0;
      0, 1, 0, 0, 0;
      0, 0, 0, 0, 0;
      0, 0, 0, 0, 0];
  
G2 = [0, 0, 1, 0, 0;
      0, 0, 0, 0, 0;
     -1, 0, 0, 0, 0;
      0, 0, 0, 0, 0;
      0, 0, 0, 0, 0];
 
G3 = [0, -1, 0, 0, 0;
      1,  0, 0, 0, 0;
      0,  0, 0, 0, 0;
      0,  0, 0, 0, 0;
      0,  0, 0, 0, 0];
  
G4 = zeros(5,5);
G4(1,4) = 1;

G5 = zeros(5,5);
G5(2,4) = 1;

G6 = zeros(5,5);
G6(3,4) = 1;

G7 = zeros(5,5);
G7(1,5) = 1;

G8 = zeros(5,5);
G8(2,5) = 1;

G9 = zeros(5,5);
G9(3,5) = 1;
% create confidence ellipse
% first create points from a unit circle + angle (third dimension of so(3))
phi = (-pi:.01:pi)';
circle = [zeros(length(phi),6), cos(phi), sin(phi), zeros(length(phi),1)];
% Chi-squared 9-DOF 95% percent confidence (0.05): 7.815
scale = sqrt(16.92);
ELLIPSE = zeros(size(circle,1),2);
for j = 1:size(circle,1)
     % sample covariance on SE_2(3)
     L = chol(filter.Sigma, 'lower');
%      L = diag([L(3,3),L(7,7),L(8,8)]);
     ell_se_2_3_vec = scale * L * circle(j,:)';
     % retract and right-translate the ellipse on Lie algebra to SE_2(3) using Lie exp map
     temp = filter.mu * expm(G1 * ell_se_2_3_vec(1) + G2 * ell_se_2_3_vec(2) + G3 * ell_se_2_3_vec(3) + G4 * ell_se_2_3_vec(4)...
          + G5 * ell_se_2_3_vec(5) + G6 * ell_se_2_3_vec(6) + G7 * ell_se_2_3_vec(7) + G8 * ell_se_2_3_vec(8) + G9 * ell_se_2_3_vec(9));
%      temp = filter.mu * expm(G3 * ell_se_2_3_vec(1) + G7 * ell_se_2_3_vec(2) + G8 * ell_se_2_3_vec(3));
     ELLIPSE(j,:) = [temp(1,5), temp(2,5)];
end
xlim([415, 445])
ylim([1630, 1700])
if to_plot
    hold on
    plot(ELLIPSE(:,1), ELLIPSE(:,2), 'r');
end
end

