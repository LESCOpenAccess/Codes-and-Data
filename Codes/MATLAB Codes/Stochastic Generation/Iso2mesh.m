function [no,fc,el] = Iso2mesh(im,resolution,opt,maxvol)
% Create a volumetric mesh from a 3-D image 
% -------------------------
% INPUTS
%  im: [nxmxp double array] 3-D image of the system to mesh
%  resolution: either [double] or [1x3 double] resolution of the 3-D image (um/pixel)
%  opt: [double] float number>1: max radius of the Delaunay sphere(element
%  size) (see vol2surf.m)
%  maxvol: [nx5 array] target maximum tetrahedral element volume (see
%  vol2mesh.m)
% OUTPUTS
%  no: [nx3 array] nodes of the mesh
%  fc: [nx4 array] faces of the mesh
%  el: [nx5 array] elements of the mesh
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
img = zeros(size(im)) ;
unique_IDs = unique(im) ;
for i = 1 : length(unique_IDs)
    img(im==unique_IDs(i)) = i ;
end
%% Meshing
[no,el,fc] = v2m(uint8(img+1),[],opt,maxvol,'cgalmesh') ;
el = Fixing_el(no,el) ;
no = no(:,1:3).*resolution ;
[no,fc,el] = ReformatMesh(no,fc,el) ;
end