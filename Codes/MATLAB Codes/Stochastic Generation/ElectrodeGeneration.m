function [IM,im,ID] = ElectrodeGeneration(dim,res,compo)
% Generate an electrode with NMC811 particles and CBD as fibers
% -------------------------
% INPUTS
%  dim: [1x3 array] x,y,z dimension (um) 
%  res: [double] resolution of the output image (um/pxl)
%  compo: [1x3 array] volumic composition for [AM,CBD,Pores]
%  opt: [cell] Options for adding CBD 
% OUTPUTS
%  IM: [nxmxp array] Electrode
%  im: [nxmxp array] Electrode without CBD
%  ID: [nx1] List of the IDs of AM 
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
%% Add particles to the bulk of the electrode
lib = importdata('Library_NMC811_filtered.mat') ; % Import the library of NMC811 particles
N_lib = length(lib) ;
var_warning = 0 ; % warning variable (loop breaking condition)
ID = [] ; % List of the IDs of the particles in the electrode
v = 0 ;
id = 0 ; 
im = zeros(round(dim./res)) ; % Electrode
posz = ones(size(im,[1,2])) ; % Will be used to determine where to add particles 
S = size(im) ;
V = prod(dim) * compo(1) ; % Amount of AM to add to the electrode
if compo(1)>0.55 % The higher the AM ratio, higher will be the relative volume of AM added to the electrode to account for more overlapping
    coef = 1.6 ;
elseif compo(1)<0.55 && compo(1)>0.5
    coef = 1.3 ;
elseif compo(1)<0.5 && compo(1)>0.45
    coef = 1.2 ;
elseif compo(1)<0.45 && compo(1)>0.4
    coef = 1.1 ;
else
    coef = 1 ;
end
coef = coef*0.85 ;
while var_warning < 1 &&  v<V*coef
    id = id + 1 
    rand_Id = randi(N_lib)  ; % Random indice of particle in the library
    part = cell2mat(lib(rand_Id,1)); % Fitted radius of this particle
    part = Rescale_Particle(part,res) ; % Rescale the array to match with the desired resolution
    part = Rotate_Particle(part) ; % Random rotation of the particle
    s = size(part) ;
    [x,y,m] = find_xy(posz,s(1:2)) ; % Define the x and y location to add the particle, at a thickness m
    if floor(m)+s(3)-1 > S(3) % If by adding the particle, we exceed the total thickness of the electrode
            var_warning = var_warning + 1 
            id = id -1 ; 
    else
        var_warning = 0 ; 
        c = 0 ;
        temp = im ;
        temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) = temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) + part*id ;
        maximum = max(temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c),[],'all') ;
        if floor(m)+s(3)+c < S(3)
            while maximum > id % While there is an overlap, increase by 1 the z position of the particle to determine the minimal z-position c where there isn't any overlapping
                c = c + 1 ;
                temp = im ;
                temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) = temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) + part*id ;
                maximum = max(temp(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c),[],'all') ;
                if floor(m)+s(3)+c > S(3)-1 % If you exceed the thickness of the electrode, the loop stops
                    c = c -1 ;
                    break
                end
            end
            c = (c + abs(c))/2 ;
            if floor(m)+s(3) / S(3) >0.8
                c = round(c*1) ;
            else
                c = round(c*0.75) ; % To allow lower porosities, we decrease c, leading to some overlapping of AM particles 
            end
            c = round(c*0.65) ; 
            im(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) = im(x:x+s(1)-1,y:y+s(2)-1,floor(m)+c:floor(m)+s(3)-1+c) + part*id ; % Add the particle to the electrode
        end
        im(im>id) = id ; % Get rid of the overlaps
    v = v + cell2mat(lib(rand_Id,2)) ;
    v*100/V
    posz(x:x+s(1)-1,y:y+s(2)-1) = posz(x:x+s(1)-1,y:y+s(2)-1) + find_posz(part) ; % Update the minimal z-position of the xy-plane where there isn't any particles 
    ID = [ID ; id] ;
    end
    
end
im= crop_electrode(im,S(3)/1.2); % To have more realistic looking electrodes, crop the original electrode to get back to the desired size 
n = length(find(im>0)) ;
N = round(compo(1) * numel(im)) ;
dim(3) = dim(3)/1.2 ;  % update S and dim
S(3) = S(3)/1.2 ;

%% Add particles to the edges of the electrode
lib = importdata('Library_NMC811_filtered_sub200.mat') ; % Load a subset of the initial library with only small particles
N_lib = length(lib) ;
xlimits = [1 S(1)] ;
ylimits = [1 S(2)] ;
zlimits = [1 S(3) S(3)] ;
n_slices = round(dim*0.1/res) ; % Number of slices investigated from the boundaries, here 10%
lim1 = S(3)/S(2) ; 
lim1 = round(100*lim1/(2*lim1 + 1)) ; % Ratio to determine the probability of a particle beeing added to the xy-planes or the (xz/yz)-planes
while n<N
    prev_im = im ;
    id = id + 1 ;
    rand_Id = randi(N_lib) ; % Random indice of particle in the library
    part = cell2mat(lib(rand_Id,1)); % Fitted radius of this particle
    part = Rescale_Particle(part,res) ; % Rescale the array to match with the desired resolution
    part = Rotate_Particle(part) ; % Random rotation of the particle
    s = size(part) ; 
    temp = randi(100) ; % Random number to compare to lim1
    
    if temp <=  lim1 % Put a particle on the yz-plane
        x = xlimits(randi(2)) ; % Randomly select the x value of the  yz-plane
        if x == 1
            posx = find_posx(reshape(im(1:n_slices(1),:,:),[n_slices(1),S(2:3)])) ; % Update the maximal x-position from the boundary of the yz-plane where there isn't any particles
            [y,z,m] = find_xy(posx,s(2:3)) ; % Define the y and z location to add the particle, at a x-value m
            l = round(s(1)/2) ; % Cut the particle in half
            im(1:l,y:y+s(2)-1,z:z+s(3)-1) = im(1:l,y:y+s(2)-1,z:z+s(3)-1) + part(end-l+1:end,:,:)*id ; % Add the particle to the electrode
        else
            posx = find_posx(flip(reshape(im(end-n_slices(1)+1:end,:,:),[n_slices(1),S(2:3)]),1)) ; % Update the minimal x-position from the boundary of the yz-plane where there isn't any particles
            pos = find(posx==0) ; 
            posx(pos) = n_slices(1) - posx(pos)  ;
            [y,z,m] = find_xy(posx,s(2:3)) ; % Define the y and z location to add the particle, at a x-value m
            im(end-round(s(1)/2):end,y:y+s(2)-1,z:z+s(3)-1) = im(end-round(s(1)/2):end,y:y+s(2)-1,z:z+s(3)-1) + flip(part(end-round(s(1)/2):end,:,:),1)*id ; % Add the particle to the electrode
        end

    elseif temp >  lim1 && temp < 2*lim1 % Put a particle on the xz-plane
        y = ylimits(randi(2)) ; % Randomly select the y value of the xz-plane
        if y == 1
            posy = find_posy(reshape(im(:,1:n_slices(2),:),[S(1),n_slices(2),S(3)])) ; % Update the maximal y-position from the boundary of the xz-plane where there isn't any particles
            [x,z,m] = find_xy(posy,s([1,3])) ; % Define the x and z location to add the particle, at a y-value m
            l = round(s(2)/2) ; % Cut the particle in half
            im(x:x+s(1)-1,1:l,z:z+s(3)-1) = im(x:x+s(1)-1,1:l,z:z+s(3)-1) + part(:,end-l+1:end,:)*id ; % Add the particle to the electrode

        else
            posy = find_posy(flip(reshape(im(:,end-n_slices(2)+1:end,:),[S(1),n_slices(2),S(3)]),2)) ; % Update the minimal y-position from the boundary of the xz-plane where there isn't any particles
            pos = find(posy==0) ;
            posy(pos) = n_slices(2) - posy(pos)  ;
            [x,z,m] = find_xy(posy,s([1,3])) ; % Define the x and z location to add the particle, at a y-value m
            im(x:x+s(1)-1,end-round(s(2)/2):end,z:z+s(3)-1) = im(x:x+s(1)-1,end-round(s(2)/2):end,z:z+s(3)-1) + flip(part(:,end-round(s(2)/2):end,:),2)*id ; % Add the particle to the electrode
        end
    else % Put a particle on the xy-plane
        z =  zlimits(randi(length(zlimits))) ; % Randomly select the z value of the xy-plane
        if z == 1
            posz = find_posz(flip(reshape(im(:,:,1:n_slices(3)),[S(1:2),n_slices(3)]),3)) ; % Update the maximal z-position from the boundary of the xy-plane where there isn't any particles
            [x,y,m] = find_xy(posz,s([1,2])) ; % Define the x and y location to add the particle, at a z-value m
            l = round(s(3)/2) ; % Cut the particle in half
            im(x:x+s(1)-1,y:y+s(2)-1,1:l) = im(x:x+s(1)-1,y:y+s(2)-1,1:l) + part(:,:,end-l+1:end)*id ; % Add the particle to the electrode
        else
            posz = find_posz(reshape(im(:,:,end-n_slices(3)+1:end),[S(1:2),n_slices(3)])) ; % Update the minimal z-position from the boundary of the xy-plane where there isn't any particles
            [x,y,m] = find_xy(posz,s([1,2])) ; % Define the x and y location to add the particle, at a z-value m
            im(x:x+s(1)-1,y:y+s(2)-1,end-round(s(3)/2):end) = im(x:x+s(1)-1,y:y+s(2)-1,end-round(s(3)/2):end) + flip(part(:,:,end-round(s(3)/2):end),3)*id ; % Add the particle to the electrode
        end
    end
    temp = im>id ; % Locations where there are overlaps
    im(temp) = prev_im(temp) ; % Fix the overlaps 
    n = length(find(im>0)) ;
end
Ncbd = compo(2) *  numel(im) ; % Amount of CBD to add
im = im * 1000 ; 
IM = vgcf(im,2,round(Ncbd*0.9),60,1) ; % Add 90% of the CBD as fiber 
opt.Id = 2 ;
opt.w = 0.8; 
opt.method = 'voxel';
opt.IdAM = 1 ;
IM = AddSurf4(IM,round(Ncbd*0.1),opt.Id,opt.w,opt.method,opt.IdAM) ; % Add 10% of the CBD as particles 
IM = flip(IM,3);
end


