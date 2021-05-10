function [f,g] = hyper_parameter(par,X,Y)
    no_var = size(X{1},2); % number of variables
    sigmax = par(1:no_var);  sigmaf = par(no_var+1); sigman = par(no_var+2);
    N = size(X,1); 
    [K,gl,gsigma,gsigman] = Cov_Mat_Sets(X,sigmax,sigmaf,sigman) ;
    K = K + 1e-8 * eye(N,N); % nugget term
    TT = chol(K,'lower');
    K_inv = inv_chol(TT);    
    
    su = Y'*K_inv*Y;        
    if det(K)==0
        ML = -0.5*(N*log(2*pi) + log(1e-100) + su);
    else
        ML = -0.5*(N*log(2*pi) + log(det(K)) + su);
    end
    f = -ML;
    
    
    g1 = zeros(1,no_var);
    for nn = 1:no_var
        su2 = Y' * K_inv * gl{nn} * K_inv * Y;
        g1(nn) = 0.5*su2 - (1/2)*trace(K_inv*gl{nn});
    end
    
    su3 = Y' * K_inv * gsigma * K_inv * Y;
    g2 = 0.5*su3 - (1/2)*trace(K_inv*gsigma);
    
    
    su4 = Y' * K_inv * gsigman * K_inv * Y;
    g3 = 0.5*su4 - (1/2)*trace(K_inv*gsigman);
    
    
    g = [-g1';-g2;-g3];
       
end