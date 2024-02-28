%% Automatic extraction of observables from electrodes structures and meshes for ML purpose
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
%% MESH OBSERVABLES
% INPUTS--------------
folder_mesh = '/' ; % Folder where the meshes are located
folder_mshdata = '/' ; % Folder where the meshes observables will be saved
%--------------------
MESHfiles = dir(fullfile(folder_mesh,'*.bdf*')) ; % Get all the .bdf mesh files in folder_mesh
N = length(MESHfiles) ;

for j = 1: N
    mesh_name = MESHfiles(j).name;  %
    [node,face,elem] = ImportMesh(strcat(folder_mesh,mesh_name));
    face = [face(:,2:end),face(:,1)] ;
    NMC_particles_mesh = unique(elem(:,5)) ;
    NMC_particles_mesh(1:3) = [];
    N_NMC = length(NMC_particles_mesh) ;
    Active_Surface = zeros(N_NMC,1) ;
    Vol_NMC = zeros(N_NMC,2) ;
    CBD_Contact = zeros(N_NMC,1) ;
    count = 0 ;
    for i = 1 : N_NMC
        100*i/N_NMC
        nmc = NMC_particles_mesh(i) ;
        particle = find(elem(:,5)==nmc);
        V =  Volume_phase(node,elem,nmc)  ;
        Vol_NMC(i+count,:) = [nmc V] ;
        Active_Surface(i+count,1) = sum(surfaceTriangle(node,face(face(:,4)==NMC_particles_mesh(i)-1,:)));
        CBD_Contact(i+count,1) = sum(surfaceTriangle(node,face(face(:,4)==NMC_particles_mesh(i)+1,:)));
    end
    data2save = [Vol_NMC Active_Surface CBD_Contact./(Active_Surface+CBD_Contact)] ;
    save(strcat(folder_mshdata,mesh_name(1:end-4),'_MeshData.mat'),'data2save')
end

%% Tortuosity Electrolyte
% INPUTS--------------
folder_out ='/' ;  % Folder where the electrolyte tortuosity will be saved
folder_struct = '/' ; % Folder where the electrodes structures are located
thickness = 150 ; % Total thickness of the electrodes (um)
% Open TauFactor
%--------------------
STRUCTfiles = dir(fullfile(folder_struct,'*.mat*')) ; % Get all the .mat electrodes files in folder_struct
N = length(STRUCTfiles) ;
for i = 1:N
    id = ['0',num2str(i)] ;
    id = id(end-1:end)
    im = importdata([folder_struct,STRUCTfiles(i).name]) ;
    clear tortuosity_electrolyte
    FindTau = 1 ; % Calculate the tortuosity
    FindMetrics = 0 ; % Don't calculate metrics
    RVAmode = 0 ;
    PhaDir = [ 0 0 1 ; 0 0 0 ; 0 0 0  ] ;
    VoxDims = [ 1 1 1] ;
    new_im = im ;
    new_im(new_im>2) = 10 ;
    Diff_coef = [1 0.5^1.5 0 ] ;
    it = 20 ;
    L = size(im,3) ;
    temp = round(L/it);
    thickness_subslice = mod(L,it) ;
    add =  [ones(1,it-thickness_subslice)*temp-1 ones(1,thickness_subslice)*temp];
    for j = 1 : it-1
        Results = TauFactor('InLine',FindTau,FindMetrics,RVAmode,new_im(:,:,L-sum(add(1:j)):end),PhaDir,VoxDims,Diff_coef);
        thickness_subslice =  fieldnames(Results) ;
        Resultstortuosity = Results.(thickness_subslice{1}) ;
        if isstruct(Resultstortuosity) == 1
            tortuosity_electrolyte(j) = Results.Tau_M3.Tau ;
        end
    end
    Results = TauFactor('InLine',FindTau,FindMetrics,RVAmode,new_im(:,:,1:end),PhaDir,VoxDims,Diff_coef);
    thickness_subslice =  fieldnames(Results) ;
    Resultstortuosity = Results.(thickness_subslice{1}) ;
    if isstruct(Resultstortuosity) == 1
        tortuosity_electrolyte(j+1) = Results.Tau_M3.Tau ;
    end
    tortuosity_electrolyte = [(L-cumsum(add'))/L  thickness*ones(size(tortuosity_electrolyte')) tortuosity_electrolyte'] ;
    save([folder_out,id,'_tortuosity_electrolyte.mat'],"tortuosity_electrolyte")
end
%% Combining the observables
% INPUTS--------------
folder_struct = '/'; % Folder where the electrodes structures are located
folder_mshdata = '/' ; % Folder where the meshes observables are located
folder_out = '/' ;  % Folder where the combined observables will be saved
%--------------------
folders = {folder_struct; folder_mshdata} ; 
STRUCTfiles = dir(fullfile(folder_struct,'*.mat*')) ; % Get all the .mat electrodes files in folder_struct
MSHDATAfiles =  dir(fullfile(folder_mshdata,'*.mat*')) ; % Get all the .mat electrodes files in folder_mshdata
N = numel(dir(fullfile(folders{2},'*.mat*'))) ;
for i = 1:N
    id = ['0',num2str(i)] ;
    id = id(end-1:end)
    im = importdata([folder_struct,STRUCTfiles(i).name]) ;
    w = importdata([folder_mshdata,MSHDATAfiles(i).name]) ;
    pos = [] ;
    c = 1 ;
    unik = unique(im) ;
    unik(1:2) = [];
    for k = 1 : length(unik)
        if isempty(find(w(:,1)-1 == unik(k),1))
            pos(c) = k ;
            c = c + 1 ;
        end
    end
    unik(unique(pos)) = [] ;
    %-------------------
    % This section identifies the NMC particles intersected by the boundaries of the simulation box
    % and removes them from the list of NMC particles to consider
    unik_mesh = unique(w(:,1)) ;
    list_a = ismember(unik,unik_mesh-1) ;
    list_m = ismember(unik_mesh-1,unik) ;
    a = [] ;
    unique_border = unique([unique(im(:,:,1)) ; unique(im(:,1,:)) ; unique(im(1,:,:)) ; unique(im(:,:,end)) ; unique(im(:,end,:)) ; unique(im(end,:,:))]);
    unique_border(1:2) = [] ;
    temp = unique_border/1000 ;
    temp = (temp(2:end) -  temp(1:end-1))-1 ;
    pos = find(temp,1,'last') ;
    part_to_remove = unique_border(pos+1:end)+1 ;
    for k = 2: length(folders)
        k
        Formatfile = dir(fullfile(folders{k},'*.mat*')) ;
        temp = importdata([folders{k},Formatfile(i).name]) ;
        if ~isempty(a)
            if length(a) > length(temp)
                a = a(list_a,:) ;
            elseif length(a) < length(temp)
                temp = temp(list_m,:) ;
            end
        end
        a = [a temp] ;
    end
    a(ismember(a(:,1),part_to_remove),:) = [] ;
    %------------------
    DoD = [0.25*ones(length(a),1) ; 0.5*ones(length(a),1) ; 0.75*ones(length(a),1) ; ones(length(a),1) ];
    tosave = [repmat(a,[4,1]) DoD];
    save([folder_out,id,'_Input_DATA_AM.mat'],'tosave') ;
end
