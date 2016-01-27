
%kmeans Pearson
for i=1:clusterNum
    idx_cluster_i = find(idx_constrained_kmeans_correlation==i);
    idx_cluster_i = orderByDistanceFromC(idx_cluster_i,D_kmeans_correlation_30,i);
    subj_num = zeros(size(idx_cluster_i));
    for k=1:size(idx_cluster_i,1)
       if(mod(idx_cluster_i(k),50) == 0)
          subj_num(k) = floor(idx_cluster_i(k)/50);
       else
          subj_num(k) = floor(idx_cluster_i(k)/50+1);
       end       
    end
    comp_num_subj = mod(idx_cluster_i,50);
    comp_num_subj(find(comp_num_subj==0)) = 50;
    ica_results_i = xff('new:vmp');
    %ica_results_i.NrOfMaps = size(subj_num,1);
    for j=1:size(subj_num,1)
        ica = eval(strcat('ica_',num2str(subj_num(j))));
        map = ica_results_i.Map(1); 
        subjIndex = comp_num_subj(j);
        map_1 = ica.Map(subjIndex);
        map.VMPData = map_1.CMPData; 
        map.Name = map_1.Name;
        ica_results_i.Map(j) = map;
        %ica_results_i.Map(j).Name = ica.Map(comp_num_subj(j)).Name;
        %ica_results_i.Map(j).CMPData = ica.Map(comp_num_subj(j)).CMPData;
    end
    %creating averege component
    tmp_VMP_average = zeros(size(ica_results_i.Map(j).VMPData));
    for j=1:size(subj_num,1)
        tmp_VMP_average = tmp_VMP_average + ica_results_i.Map(j).VMPData;
    end
    tmp_VMP_average = tmp_VMP_average/size(subj_num,1);
    map = ica_results_i.Map(1); 
    subjIndex = comp_num_subj(j);
    map.VMPData = tmp_VMP_average;
    map.Name = 'Average component';
    ica_results_i.Map(size(subj_num,1)+1) = map;
    %Saving result
    ica_results_i.SaveAs(strcat('cluster_',num2str(i),'_subjects.ica'));
end