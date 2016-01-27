
% %performing clustering NOT CONSTRAINED
[idx_pamPearson,c_pamPearson,sum_pamPearson,D_pamPearson] = kmedoids(conALL_2d_ica, 20, 'Algorithm', 'pam', 'Distance', 'correlation');
[idx_kmeans,C_kmeans,sum_kmeans,D_kmeans] = kmeans(conALL_2d_ica,20);

%create a matrxi 550x20 with each column ordered by distance of component i
%from cluster j (it will be used to select nearest n points from each
%cluster)
ordered_D_pamPearson = zeros(550,20);
for i=1:20
    [B,I] = sort(D_pamPearson(:,i));
    ordered_D_pamPearson(:,i) = I;
end 
%from index to subject (ex: 340-> 340/50 = 6.8 -> subj 7)
ordered_D_pamPearson = ordered_D_pamPearson/50;
ordered_D_pamPearson = ceil(ordered_D_pamPearson);

ordered_D_kmeans = zeros(550,20);
for i=1:20
    [B,I] = sort(D_kmeans(:,i));
    ordered_D_kmeans(:,i) = I;
end 
ordered_D_kmeans = ordered_D_kmeans/50;
ordered_D_kmeans = ceil(ordered_D_kmeans);

% %CONSTRAINED CLUSTERING 
% %similarity matrix
D = pdist(conALL_2d_ica,'correlation');
k = 20; %number of cluster (shuld be number of components)

%defining constrained: each subject's component cannot pair with another
%subject component1) 
%          1-2, 1-3, 1-4, ... , 1-50
%		   2-3, 2-4, 2-5, ... , 2-50
%		   ...
%		2) 51-52, 51-53, ... , 51-100
%		   ...

%getting size of cannot link matrix
matrixSize = nchoosek(50,2) * 11;  %combination without ripetition * 11 subject
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

D_mat = squareform(D);  %pdist reurn a vector; squareform convert it to a simmetric matrix
D_mat_sparse = sparse(D_mat);   %cosc works with sparse matrix
vertex_weights = sum(D_mat_sparse,2);
[cut, clusters, viols] = cosc(D_mat_sparse, vertex_weights, k, [], CL);  
