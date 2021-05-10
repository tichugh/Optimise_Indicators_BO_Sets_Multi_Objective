clear; clc; close all;
addpath(genpath('Support_files'));
addpath(genpath('BO_files'));
warning('off');

Indicator = 'Hypervolume';
% Indicator = 'epsilon';
if strcmp(Indicator,'Hypervolume')
    result_dir = 'Results';
elseif strcmp(Indicator,'epsilon')
    result_dir = 'Results_Indicator';
end

%% Benchmark Problem and its parameters
Problem = 'DTLZ5' ; M = 2; % number of objectives;
no_var = 3; % number of decision variables
lb = zeros(1,no_var); ub = ones(1,no_var); %lower and upper bounds
K_problem = no_var - M + 1; % specific to DTLZ problems
%% algorithm parameters
no_sol = 5; % cardinality of the sets - fixed here but can be changed
maxFE = 100; % maximum number of expensive evaluations
N = 10*no_var; % size of the initial data set for training GP model - change here if you already have sone data

run =  1;
%% load the initial data set or initialise it
load (['Initial_Population/Initial_pop_' Problem 'M_' num2str(M) '_n_' num2str(no_var) '_run_' num2str(run) '.mat']);
X = Data(:,1:no_var); F = Data(:,no_var+1:end);
Archive{1} = Data;
FE = size(Data,1);
%%
itr =1;
while FE < maxFE
    %% Generate sets
    ref_point = max(Data(:,no_var+1:end)) + 1;
    tic;
    Sets = generate_sets(Data,no_sol,no_var,ref_point,Indicator);
    t_sets = toc;
    disp(['Time to generate sets is ' num2str(t_sets) ' seconds']);
    if strcmp(Indicator,'Hypervolume')
        for ss = 1:length(Sets)
            Sets{ss}.HV = -Sets{ss}.HV; % as we are trying to maximise hypervolume 
        end
    end
    %% get a new set by using Bayesian optimisation over sets            
    X_new_set = run_BO_with_sets(Sets,lb,ub);
    X_new_set= unique(X_new_set,'rows');

    %% check if the vectors in the new set has already been evaluated
    id = ~ismember(X_new_set,Data(:,1:no_var),'rows');
    X_new = X_new_set(id,:);
    F = P_objective('value',Problem,M,X_new,K_problem);
    FE = FE + size(F,1)
    Data = [Data;[X_new,F]]; Archive{itr+1} = [X_new,F];
    itr = itr+1;
end
save([result_dir '/Archive_solutions_' Problem 'M_' num2str(M) '_n_' num2str(no_var) '_run_' num2str(run) '.mat'],'Archive'); 


