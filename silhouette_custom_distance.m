% silhouette_custom_distance Applicates Silhouette alghoritm with a custom
% distance matrix
%   idx = cluster vector 1xk(output of clustering algorithm)
%   X = m-by-n data matrix. Rows of X correspond to observations, and
%   columns correspond to variables.
%   D = distance matrix 
function s = silhouette_custom_distance(X,idx,D)

s = zeros(size(X,1),1);
k = max(unique(idx));    %getting k (number of cluster)
for i=1:size(X,1)
    fprintf('Computing element %d...\n',i);
    %computing a(i)
    cluster_of_i = idx(i);
    el_cluster_i = find(idx==cluster_of_i);
    el_cluster_i = el_cluster_i(el_cluster_i~=i);   %removing i from res
    sum_ = 0;
    for j=1:size(el_cluster_i,1)
       sum_ = sum_ + D(i,el_cluster_i(j));
    end
    a_i = sum_/size(el_cluster_i,1);
    %computing b(i)
    for j=1:k
       if not(j==cluster_of_i)
           el_cluster_j = find(idx==j);
           sum_ = 0;
           for k=1:size(el_cluster_j,1)
               sum_ = sum_ + D(i,el_cluster_j(k));
           end
           b_set(j) = sum_/size(el_cluster_j,1);
       end
    end
    b_i = min(b_set(find(b_set~=0)));
    s(i) = (b_i-a_i)/(max(a_i,b_i));    %1 - a_i/b_i;
end