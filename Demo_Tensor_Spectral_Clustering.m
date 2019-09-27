clc
clear
close all

tic
%% Calculation of similarity matrix
R = 36; % Model order of CPD
Modes = 4; % the number of modes of the decomposed tensor
Runs = 50; % the number of runs
Resultfile = 'Multi_runs_result_R#36'; % The folder that used to store CPD results. The number of files in the folder is exactly same with Runs
file = dir([Resultfile filesep '*.mat']);
for isRun = 1:Runs
        load([Resultfile filesep file(isRun).name]);
    if isRun==1
        for isMode = 1:Modes
            Modedata{isMode} = [];
        end
    end
    for isMode = 1:Modes
        Modedata{isMode} = [Modedata{isMode}  P.u{isMode}];
    end
end
for isMode = 1:Modes
    Sim{isMode} = abs(corr(Modedata{isMode}));
end
%% Tensor Spectral Clustering
[in_avg,partition,P,newspace,CentroidIndex]=f_Tensor_Spectral_Clustering(Sim,R);
%% Centroid
for isMode = 1:Modes
    Centroid{isMode} = Modedata{isMode}(:,CentroidIndex);
end
%%
for i = 1:R
    Cont(i) = length(find(partition(R,:)==i));
end
%% Bars of Stability index
figure;
ylimit = max(Cont)*1.1;
ind = Cont'>in_avg*ylimit;
yyaxis left
tmp = zeros(size(Cont));
tmp(ind) = Cont(ind);
bar(tmp,'b');hold on;ylim([0 ylimit]);xlim([0 R+1]);hold on;
tmp = zeros(size(in_avg));
tmp(ind==0) = in_avg(ind==0);
bar(tmp*ylimit,'r');
tmp = zeros(size(Cont));
tmp(ind==0) = Cont(ind==0);
bar(tmp,'b');
tmp = zeros(size(in_avg));
tmp(ind) = in_avg(ind);
bar(tmp*ylimit,'r');
% text(1:R,Cont,num2str(Cont'),'ROtation',90,'color','b');
text(1:R,in_avg*ylimit,num2str(in_avg,2),'ROtation',90,'color','r');
ylim([0 ylimit*1.1]);
xlabel('Component#','fontsize',14);
ax = gca;
ax.YColor = 'b';
ylabel('Number of components in the cluster','fontsize',14,'color','b');
yyaxis 'right'
ax = gca;
ax.YColor = 'r';
ylim([0 1.1]);
ylabel('Stability Index: Average intra-cluster similarity','fontsize',14,'color','r');
%% Visualization of clustering result
figure;
Graph(R,partition,abs(corr(newspace')),P);
%%
toc