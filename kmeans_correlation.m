function [idx,C,D] = kmeans_correlation(X,k,maxIter)
% kmeans_correlation  compute kmeans using correlation as distance between
% 2 observations. It sees observations as signals.
%   [idx,C, D] = kmeans_correlation(X,k) given data X (NxP) and k returns the
%   associations observation-centroid, centroids and distance between each
%   observation-centroid.

observations_num =size(X,1);
idx = zeros(size(X,1),1);
D = zeros(size(X,1),k);
%initializing random centroids
centroids_index = randi(observations_num,k,1);
centroids = X(centroids_index,:);
for iter=1:maxIter
    fprintf('iteration %d...\n',iter);
    old_idx = idx;
    %computing distance points-centroids
    for i=1:observations_num
        max = -1;
        for j=1:k
            tmp = corrcoef(X(i,:),centroids(j,:));
            tmp = tmp(2,1);
            D(i,j) = tmp;
            if(tmp) >(max) %correlation is between [-1;1]; getting highest
                max = tmp;
                idx(i) = j;
            end
        end
    end
    if(isequal(old_idx,idx))
        fprintf('no update in last iteration...exiting to iteration %d\n', iter);
        C = centroids;
        return;
    end
    %updating centroids    
    if iter~=maxIter
        fprintf('updating centroids...\n');
        for i=1:k
           el_cluster_i = find(idx==i); %getting elements assigned to cluster i
           centroids(i,:) = mean(X(el_cluster_i,:));    %updating centroids as means of cluster's elements
        end
    end    
end
C = centroids;
