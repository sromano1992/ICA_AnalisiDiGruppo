% getDistanceMatrix Return distance matrix m-by-n from input matrix X
% m-by-n
%   X = m-by-n data matrix. Rows of X correspond to observations, and
%   columns correspond to variables.
%   distance = computes the distance between objects in the data matrix, X,
%   using the method specified by distance, which can be any of the
%   pdist distance values.  
%   verbose = 'on' to show log; 'off' to not show log
function D = getDistanceMatrix(X,distance,verbose)

D = zeros(size(X,1),size(X,1));
for i=1:size(X,1)
    for j=i:size(X,1)
        if(verbose=='on')
            fprintf('%d-%d...\n',i,j);
        end
        D(i,j) = pdist([X(i,:); X(j,:)], distance); 
        D(j,i) = D(i,j);
    end
end