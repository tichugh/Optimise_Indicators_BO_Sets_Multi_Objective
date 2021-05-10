function I =  P_evaluate_indicator(approx_set,sol_set)

    sol_set = sol_set'; approx_set= approx_set';
    M = zeros(size(sol_set,2),size(approx_set,2));
    for s = 1 : size(sol_set,2)
        
        for a = 1 : size(approx_set,2)
            
            M(s,a) = max(max(approx_set(:,a)./sol_set(:,s)));
            
        end
        
    end
    
    I = max(min(M,[],2));
end