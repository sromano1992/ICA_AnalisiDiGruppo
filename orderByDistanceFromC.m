% orderByDistanceFromC Return new vector idx where the elements are
% ordered by distance from centroids
%   idx = clustering output
%   D = distance between each point to each centroid
%   centroid = centroid to analyze
function idx = orderByDistanceFromC(idx,D,centroid)

for i=1:size(idx,1)
   for j=i:size(idx,1)
        if (D(idx(i),centroid)>D(idx(j),centroid))
            tmp = idx(i);
            idx(i) = idx(j);
            idx(j) = tmp;
        end
   end
end
