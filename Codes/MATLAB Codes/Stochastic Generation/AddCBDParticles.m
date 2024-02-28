function IM = AddCBDParticles(IM,N,Id,w,method,Id_AM,varargin)
%% Modified from AddSurf3: https://www.sciencedirect.com/science/article/pii/S0378775320313987#appsec2
% Add stochastically CBD as particles (pixels/voxels) in im
% -------------------------
% INPUTS
%  IM: [nxmxp array] Image of the electrode
%  N: [int] Number of pixel to convert to CBD
%  Id: [int] Value associated to CBD in IM
%  w: [double] Between 0 and 1, if close to 1 the CBD will form aggregate,
%  if close to 0 it will form a film covering the phase with the ID=Id_AM
%  method: [string] If 'pixel', add CBD pixel per pixel, if 'voxel', add CBD by blocks of 3x3x3 pixels 
%  Id_AM: [int] Value associated to AM in IM
% OUTPUTS
%  IM: [nxmxp array] Image of the electrode with CBD
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

if w > 0.99
    w = 0.99 ; 
end
if unique(IM)==0
    error('The image is empty !! ')
    return
end
if nargin ==5
    Id_AM = 1 ;
end
indPore = find(IM==0) ; 
dim = size(IM) ;
NindPore = length(indPore) ;
i = 0 ;
pourcent = round((0.05:0.05:1)*N);
pourcentage = 5:5:100 ;
compteur = 1 ;
while i < N  
    if i > pourcent(compteur)
        message = [num2str(pourcentage(compteur)),' % ...'] ;
        disp(message)
        compteur = compteur + 1 ;
    end
    summ = 0 ;
    while summ==0 
        pxl_void = randi(NindPore); 
        ind = indPore(pxl_void) ; 
        if IM(ind) == 0 
            neighbors = findNeighboursSEI(ind,dim,6) ; 
            neighbors = neighbors(:,2) ; 
            Id_neighbors = IM(neighbors); 
            summ = sum(Id_neighbors) ;
        end
        if summ ~= 0 
            if ismember(Id,Id_neighbors)==0 
                summ = rand()< 1-w ; 
            elseif ismember(Id_AM,Id_neighbors)==0 
                summ = rand()< w ; 
            end
        end
    end
    if sum(method == 'pixel')==5
        N_void = 0 ; 
    elseif sum(method == 'voxel')==5
        Neighbors_void = find(IM(neighbors)==0) ; 
        N_void = length(Neighbors_void);
        ind = [ind ; neighbors(Neighbors_void)] ;
    end
    IM(ind) = Id ;  
    i = i + N_void + 1 ;
end
end
