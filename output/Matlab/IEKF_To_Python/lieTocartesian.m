function lieTocartesian(filter)

f = @func;
kappa = 2;
X = logm(filter.mu);
x = [];
x(1,1) = X(3,2);
x(2,1) = X(1,3);
x(3,1) = X(2,1);
x(4:6,1) = X(1:3,4);
x(7:9,1) = X(1:3,5);
x(2,1) = X(2,5);
x(3,1) = X(3,5);
x(4,1) = X(2,1); 
ut = unscented_transform(x, filter.Sigma, f, kappa);
ut.propagate();
filter.mu_cart = [filter.mu(1,5);filter.mu(2,5);filter.mu(3,5);atan2(filter.mu(2,1), filter.mu(1,1))];
filter.sigma_cart = ut.Cov;
end

function y = func(x)

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
  
X = expm(x(1)*G1 + x(2)*G2 + x(3)*G3 + x(4)*G4 + x(5)*G5 + x(6)*G6 + x(7)*G7 + x(8)*G8 + x(9)*G9);
y = [];
y(1,1) = atan2(X(3,2), X(3,3));
y(2,1) = asin(-X(3,1));
y(3,1) = atan2(X(2,1), X(1,1));
y(4,1) = X(1,4);
y(5,1) = X(2,4);
y(6,1) = X(3,4);
y(7,1) = X(1,5);
y(8,1) = X(2,5);
y(9,1) = X(3,5);

end
  