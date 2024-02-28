%% Automatized extraction of COMSOL simulations observables
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
% INPUTS--------------
folder_comsol = '/'  ; % Specify the folder where the COMSOL files are located (example: 'MyDocuments/COMSOL Files/')
folder_mesh = '/' ; % Specify the folder where the mesh files are located
folder_struct = '/' ; % Specify the folder where the electrode files are located
folder_DchCrv_out = '/' ; % Specify the folder where the Discharge Curve files will be saved
folder_SoD_out = '/' ; % Specify the folder where the SoD files will be saved
%--------------------
COMSOLfiles = dir(fullfile(folder_comsol,'*.mph*')) ; % Get all the .mph files in folder_comsol
MESHfiles = dir(fullfile(folder_mesh,'*.bdf*')) ; % Get all the .bdf files in folder_mesh
STRUCTfiles = dir(fullfile(folder_struct,'*.mat*')) ; % Get all the .mat files in folder_struct
N = numel(COMSOLfiles) ;
count = 1 ;
clear COMSOL
% When a COMSOL file is open or incorrectly closed, .mphlock can remain and they shouldn't be considered as .mph
for i = 1: N
    if  COMSOLfiles(i).name(end) == 'h'
        COMSOL{count} = COMSOLfiles(i).name ;
        count = count + 1 ;
    else
        COMSOLfiles(i) = []  ;
    end
end
N = numel(COMSOL) ;
% You should pay attention that the COMSOL file j corresponds to the
% simulation using the electrode structure j with the mesh j
for j =  1:N
    id = ['0',num2str(j)] ;
    id = id(end-1:end) ;
    id_num = str2double(id)
    mesh_name = MESHfiles(id_num).name ;
    filename = strcat(folder_comsol,COMSOL{j}) ;
    model = mphopen(filename); % Load the COMSOL file into Matlab (can take a while)
    % The following loop links the different phases in the mesh to their label
    % in the COMSOL file
    Label_comsol = char(string(model.selection)) ; % name of the phases in COMSOL
    number = str2double(Label_comsol(find(Label_comsol=='l',1,'last')+1:end)) ; % total number of phases
    clear Label_mesh Label_selection
    for k = 1 : number
        label_mesh = char(model.selection(['nastransel',num2str(k)]).label) ;
        pos = find(label_mesh==' ');
        Label_mesh(k,1) = str2double(label_mesh(pos(1):pos(2))) ;
        Label_selection{k} = ['nastransel',num2str(k)] ;
    end
    position_NMC = find(Label_mesh == 1001) ; % find the position of the first NMC particle
    [no,fc,el] = ImportMesh(strcat(folder_mesh,mesh_name)); % Import the mesh
    fc = [fc(:,2:end),fc(:,1)] ; % Rearrange the faces with first the node IDs and then the phase ID
    NMC_particles_mesh = unique(el(:,5)) ; % get all the phases in the mesh
    NMC_particles_mesh(1:3) = []; % get rid off the undesired phases (pores, cbd, separator)
    [t,U] = mphglobal(model,{'t','liion.cdc1.phis0'}); % extract the time t and the potential U of the COMSOL simulation
    Time_Potential = [t U] ;
    save(strcat(folder_DchCrv_out,id,'_DischargeCurve.mat'),'Time_Potential') ;
    %--------------------
    % This section determines the time at which the cut-off voltage is reached (here 3.0 V)
    p = find(U(2:end)-U(1:end-1)>0,1)    ;
    if isempty(p)
        p = length(t) ;
    end
    ocv = fit(U(1:p),t(1:p),'linearinterp') ;
    t_cutoff = ocv(3.0) ;
    %-------------------
    % This section identifies the NMC particles intersected by the boundaries of the simulation box
    % and removes them from the list of NMC particles to consider
    im = importdata([folder_struct,STRUCTfiles(id_num).name]) ; % Import the electrode stack of images
    unique_border = unique([unique(im(:,:,1)) ; unique(im(:,1,:)) ; unique(im(1,:,:)) ; unique(im(:,:,end)) ; unique(im(:,end,:)) ; unique(im(end,:,:))]); % find particles on the edges
    unique_border(1:2) = [] ; % get rid off pores and CBD phases
    temp = unique_border/1000 ;
    temp = (temp(2:end) -  temp(1:end-1))-1 ;
    pos = find(temp,1,'last') ;
    part_to_remove = unique_border(pos+1:end)+1 ;
    list_name = position_NMC : number ;
    list_id = Label_mesh(position_NMC : number) ;
    temp = ismember(list_id,part_to_remove) ;
    list_id(temp) = [] ;
    list_name(temp) = [] ;
    %------------------
    % This loop extract the state of discharge of the desired NMC particles
    % at 4 different depths of discharge (25%, 50%, 75%, 100%)
    clear SoD
    for i = 1 : length(list_id)% For each AM particle, determine the SoL w at DoD = 25/50/75/100 %
        i*100/length(list_id)
        am = list_name(i) ;
        dat = mpheval(model,{'SOD'},'selection',Label_selection{list_name(i)},'t',[t_cutoff*0.25 t_cutoff*0.5 t_cutoff*0.75 t_cutoff],'edim','domain','refine',8); % You can lower the 'refine' parameter to suit your computational power
        SoD(i,:) = [list_id(i)  mean(dat.p(3,:)) mean(dat.d1,2)'] ; % Store the NMC particle ID, the thickness position and the mean state of discharge
    end
    save(strcat(folder_SoD_out,id,'_SoD.mat'),'SoD') ;
    % Coordinates  z || State of Lithiation at Depth of Discharge = 25% || 50% || 75% || 100%
end
%% Combine the SOD extracted here and the electrodes' observables
% INPUTS--------------
folder_input = '';  % Specify the folder where the electrodes' observables files are located
folder_tliq = '' ;  % Specify the folder where the electrolyte tortuosity files are located
folder_SOD =  '' ; % Specify the folder where the SOD (from COMSOL) files are located
folder_struct = '' ; % Specify the folder where the electrode image files are located
folder_out = '' ; % Specify the folder where the combined components will be saved
thickness_electrode = 150 ; % Thickness of the electrodes (um)
%--------------------
MATfiles = dir(fullfile(folder_SOD,'*.mat*')) ;
TORTUfiles = dir(fullfile(folder_tliq,'*.mat*')) ;
STRUCTfiles = dir(fullfile(folder_struct,'*.mat*')) ;
clear dod
for i = 1:length(MATfiles)
    id = MATfiles(i).name(1:2) ;
    id_num = str2double(id)
    DOD = [] ;

    tliq = importdata([folder_tliq,TORTUfiles(id_num).name]);
    f = fit(tliq(:,1)*thickness_electrode,tliq(:,3),'linearinterp') ; % Create a linear interpolation fit function for the tortuosity as a function of the thickness position
    im = importdata([folder_struct,STRUCTfiles(id_num).name]) ;
    %-------------------
    % This section identifies the NMC particles intersected by the boundaries of the simulation box
    % and removes them from the list of NMC particles to consider
    unique_border = unique([unique(im(:,:,1)) ; unique(im(:,1,:)) ; unique(im(1,:,:)) ; unique(im(:,:,end)) ; unique(im(:,end,:)) ; unique(im(end,:,:))]);
    unique_border(1:2) = [] ;
    temp = unique_border/1000 ;
    temp = (temp(2:end) -  temp(1:end-1))-1 ;
    pos = find(temp,1,'last') ;
    part_to_remove = unique_border(pos+1:end)+1 ;
    dod = importdata([folder_SOD,MATfiles(i).name]);
    dod(ismember(dod(:,1),part_to_remove),:) = [] ;
    %------------------
    % This section identifies the potential mismatches between the mesh and the electrode structure, 
    % i.e. particles in one but not in the other, and remove them
    for j = 1 : 4
        DOD = [DOD;dod(:,[1,2,2+j])] ;
    end
    input = importdata([folder_input,id,'_Input_DATA_AM.mat']) ;
    unik_in = unique(input(:,1)) ;
    unik_out = unique(DOD(:,1)) ;
    D = length(unik_out) - length(unik_in) ;
    while D~= 0
        dif_unik = find(unik_out - [unik_in ; unik_in(end)],1) ;
        DOD(DOD(:,1)==unik_out(dif_unik),:) = [] ;
        unik_out(dif_unik) = [] ;
        D = D - 1 ;
    end
    if length(DOD) ~=length(input)
        for i = 1: length(unik_out)
            pos = find(DOD(:,1)==unik_out(i)) ;
            if length(pos)>4
                DOD(pos(2:2:end),:) = [] ;
            end
        end
    end
    %------------------    
    tosave = [input(:,1:end) f(DOD(:,2)) DOD(:,[2,end])];
    tosave(find(isnan(tosave))) = 0;
    save([folder_out,id,'_Full_DATA_SoD.mat'],'tosave') ;
    % Particle ID // Volume Particle // Active surface area // CBD contact // Depth of Discharge // Tortuosity Liq // Thickness Position // SoD
end
