function Sets = generate_sets(Data,no_sol,no_var,ref_point,Indicator)

Data_archive = Data;
j = 1; Sets = [];
if strcmp(Indicator,'epsilon')
    F = Data(:,no_var+1:end);
    B = first_front(-F);
    B = -B;
end

%% generate front here as in NSGA-II
while ~isempty(Data)
    F = Data(:,no_var+1:end);
    non = P_sort(F,'first')==1;
    Data_non = Data(non,:);
    if j==1
        if size(Data_non,1)<no_sol
            no_sol = size(Data_non,1);
        end
    end
      
    if size(Data_non,1)>= no_sol
        if strcmp(Indicator,'epsilon')
            [Sets{j},data_left] = sort_with_HV_Indicator(Data_non,no_sol,no_var,ref_point,B);
        elseif strcmp(Indicator,'Hypervolume')
            [Sets{j},data_left] = sort_with_HV(Data_non,no_sol,no_var,ref_point);
        end
        Data(non,:) = [];
        Data = [Data;data_left];
        
    elseif size(Data_non,1) < no_sol
        if strcmp(Indicator,'epsilon')
            Sets{j} = select_with_archive_Indicator(Data_non,Data_archive,no_sol,no_var,ref_point,Sets,B);
        elseif strcmp(Indicator,'Hypervolume')
            Sets{j} = select_with_archive(Data_non,Data_archive,no_sol,no_var,ref_point,Sets);
        end
        Data(non,:) = [];
    end
    j = j+1;
end
end

function B =  first_front(F)
    non = P_sort(F,'first')==1;
    B = F(non,:);
end