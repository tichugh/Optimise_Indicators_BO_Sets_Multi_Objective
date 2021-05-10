function [k,gl_2,gsigma,gsigman] = kernel_with_sets(X1,X2,sigmax,sigmaf,sigman)

if size(X1)~=size(X2)
    error('this implementation works for same size data set');
end

N = size(X1,1);
Sum_matrix = 0;
for n = 1:size(X1,2)
    Dist_matrix = pdist2(X1(:,n),X2(:,n));
    
    S_n_matrix = (Dist_matrix.^2)/sigmax(n).^2;
    
    Sum_matrix = Sum_matrix + S_n_matrix;
end
s = exp(-0.5*Dist_matrix);
k = sigmaf^2*s;
I_matrix_am = zeros(N,N);
diff_matrix = X1 - X2;

sum_diff_matrix = sum(diff_matrix,2);
r_zero = find(sum_diff_matrix==0);

for t = 1:length(r_zero)
    id = r_zero(t);
    I_matrix_am(id,id)=1;
end

k = k + sigman.^2*I_matrix_am;


gsigma = 2*sigmaf*s;
gl = cell(1,size(X1,2));
for n =1:size(X1,2)
    gl{n} = sigmaf^2*s.*(Dist_matrix.^2/sigmax(n).^3);
end
gsigman = 2*sigman.*I_matrix_am;


k = k(:);
gl_2 = [];
for n =1:size(X1,2)
    gl_2(:,n) = gl{n}(:);
end
gsigma = gsigma(:);
gsigman = gsigman(:);

k = sum(k)/(N*N);
% k = prod(k)/(N*N);
gl_2 = sum(gl_2,1)./(N*N);
gsigma = sum(gsigma)/(N*N);
gsigman = sum(gsigman)/(N*N);

end