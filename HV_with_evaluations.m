clear; clc; close all;
addpath(genpath('Support_files'));

%% settings
no_runs =11; 
Problems = {'DTLZ2','DTLZ4','DTLZ5','DTLZ6','DTLZ7'};
M = 2; no_var = 3; K_problem = no_var - M + 1;
N = 10*no_var;
maxFE = 100;
Plot_dir = (['Plots/M_' num2str(M) '_style_2']);
%%
Results_BO_HV_dir = 'Results';
Results_BO_Indicator_dir = 'Results_Indicator';
Results_ParEGO_dir = 'Results_ParEGO';
Results_EHVI_dir = 'Results_EHVI_EGO';
%%

%% Hypervolume with function evaluations 

for p = 1:length(Problems)
    Problem = Problems{p};
    True_PF = P_objective('true',Problem,M,500, K_problem);
    ref_point = max(True_PF) + 1;
    
    HV_BO_Hypervolume = calculate_hypervolume(Results_BO_HV_dir,ref_point,no_runs,maxFE,N,Problem,M,no_var);
    HV_BO_Indicator = calculate_hypervolume(Results_BO_Indicator_dir,ref_point,no_runs,maxFE,N,Problem,M,no_var);
    HV_BO_ParEGO = calculate_hypervolume(Results_ParEGO_dir,ref_point,no_runs,maxFE,N,Problem,M,no_var);
    HV_BO_EHVI = calculate_hypervolume(Results_EHVI_dir,ref_point,no_runs,maxFE,N,Problem,M,no_var);
    
    HV_true = P_evaluate_hv('HV',True_PF,ref_point);
    %% plotting
    plot_hypervolume(HV_BO_Hypervolume,HV_BO_Indicator,HV_BO_ParEGO,HV_BO_EHVI,HV_true,N,Problem)
end


function HV_runs = calculate_hypervolume(dir,ref_point,no_runs,maxFE,N,Problem,M,no_var)

    HV_runs = zeros(maxFE-N+1,no_runs);    
    for run = 1:no_runs
        Data_Solutions = [];
        
        Data = load ([dir '/Archive_solutions_' Problem 'M_' num2str(M) '_n_' num2str(no_var) '_run_' num2str(run) '.mat']);
        
        if strcmp(dir,'Results_ParEGO') || strcmp(dir,'Results_EHVI_EGO')
            Data_Solutions = Data.Archive;
        else
            for i = 1:length(Data.Archive)
                Data_Solutions = [Data_Solutions;Data.Archive{i}];  
            end
        end
        Data_Solutions = Data_Solutions(1:maxFE,:);
        
        t = 1;
        HV_fun = zeros(maxFE-N,1); 
        for fun = N:maxFE
            obj_val = Data_Solutions(1:fun,no_var+1:end);
            non = P_sort(obj_val,'first')==1;
            PF = obj_val(non,:);
            HV_fun(t,:) = P_evaluate_hv('HV',PF,ref_point);
                     
            t = t+1;
        end
        
        HV_runs(:,run) = HV_fun;        
    end
end

function plot_hypervolume(HV_BO_Hypervolume,HV_BO_Indicator,HV_BO_ParEGO,HV_BO_EHVI,HV_true,N,Problem)

    %%
    HV_BO_Hypervolume = HV_BO_Hypervolume/HV_true;
    std_HV_BO_Hypervolume = std(HV_BO_Hypervolume,[],2);
    max_HV_BO_Hypervolume = mean(HV_BO_Hypervolume,2) + 1*std_HV_BO_Hypervolume;
    min_HV_BO_Hypervolume = mean(HV_BO_Hypervolume,2) - 1.*std_HV_BO_Hypervolume;
    
    
    %%
    HV_BO_Indicator = HV_BO_Indicator/HV_true;
    std_HV_BO_Indicator= std(HV_BO_Indicator,[],2);
    max_HV_BO_Indicator = mean(HV_BO_Indicator,2) + 1.*std_HV_BO_Indicator;
    min_HV_BO_Indicator = mean(HV_BO_Indicator,2) - 1.*std_HV_BO_Indicator;
    
    
    %%
    HV_BO_ParEGO = HV_BO_ParEGO/HV_true;
    std_HV_BO_ParEGO= std(HV_BO_ParEGO,[],2);
    max_HV_BO_ParEGO = mean(HV_BO_ParEGO,2) + 1.*std_HV_BO_ParEGO;
    min_HV_BO_ParEGO = mean(HV_BO_ParEGO,2) - 1.*std_HV_BO_ParEGO;
    
    
    %%
    
    HV_BO_EHVI = HV_BO_EHVI/HV_true;
    std_HV_BO_EHVI= std(HV_BO_EHVI,[],2);
    max_HV_BO_EHVI = mean(HV_BO_EHVI,2) + 1.*std_HV_BO_EHVI;
    min_HV_BO_EHVI = mean(HV_BO_EHVI,2) - 1.*std_HV_BO_EHVI;
    
    
    %%
    
    
    figure;
    X = [N:size(HV_BO_Hypervolume,1)+N-1]';
    plot(X,mean(HV_BO_Hypervolume,2),'LineWidth',2,'Color','k');
    hold on;
    plot(X,mean(HV_BO_Indicator,2),'LineWidth',2,'Color','b');
    plot(X,mean(HV_BO_ParEGO,2),'LineWidth',2,'Color','red');
    plot(X,mean(HV_BO_EHVI,2),'LineWidth',2,'Color','green');
    
    x2 = [X; flipud(X)];
    inBetween = [max_HV_BO_Hypervolume; flipud(min_HV_BO_Hypervolume)];
    patch(x2, inBetween, [17 17 17]/255, 'FaceAlpha',0.1, 'EdgeColor','none');
    
    inBetween = [max_HV_BO_Indicator; flipud(min_HV_BO_Indicator)];
    patch(x2, inBetween, 'b', 'FaceAlpha',0.1, 'EdgeColor','none');
    
    inBetween = [max_HV_BO_ParEGO; flipud(min_HV_BO_ParEGO)];
    patch(x2, inBetween, 'r', 'FaceAlpha',0.1, 'EdgeColor','none');
    
    inBetween = [max_HV_BO_EHVI; flipud(min_HV_BO_EHVI)];
    patch(x2, inBetween, 'g', 'FaceAlpha',0.1, 'EdgeColor','none');
    
    
    hold off;
    
%     hl = legend('BO over sets - Hypervolume','BO over sets - \epsilon','ParEGO','EHVI-EGO','Location','southeast');
%     set(hl, 'interpreter', 'tex')
%     legend('BO over sets','ParEGO','Location','southeast');
    box on;
    xlabel('Number of function evaluations');
    ylabel('Hypervolume ratio');
    title([Problem])
    xlim([30,100])
    %% check here GP code to plot the hypervolume with function evaluations with max and min filling 
    ax = gca;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    


end



