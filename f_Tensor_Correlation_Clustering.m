function [in_avg,partition,P,Similarity,CentroidIndex]=f_Tensor_Correlation_Clustering(Sim,nbclusters)
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
% Similarity: (matrix) aggregate matrix

% ver 1.0 092319 GQ

Modes = length(Sim);
Similarity = Sim{1};
for isMode = 2:Modes
    Similarity = Similarity.*Sim{isMode};
end
D = sim2dis(Similarity);
[partition,dendrogram,order]=hcluster(D,'AL');
%% Centroid
for i = 1:nbclusters
    P = find(partition(nbclusters,:)==i);
    [~,ind]=max(sum(Similarity(P,P)));
    CentroidIndex(i) = ind;
end
[Iq,in_avg,ext_avg]=clusterquality('mean',Similarity,partition(nbclusters,:));
P = Projection(Similarity);