function X_new_set = run_BO_with_sets(Sets,lb,ub)
    %% train the model here
    no_sets = size(Sets,2);
    X_data = cell(1,no_sets); Y_data = zeros(no_sets,1);
    for i = 1:no_sets
        X_data{i} = Sets{i}.X;
        Y_data(i,:) = Sets{i}.HV;
    end
    count = 0; err_count = 0;
    tic;
    while count==err_count
       try
           model_params = GP(X_data,Y_data,'GA');  
       catch
            err_count = err_count+1;
       end
       count = count + 1;
    end% 
    t_model = toc;
    disp(['Time to build model is ' num2str(t_model) ' seconds']);
    %% maximise AF here to get the new set - two options in this code - GA or CMA-ES
    optimiser_AF = 'GA';
%     optimiser_AF = 'CMA-ES';
    tic;
    X_new_set = maximise_AF(X_data,Y_data,model_params,lb,ub,optimiser_AF);  
    t_AF = toc;
    disp(['Time to maximise AF is ' num2str(t_AF) ' seconds']);
end