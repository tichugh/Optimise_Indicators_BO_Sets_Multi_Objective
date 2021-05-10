function Set_data = select_with_archive(Data_non,Data_archive,no_sol,no_var,ref_point,Sets)


Data_non = find_nondominated(Data_non,Data_archive,no_var);
if size(Data_non,1)>no_sol
    %% sort with HV
    Set_data = sort_with_HV(Data_non,no_sol,no_var,ref_point);
elseif size(Data_non,1)<no_sol
    %% select from the previous set
    Set_data = select_with_previous_set(Sets,Data_non,no_sol,ref_point,no_var);
else 
    data_temp = Data_non;
    Set_data.X = data_temp(:,1:no_var);
    Set_data.F = data_temp(:,no_var+1:end);
    non = P_sort(Set_data.F,'first')==1;
    PF = Set_data.F(non,:);

    HV = P_evaluate_hv('HV',PF,ref_point);
    Set_data.HV = HV;
end


end

function Sol = find_nondominated(Sol,Data_archive,no_var)
    for i = 1:size(Data_archive,1)
        data = [Sol;Data_archive(i,:)];
        data_obj = data(:,no_var+1:end);
        data_obj = unique(data_obj,'rows');
        
        non = P_sort(data_obj,'first')==1;
        if sum(non)>size(Sol,1)
            Sol = data(non,:);
        end 
    end
end

function Set_data = select_with_previous_set(Sets,Data_non,no_sol,ref_point,no_var)

data_temp = Data_non;
for i = 1:length(Sets)
    rr = no_sol - size(data_temp,1); 
    set_i = Sets{end-i+1};
    x_size = size(set_i.X,1);

    if x_size>=rr
       t = randperm(x_size); 
       d_data_X = set_i.X(t(1:rr),:);
       d_data_F = set_i.F(t(1:rr),:);
       d_data = [d_data_X,d_data_F];
    end

    data_temp = [data_temp;d_data];

    if size(data_temp,1)==no_sol
        break;
    end

end

Set_data.X = data_temp(:,1:no_var);
Set_data.F = data_temp(:,no_var+1:end);

non = P_sort(Set_data.F,'first')==1;
PF = Set_data.F(non,:);
HV = P_evaluate_hv('HV',PF,ref_point);
Set_data.HV = HV;
end