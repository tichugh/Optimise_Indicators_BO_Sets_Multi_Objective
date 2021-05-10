function [y_pred,std_dev] = GP_prediction(X_test,X_train,Y_train,params)

no_var = size(X_test{1},2);

X = X_train;
Y = Y_train;
mean_Y = mean(Y_train);
% mean_Y = max(Y_train);

Y = Y - mean_Y;
sigmax = params(1:no_var);
sigmaf = params(no_var+1);
sigman = params(no_var+2);

[~,N1] = size(X);
[~,N2] = size(X_test);
K = Cov_Mat_Sets(X,sigmax,sigmaf,sigman) + 0.00001 * eye(N1,N1); % N x N covariance matrix

K_star1 = [];
for ii = 1:N1
    Xi = X{ii};
    for j = 1:N2
        Xj = X_test{j};
%         K_star1(ii,j) = kernel_with_sets_V3(Xi,Xj,sigmax,sigmaf,sigman);
        K_star1(ii,j) = kernel_with_sets(Xi,Xj,sigmax,sigmaf,sigman);
    end
end

% NN = size(X_test,1);
K_star2 = Cov_Mat_Sets(X_test,sigmax,sigmaf,sigman) + 0.00001 * eye(N2,N2);

TT = chol(K,'lower');
K_inv = inv_chol(TT);

m = K_star1'*K_inv*Y; % caluated mean for the test data
Cov = K_star2 - K_star1'*K_inv*K_star1; % covariance for the test data
Var_test = diag(Cov);
ST_test = sqrt(Var_test);
    
% mt = m';
% 
% tj = (Cov + Cov')/2;
% R2 = mvnrnd(mt,tj); % generating multivariare random posteriror distribution for the test data


y_pred = m;
y_pred = y_pred + mean_Y;
std_dev = ST_test;
