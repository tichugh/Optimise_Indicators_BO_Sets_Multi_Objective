function [K,gl,gsigma,gsigman] = Cov_Mat_Sets(X_sets,sigmax,sigmaf,sigman)

[~,D] = size(X_sets); no_var = size(X_sets{1},2);
K = zeros(D,D); gsigma = zeros(D,D); gsigman = zeros(D,D);
K_temp = ones(D,D);
B = tril(K_temp);
[roo,coo] = find(B);
gl = cell(1,no_var);
for i = 1:size(roo,1)
    
    t1 = roo(i); t2 = coo(i);
    Xi = X_sets{t1};
    Xj = X_sets{t2};
    [K(t1,t2),gl_temp,gsigma(t1,t2),gsigman(t1,t2)] = kernel_with_sets(Xi,Xj,sigmax,sigmaf,sigman); 
    t = 1;
    for nn = 1:no_var
        gl{nn}(t1,t2) = gl_temp(t);
        t = t+1;
    end
    
end

K = (K+K') - eye(size(K,1)).*diag(K);
gsigma = (gsigma+gsigma') - eye(size(gsigma,1)).*diag(gsigma);
gsigman = (gsigman+gsigman') - eye(size(gsigman,1)).*diag(gsigman);

for nn = 1:no_var
    gl{nn} = (gl{nn}+gl{nn}') - eye(size(gl{nn},1)).*diag(gl{nn});
end
end