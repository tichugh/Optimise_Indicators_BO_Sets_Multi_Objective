function X_new_set = maximise_AF(X_data,Y_data,model_params,lb,ub,optimiser_AF)

no_sol = size(X_data{1},1);
X_new_set = zeros(no_sol,size(X_data{1},2));
no_sets = size(X_data,2);
X = [];
for i = 1:no_sets
    x_temp = X_data{i};
    x_temp2 = x_temp(:);
    X = [X;x_temp2'];
end
no_var = size(X,2);
lb_c = []; ub_c = [];
for i = 1:size(lb,2)
    lb_c = [lb_c,repmat(lb(i),1,no_sol)];
    ub_c = [ub_c,repmat(ub(i),1,no_sol)];
end

%% cma-es
if strcmp(optimiser_AF,'CMA-ES')

    opts.LBounds = lb_c'; opts.UBounds = ub_c'; 
    x =cmaes('ei', rand(no_var,1), 0.5, opts,X_data,Y_data,no_sol,model_params);
elseif strcmp(optimiser_AF,'GA')
    options = optimoptions('ga','Display', 'off','PopulationSize',10*no_var);
    x = ga(@(x)ei(x,X_data,Y_data,no_sol,model_params),no_var,[],[],[],[],lb_c,ub_c,[],options);
end
for i = 1:size(X_data{1},2)
    X_new_set(:,i) = x((i-1)*no_sol+1:i*no_sol);
end
end

function f = ei(x,X_data,Y_data,no_sol,model_params)
%% convert x back to set here
X_test = zeros(no_sol,size(X_data{1},2));
for i = 1:size(X_data{1},2)
    X_test(:,i) = x((i-1)*no_sol+1:i*no_sol);
end
X_test_{1} = X_test;
y_min = min(Y_data);
[y,s] = GP_prediction(X_test_,X_data,Y_data,model_params);
if s>0
   EI_fit     = -((y_min-y).*normcdf((y_min-y)./s) ) -  ( s.*normpdf((y_min-y)./s) );
else
   EI_fit = 0;
end


f = EI_fit;
end
% 
% function [c,ceq] = cons_ga(x,X_data,Y_data,no_sol,model_params)
%         X_test = zeros(no_sol,size(X_data{1},2));
%         for i = 1:size(X_data{1},2)
%             X_test(:,i) = x((i-1)*no_sol+1:i*no_sol);
%         end
% 
%         X_test_{1} = X_test;
% 
% %%
% %         y_min = min(Y_data);
%         y_max = max(Y_data);
%         [y,s] = GP_prediction(X_test_,X_data,Y_data,model_params);
%         c = y_max - y;
%         ceq = [];
% end