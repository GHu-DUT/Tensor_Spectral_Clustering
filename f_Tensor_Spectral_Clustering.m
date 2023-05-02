function [in_avg,partition,P,newspace,CentroidIndex]=f_Tensor_Spectral_Clustering(Sim,nbclusters)
%
% INPUTS
% Sim:        (cell)   the similarity matrix of each mode components
% nbclusters: (scalar) the number of clusters, usually selected as the
% number of extracted components
%
% OUTPUTS
% in_avg:     (vector) the stability index of components
% partition:  (matrix) contains the partitions on each level of the
% dendrogram (partition vectors)
% P:          (matrix) the projections
% newspace:   (matrix) the newspace results projected by tensor spectral
% kernal

% ver 1.0 092319 GQ

Modes = length(Sim);
Similarity = Sim{1}/diag(sum(Sim{1}));
for isMode = 2:Modes
    Similarity = Similarity.*(Sim{isMode}/diag(sum(Sim{isMode})));
end
[U,S,V] = svd(Similarity);
newspace = V(:,2:nbclusters+1);
Sim = abs(corr(newspace'));
D = sim2dis(Sim);
[partition,dendrogram,order]=hcluster(D,'AL');
%% Centroid
for i = 1:nbclusters
    P = find(partition(nbclusters,:)==i);
    [~,ind]=max(sum(Sim(P,P)));
    CentroidIndex(i) = P(ind);
end
%%
[Iq,in_avg,ext_avg]=clusterquality('mean',corr(newspace'),partition(nbclusters,:));
P = Projection(abs(corr(newspace')));
