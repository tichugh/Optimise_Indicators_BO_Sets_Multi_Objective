function [Set_data,data_left] = sort_with_HV(Data_non,no_sol,no_var,ref_point)

    if size(Data_non,1)==no_sol
        Set_data.X = Data_non(:,1:no_var);
        Set_data.F = Data_non(:,no_var+1:end);
        HV_set = P_evaluate_hv('HV',Set_data.F,ref_point);
        Set_data.HV = HV_set;
        data_left = [];
    else
        F = Data_non(:,no_var+1:end);
        HV = P_evaluate_hv('HV',F,ref_point);

        HV_ind = zeros(size(Data_non,1),1);
        for i = 1:size(Data_non,1)
            Data_temp = Data_non;
            Data_temp(i,:) = [];
            F_temp = Data_temp(:,no_var+1:end);
            HV_temp = P_evaluate_hv('HV',F_temp,ref_point);

            HV_ind(i,:) = HV - HV_temp;
        end

        [~,index] = sort(HV_ind,'descend');
        Set = Data_non(index(1:no_sol),:);
        F_set = Set(:,no_var+1:end);
        HV_set = P_evaluate_hv('HV',F_set,ref_point);

        Set_data.X = Set(:,1:no_var);
        Set_data.F = Set(:,no_var+1:end);
        Set_data.HV = HV_set;
        data_left = Data_non(index(no_sol+1:end),:);
    end
    
end