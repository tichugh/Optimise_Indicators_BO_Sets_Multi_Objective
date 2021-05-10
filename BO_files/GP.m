function [params_GP,ML] = GP(X,Y,Optimizer)
addpath(genpath('COV_MATRIX'));
addpath(genpath('Likelihood_functions'));
% 
%% maximize the likelihood function here to get back the parameters -  noise in the measurements

X_train = X; Y_train = Y;
Y_train = Y_train- mean(Y_train);
no_var = size(X_train{1},2);

if strcmp(Optimizer,'Gradient')
    n_start = 10;
    pop_opt = zeros(n_start,no_var+2);
    ML_opt = zeros(n_start,1);
    for j = 1:n_start
        x0 = [rand(1,no_var),rand,rand];
        options = optimoptions('fmincon','SpecifyObjectiveGradient',true,'Display','off');
        [pop_opt(j,:),ML_opt(j,:)] = fmincon(@(par)hyper_parameter(par,X_train,Y_train),x0,[],[],[],[],[1e-6*ones(1,no_var),1e-6,1e-8],[20*ones(1,no_var),10,1],[],options);
    end
    [ML,id] = min(ML_opt);
    pop = pop_opt(id,:);
sigmax = pop(1:no_var);
sigmaf = pop(no_var+1);
sigman = pop(no_var+2);
% % ML1

params_GP = [sigmax,sigmaf,sigman];

%% with GA
elseif strcmp(Optimizer,'GA')
    lb = [1e-6*ones(1,no_var),1e-6,1e-8];
    ub = [20*ones(1,no_var),10,1];
    options = optimoptions('ga','FunctionTolerance',1e-12,'Display','off','PopulationSize', 10*no_var);
    [pop,ML] = ga(@(par)hyper_parameter(par,X_train,Y_train),no_var+2,[],[],[],[],lb,ub,[],options);

sigmax = pop(1:no_var);
sigmaf = pop(no_var+1);
sigman = pop(no_var+2);
params_GP = [sigmax,sigmaf,sigman];

end


end


