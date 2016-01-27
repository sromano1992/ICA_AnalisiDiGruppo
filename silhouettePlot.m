function b = silhouettePlot(idx,s,name,marginy_1,marginy_2)

k = max(unique(idx));    %getting k (number of cluster)
results = zeros(size(idx,1)+(40*k),1);
currentIndex = 1;
for i=1:k
    tmp = find(idx==i);
    results(currentIndex:(currentIndex+size(tmp,1)-1)) = s(tmp);
    currentIndex = currentIndex + size(tmp,1) + 40;
end
b = bar(results);
set(gca,'xticklabel',{[]}) 
set(gca,'ylim',[marginy_1 marginy_2])
title(name)