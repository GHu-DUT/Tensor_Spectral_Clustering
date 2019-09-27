function Graph(R,partition,similarity,coordinates)
index2centrotypes=[];

EDGECOLOR=[0.3 0.3 0.3];

%% Set defaults and process optional input
default={'line','on','l', 'rdim',...
    'graphlimit','auto','colorlimit',[0.5 0.75 0.9],...
    'dense','auto','hull','on'};

% varargin=processvarargin(varargin,default);
varargin=default;
num_of_args=length(varargin);

for i=1:2:num_of_args,
    id=varargin{i}; value=varargin{i+1};
    switch lower(id)
        case 'line'
            switch lower(value)
                case 'on'
                    graph=1;
                case 'off'
                    graph=0;
                otherwise
                    error('Option ''line'' must be ''on'' or ''off''.');
            end
        case 'hull'
            switch lower(value)
                case 'on'
                    hull=1;
                case 'off'
                    hull=0;
                otherwise
                    error('Option ''hull'' must be ''on'' or ''off''.');
            end
        case 'l'
            if isnumeric(value);
                level=value;
            else
                switch lower(value)
                    case 'rdim'
                        % 	level=icassoGet(sR,'rdim');
                        level=R;
                    otherwise
                        error(['Unknown value for identifier ' id]);
                end
            end
        case 'dense'
            if ischar(value),
                switch lower(value)
                    case 'auto'
                        internallimit='auto';
                    otherwise
                        error('Option ''dense'' must be string ''auto'' or a scalar in 0...1');
                end
            else
                internallimit=value(1);
                if internallimit<0 | internallimit>1,
                    error('Option ''dense'' must be string ''auto'' or a scalar in 0...1');
                end
            end
        case 'graphlimit'
            if ischar(value),
                switch lower(value)
                    case 'auto'
                        lowlimit='auto';
                    otherwise
                        error('Option ''graphlimit'' must be string ''auto'' or a scalar in 0...1');
                end
            else
                lowlimit=value(1);
                if lowlimit<0 | lowlimit>1,
                    error('Option ''graphlimit'' must be string ''auto'' or a scalar in 0...1');
                end
            end
        case 'colorlimit'
            if any(value(:)==0) | any(value(:)==1),
                error('0 and 1 not allowed in ''colorlimit''.');
            end
            clustercolorlimit=value(:);
        otherwise
            error(['Doesn''t recognize option ''' id '''.' sprintf('\n')...
                'Available: ''level'',''dense'',''graphlimit'',' ...
                '''colorlimit'',''hull'', and ''line''.']);
    end
end

% set auto values
if strcmp(lowlimit,'auto'),
    lowlimit=min(clustercolorlimit);
end

if strcmp(internallimit,'auto'),
    internallimit=max(clustercolorlimit);
end

% Check if cluster level is valid
maxCluster=size(partition,1);
if level<=0 | level>maxCluster,
    error('Cluster level out of range or not specified.');
end

%%%%% Compute some cluster statistics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the partition

partition=partition(level,:);
Ncluster=max(partition);

% cluster statistics
c=similarity;
s=clusterstat(c,partition);

%%%% Get centrotypes %

for i = 1:R
    P = find(partition==i);
    [~,ind]=max(sum(similarity(P,P)));
    index2centrotypes(i)= P(ind);
end

%%%%%%%%%% Visualization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clf reset; hold on;

p=coordinates;

% define clustercolors
clustercolor=redscale(length(clustercolorlimit)+1);

% initiate graphic handles
h_graph=[];   % graph lines
graphText=[]; % label texts for graph lines

% Reduce similarities
% If partitioning is computed, limit not only by lowlimit but also
% by denseLim: ignore lines inside cluster hulls if average internal
% similarities are over denseLim (dense clusters)

if graph,
    c=reducesim(c,lowlimit,partition,s.internal.avg,internallimit);
end

% set colors for clusters

faceColorMatrix=repmat(NaN,Ncluster,3);
for i=1:length(clustercolorlimit);
    tmp=find(s.internal.avg(:)>=clustercolorlimit(i));
    faceColorMatrix(tmp,:)=repmat(clustercolor(i+1,:),length(tmp),1);
end

% set edgecolors
edgeColorMatrix=repmat(EDGECOLOR,Ncluster,1);

% draw faces for clusters; they have to be in
% bottom; otherwise they shade everything else

if hull,
    h_fill=clusterhull('fill',p,partition,faceColorMatrix);
end

% title(sprintf('Estimate space as a 2D CCA projection'));

if lowlimit<clustercolorlimit(1),
    graphlimit=[lowlimit, clustercolorlimit(:)', 1];
    linecolor=[repmat(clustercolor(2,2),1,3).^.5; clustercolor(2:end,:)];
else
    graphlimit=[clustercolorlimit(:)', 1];
    linecolor=clustercolor(2:end,:);
end

if graph,
    h_graph=similaritygraph(p,c, graphlimit, linecolor);
    ax=axis;
    xwidth=ax(2)-ax(1);
else
    % Only vertices
    h_graph=similaritygraph(p);
    ax=axis;
    xwidth=ax(2)-ax(1);
end

% Cluster labels
txt=cellstr(num2str([1:Ncluster]'));
% Hull edges...

if hull,
    [h_edge,txtcoord]=clusterhull('edge',p,partition,edgeColorMatrix);
    %h_clusterlabel=text(txtcoord(:,1)-xwidth/100,txtcoord(:,2),txt);
end

%...and centrotypes (cyan circles)

%% Plot centrotypes
h_centrotype=plot(p(index2centrotypes,1),p(index2centrotypes,2),'ko');
set(h_centrotype,'markersize',10,'color','c');

h_clusterlabel=text(p(index2centrotypes,1)-xwidth/100,p(index2centrotypes,2),txt);
for i=1:Ncluster,
    set(h_clusterlabel(i),'horiz','right','color',[0 0 0.7],'fontsize',17);
end

set(gca,'box','on');
