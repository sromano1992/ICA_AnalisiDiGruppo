%This script concatenates all ica.Map.CMData of each subject
clear all;
clear all classes; fclose all;
close all hidden; clc;

str = input('Initialization string for ICAs : ','s');
d = dir([str,'.ica']);
NrOfICAs = length(d)
conALL_ica = zeros(550,58,40,46);
%%
    
for i = 1 : NrOfICAs,

    disp(d(i).name);

    %%
    ica = xff([d(i).name]);
    map = ica.Map;
    for j=1:50
        conALL_ica(j+(50*(i-1)),:,:,:) = map(j).CMPData(:,:,:);
    end
end

%building 2d matrix - vettorizzazione
conALL_2d_ica = zeros(550,10676);
for observation=1:550
   for i=1:58
       for j=1:40
           startIndex = 1840*(i-1)+46*(j-1)+1;
           endIndex = startIndex + 46 - 1;
           conALL_2d_ica(observation,startIndex:endIndex) = squeeze(conALL_ica(observation,i,j,:))';
       end
   end
end
 
%finding clusterNum (k of clustering) and
%performing clustering NOT CONSTRAINED
fprintf('PamPearson...\n');
%distanceMatrixPamPearson = getDistanceMatrix(conALL_2d_ica,'pearson','on');
for i=5:5:30    
    fprintf('iteration %d of %d...\n',i, 30);
    %eval(strcat('[idx_pamPearson_',num2str(i),',',strcat('c_pamPearson_',num2str(i),','),strcat('sum_pamPearson_',num2str(i),','),strcat('D_pamPearson_',num2str(i)),']=kmedoids(conALL_2d_ica, i, ''Algorithm'', ''pam'', ''Distance'', ''correlation'');'));
    fprintf('Computing Silhouette...\n');
    eval(strcat('[s_pamPearson_',num2str(i),'] = silhouette(conALL_2d_ica,',strcat('idx_pamPearson_',num2str(i)),',''correlation'');'));
    fprintf('Silhouette mean PamPearson %d = %d...\n',i,eval(strcat('mean(s_pamPearson_',num2str(i),')')));
end

fprintf('kmedoids Spearman...\n');
distanceMatrixPamSpearman = getDistanceMatrix(conALL_2d_ica,'spearman','on');
for i=5:5:30
    fprintf('iteration %d of %d...\n',i, 30);
    %eval(strcat('[idx_pamSpearman_',num2str(i),',',strcat('c_pamSpearman_',num2str(i),','),strcat('sum_pamSpearman_',num2str(i),','),strcat('D_pamSpearman_',num2str(i)),'] = kmedoids(conALL_2d_ica, i, ''Algorithm'', ''pam'', ''Distance'', ''Spearman'');'));
    fprintf('Computing Silhouette...\n');
    eval(strcat('[s_pamSpearman_',num2str(i),'] = silhouette_custom_distance(conALL_2d_ica,',strcat('idx_pamSpearman_',num2str(i)),',distanceMatrixPamSpearman);'));
    fprintf('Silhouette mean PamSpearman %d = %d...\n',i,eval(strcat('mean(s_pamSpearman_',num2str(i),')')));
end

fprintf('kmeans...\n');
%distanceMatrixKmeans = getDistanceMatrix(conALL_2d_ica,'euclidean','on');
for i=5:5:30
    fprintf('iteration %d of %d...\n',i, 30);
    eval(strcat('[idx_kmeans_',num2str(i),',',strcat('c_kmeans_',num2str(i)),',',strcat('sum_Kmeans_',num2str(i)),',',strcat('D_kmeans_',num2str(i),'] = kmeans(conALL_2d_ica,i);')));
    fprintf('Computing Silhouette...\n');
    eval(strcat('[s_kmeans_',num2str(i),'] = silhouette(conALL_2d_ica,',strcat('idx_kmeans_',num2str(i)),',''euclidean'');'));
    fprintf('Silhouette mean kmeans %d = %d...\n',i,eval(strcat('mean(s_kmeans_',num2str(i),')')));
end

fprintf('kmeans correlation...\n');
%correlation distance matrix
% distanceMatrixKmeansCorrelation = zeros(550,550);
% for i=1:550
%     parfor j=1:550
%         tmp = corrcoef(conALL_2d_ica(i,:),conALL_2d_ica(j,:));
%         distanceMatrixKmeansCorrelation(i,j) = tmp(2,1);
%     end
% end
for i=5:5:30
    fprintf('iteration %d of %d...\n',i, 30);
    eval(strcat('[idx_kmeans_correlation_',num2str(i),',',strcat('c_kmeans_correlation_',num2str(i)),',',strcat('sum_Kmeans_',num2str(i)),',',strcat('D_kmeans_correlation_',num2str(i)),'] = kmeans(conALL_2d_ica,i,''Distance'',''correlation'');'));
    fprintf('Computing Silhouette...\n');
    eval(strcat('[s_kmeans_correlation_',num2str(i),'] = silhouette(conALL_2d_ica',',',strcat('idx_kmeans_correlation_',num2str(i)),',''correlation'');'));
    fprintf('Silhouette mean kmeans_correlation %d = %d...\n',i,eval(strcat('mean(s_kmeans_correlation_',num2str(i),')')));
end

%Plot results
figure(1)
x_clust = [5 10 15 20 25 30];
y_pamPearson = [mean(s_pamPearson_5) mean(s_pamPearson_10) mean(s_pamPearson_15) mean(s_pamPearson_20) mean(s_pamPearson_25) mean(s_pamPearson_30)];
y_pamSpearman = [mean(s_pamSpearman_5) mean(s_pamSpearman_10) mean(s_pamSpearman_15) mean(s_pamSpearman_20) mean(s_pamSpearman_25) mean(s_pamSpearman_30)];
y_kmeansEuclidean = [mean(s_kmeans_5) mean(s_kmeans_10) mean(s_kmeans_15) mean(s_kmeans_20) mean(s_kmeans_25) mean(s_kmeans_30)];
y_kmeansPearson = [mean(s_kmeans_correlation_5) mean(s_kmeans_correlation_10) mean(s_kmeans_correlation_15) mean(s_kmeans_correlation_20) mean(s_kmeans_correlation_25) mean(s_kmeans_correlation_30)];
plot(x_clust,y_pamPearson,'-o',x_clust,y_pamSpearman,'-o',x_clust,y_kmeansEuclidean,'-o',x_clust,y_kmeansPearson,'-o');
grid on
legend({'Silhouette PamPearson','Silhouette PamSpearman','Silhouette KmeansEuclidean','Silhouette KmeansPearson'},'Location','northwest')

%Silhouette plot
%pamPearson
marginy_1 = min(min([s_pamPearson_5 s_pamPearson_10 s_pamPearson_15 s_pamPearson_20 s_pamPearson_25 s_pamPearson_30]));
marginy_2 = max(max([s_pamPearson_5 s_pamPearson_10 s_pamPearson_15 s_pamPearson_20 s_pamPearson_25 s_pamPearson_30]));
subplot(3,2,1);
silhouettePlot(idx_pamPearson_5,s_pamPearson_5,'PamPearson 5',marginy_1,marginy_2);
subplot(3,2,2);
silhouettePlot(idx_pamPearson_10,s_pamPearson_10,'PamPearson 10',marginy_1,marginy_2);
subplot(3,2,3);
silhouettePlot(idx_pamPearson_15,s_pamPearson_15,'PamPearson 15',marginy_1,marginy_2);
subplot(3,2,4);
silhouettePlot(idx_pamPearson_20,s_pamPearson_20,'PamPearson 20',marginy_1,marginy_2);
subplot(3,2,5);
silhouettePlot(idx_pamPearson_25,s_pamPearson_25,'PamPearson 25',marginy_1,marginy_2);
subplot(3,2,6);
silhouettePlot(idx_pamPearson_30,s_pamPearson_30,'PamPearson 30',marginy_1,marginy_2);
%pamSpearman
marginy_1 = min(min([s_pamSpearman_5 s_pamSpearman_10 s_pamSpearman_15 s_pamSpearman_20 s_pamSpearman_25 s_pamSpearman_30]));
marginy_2 = max(max([s_pamSpearman_5 s_pamSpearman_10 s_pamSpearman_15 s_pamSpearman_20 s_pamSpearman_25 s_pamSpearman_30]));
subplot(3,2,1);
silhouettePlot(idx_pamSpearman_5,s_pamSpearman_5,'PamSpearman 5',marginy_1,marginy_2);
subplot(3,2,2);
silhouettePlot(idx_pamSpearman_10,s_pamSpearman_10,'PamSpearman 10',marginy_1,marginy_2);
subplot(3,2,3);
silhouettePlot(idx_pamSpearman_15,s_pamSpearman_15,'PamSpearman 15',marginy_1,marginy_2);
subplot(3,2,4);
silhouettePlot(idx_pamSpearman_20,s_pamSpearman_20,'PamSpearman 20',marginy_1,marginy_2);
subplot(3,2,5);
silhouettePlot(idx_pamSpearman_25,s_pamSpearman_25,'PamSpearman 25',marginy_1,marginy_2);
subplot(3,2,6);
silhouettePlot(idx_pamSpearman_30,s_pamSpearman_30,'PamSpearman 30',marginy_1,marginy_2);
%kmeansEuclidean
marginy_1 = min(min([s_kmeans_5 s_kmeans_10 s_kmeans_15 s_kmeans_20 s_kmeans_25 s_kmeans_30]));
marginy_2 = max(max([s_kmeans_5 s_kmeans_10 s_kmeans_15 s_kmeans_20 s_kmeans_25 s_kmeans_30]));
subplot(3,2,1);
silhouettePlot(idx_kmeans_5,s_kmeans_5,'kmeansEuclidean 5',marginy_1,marginy_2);
subplot(3,2,2);
silhouettePlot(idx_kmeans_10,s_kmeans_10,'kmeansEuclidean 10',marginy_1,marginy_2);
subplot(3,2,3);
silhouettePlot(idx_kmeans_15,s_kmeans_15,'kmeansEuclidean 15',marginy_1,marginy_2);
subplot(3,2,4);
silhouettePlot(idx_kmeans_20,s_kmeans_20,'kmeansEuclidean 20',marginy_1,marginy_2);
subplot(3,2,5);
silhouettePlot(idx_kmeans_25,s_kmeans_25,'kmeansEuclidean 25',marginy_1,marginy_2);
subplot(3,2,6);
silhouettePlot(idx_kmeans_30,s_kmeans_30,'kmeansEuclidean 30',marginy_1,marginy_2);
%kmeansPearson
marginy_1 = min(min([s_kmeans_correlation_5 s_kmeans_correlation_10 s_kmeans_correlation_15 s_kmeans_correlation_20 s_kmeans_correlation_25 s_kmeans_correlation_30]));
marginy_2 = max(max([s_kmeans_correlation_5 s_kmeans_correlation_10 s_kmeans_correlation_15 s_kmeans_correlation_20 s_kmeans_correlation_25 s_kmeans_correlation_30]));
subplot(3,2,1);
silhouettePlot(idx_kmeans_correlation_5,s_kmeans_correlation_5,'kmeansPearson 5',marginy_1,marginy_2);
subplot(3,2,2);
silhouettePlot(idx_kmeans_correlation_10,s_kmeans_correlation_10,'kmeansPearson 10',marginy_1,marginy_2);
subplot(3,2,3);
silhouettePlot(idx_kmeans_correlation_15,s_kmeans_correlation_15,'kmeansPearson 15',marginy_1,marginy_2);
subplot(3,2,4);
silhouettePlot(idx_kmeans_correlation_20,s_kmeans_correlation_20,'kmeansPearson 20',marginy_1,marginy_2);
subplot(3,2,5);
silhouettePlot(idx_kmeans_correlation_25,s_kmeans_correlation_25,'kmeansPearson 25',marginy_1,marginy_2);
subplot(3,2,6);
silhouettePlot(idx_kmeans_correlation_30,s_kmeans_correlation_30,'kmeansPearson 30',marginy_1,marginy_2);

%clusterNum = 20;
% %performing clustering NOT CONSTRAINED
%[idx_pamPearson,c_pamPearson,sum_pamPearson,D_pamPearson] = kmedoids(conALL_2d_ica, clusterNum, 'Algorithm', 'pam', 'Distance', 'correlation');
%[idx_pamSpearman,c_pamSpearman,sum_pamSpearman,D_pamSpearman] = kmedoids(conALL_2d_ica, clusterNum, 'Algorithm', 'pam', 'Distance', 'Spearman');
%[idx_kmeans,C_kmeans,sum_kmeans,D_kmeans] = kmeans(conALL_2d_ica,clusterNum);
%[idx_kmeans_correlation,C_kmeans_correlation, D_kmeans_correlation] = kmeans_correlation(conALL_2d_ica,clusterNum, 20);

%correlation distance matrix
% D_correlation = zeros(550,550);
% for i=1:550
%     for j=1:550
%         tmp = corrcoef(conALL_2d_ica(i,:),conALL_2d_ica(j,:));
%         D_correlation(i,j) = tmp(2,1);
%     end
% end

CL = zeros(matrixSize,2);   %cannot link matrix
index = 1;
for k=1:11
    tmpI = 50*(k-1)+1;
    tmpJ = tmpI + 49;
    tmpInterval = tmpI + 49;
    for i=tmpI:tmpJ
        for j=i+1:tmpInterval
            CL(index,:) = [i j];
            index = index + 1;
        end
    end
end

%using my addConstraints algorithm to delete cluster's elements that
%violate the contraints
%best cluster is 30 (see silhouette plot)
idx_constrained_pamPearson = addConstraints(idx_pamPearson_30,D_pamPearson_30,CL,false);
idx_constrained_pamSpearman = addConstraints(idx_pamSpearman_30,D_pamSpearman_30,CL,false);
idx_constrained_kmeans = addConstraints(idx_kmeans_30,D_kmeans_30,CL,false);
idx_constrained_kmeans_correlation = addConstraints(idx_kmeans_correlation_30,D_kmeans_correlation_30,CL,false);

%ica clustering creation
for i = 1 : NrOfICAs,
    eval(strcat('ica_',num2str(i),'= xff([d(i).name]);'));
end
clusterNum = 30;
%kmeans
for i=1:clusterNum
    idx_cluster_i = find(idx_constrained_kmeans==i);    
    idx_cluster_i = orderByDistanceFromC(idx_cluster_i,D_kmeans_30,i);
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
%pamPearson
for i=1:clusterNum
    idx_cluster_i = find(idx_constrained_pamPearson==i);
    idx_cluster_i = orderByDistanceFromC(idx_cluster_i,D_pamPearson_30,i);
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
%pamSpearman
for i=1:clusterNum
    idx_cluster_i = find(idx_constrained_pamSpearman==i);
    idx_cluster_i = orderByDistanceFromC(idx_cluster_i,D_pamSpearman_30,i);
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
