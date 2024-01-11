%% Automatic stochastic generation and saving of electrodes with NMC811 particles and CBD as fibers
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

% INPUTS -----------------
folder_struct = '/'; % folder where to save the electrodes
filename_struct = 'Electrode' ; % Name of the svaed file for the electrode
N = 1 ; % Number of electrodes to generate
dimension = [30 30 100] ; % x/y/z dimension of the electrode (um)
dimension(3) = dimension(3)*1.2 ; % To account for the cropping in ElectrodeGeneration
resolution = 1/3; % Resolution of the electrodes (um/pixel)
composition = [90 10]; % Weight ratio between AM and CBD
porosity = 0.30 ; % Porosity of the electrode
density_NMC = 4.65 ;
density_CBD = 0.95 ;
% ------------------------
%% Electrode Generation
ratio_mass = (composition(:,1)*density_CBD) ./ (composition(:,2)*density_NMC) ;
Vtotal = prod(dimension)/(resolution^3) ;
Vsol = Vtotal * (1 - porosity) ;
composition = [(Vsol/Vtotal)*ratio_mass/(1+ratio_mass) (Vsol/Vtotal)/(1+ratio_mass) porosity] ; % Volumetric composition of the electrode
actual_porosity = porosity + composition(2)*0.5 % Actual porosity of the electrode taking into account 50% porous CBD
for i = 1: N
    id = ['00',num2str(i)] ;
    id = id(end-1:end) ;
    [IM,im2] = ElectrodeGeneration(dimension,resolution,composition) ;
    % save([folder_struct,id,'_',filename_struct,'.mat'],'IM') ;
end
%% Electrode Meshing
% INPUTS -----------------
resolution = 1/3; % Resolution of the electrodes (um/pixel)
folder_struct = '/' ; % folder where the electrodes are located
folder_mesh = '/' ; % folder where to save the meshes
% ------------------------
STRUCTfiles = dir(fullfile(folder_struct,'*.mat*')) ;
N = length(STRUCTfiles) ;
for i = 1 : N
    i
    im = importdata([folder_struct,STRUCTfiles(i).name]) ; % Import the electrode
    electrode2mesh = cat(3,im,3*ones(90,90,20)) ; % Add a separator on top of the electrode
    [no,fc,el] = Iso2mesh(electrode2mesh,resolution,5,5) ; 
    saveBDF(no,fc,el,[folder_mesh,STRUCTfiles(i).name(1:3),'Mesh',STRUCTfiles(i).name(3:end-4)]) ;
end