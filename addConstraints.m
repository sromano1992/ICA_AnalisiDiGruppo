% add_constrains Remove elements from a cluster vector that don't respect a
% constrain.
%   idx = cluster vector 1xk(output of clustering algorithm)
%   D = distance matrix from each point to each centroid nxk(output of
%   clustering algorithm)
%   CL = matrix 2xk with CannotLink pairs
%   removeOutliers = remove points distant from distance's mean of other
%       points from same cluster
%   c_constrained = add_constraints(c,D,CL) returns a new vector c that
%   respects all constraints (-k for not clustered elements of cluster k)
function c_constrained = addConstraints(idx,D,CL,removeOutliers)

c_constrained = idx;
k = max(unique(idx));    %getting k (number of cluster)

fprintf('checking constraints...\n');
for i=1:k       
    cluster_i_idx = find(c_constrained==i);
    %checking violated constraints into cluster i
    for j=1:size(CL,1)
       if size(find(cluster_i_idx==CL(j,1)),1)==1 && size(find(cluster_i_idx==CL(j,2)),1)==1
           %leave only "nearest to cluster"
           CL_j_1_distance = D(CL(j,1),i);
           CL_j_2_distance = D(CL(j,2),i);
           if CL_j_1_distance < CL_j_2_distance
                c_constrained(cluster_i_idx(find(cluster_i_idx==CL(j,2)))) = cluster_i_idx(find(cluster_i_idx==CL(j,2)))*(-1);
           else
                c_constrained(cluster_i_idx(find(cluster_i_idx==CL(j,1)))) = cluster_i_idx(find(cluster_i_idx==CL(j,1)))*(-1);
           end           
       end
    end
end

%remove cluster outliers
if removeOutliers
    fprintf('removing outliers...\n');
    for i=1:k
        cluster_i_el = find(c_constrained==i);
        distance_cl_i = D(cluster_i_el,i);
        mean_dist = mean(distance_cl_i);
        for j=1:size(cluster_i_el,1)
           if distance_cl_i(j) > mean_dist
              c_constrained(cluster_i_el(j)) = c_constrained(cluster_i_el(j)) *(-1);
           end
        end
    end
end

