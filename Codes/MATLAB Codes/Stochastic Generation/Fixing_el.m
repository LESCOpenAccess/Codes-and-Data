function new_el = Fixing_el(no,el)
% Modify the orders of the nodes for each elements so the tetrahedrons are well oriented
% -------------------------
% INPUTS
%  no: [nx3 array] nodes of the mesh
%  el: [nx5 array] elements of the mesh
% OUTPUT
%  el: [nx5 array] Reordered elements of the mesh
%
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
new_el = el ;
SurfNorm_base = surfacenorm(no,el(:,1:3));
Vector41 = no(el(:,4),:) - no(el(:,1),:) ;
Wrong_order = find(sum(SurfNorm_base.*Vector41,2)<0) ;
i = 1 ;
DifferentOrder = perms([1 2 3]) ;
while ~isempty(Wrong_order)
    new_el(Wrong_order,1:3) = [el(Wrong_order,DifferentOrder(i,1)) el(Wrong_order,DifferentOrder(i,2)) el(Wrong_order,DifferentOrder(i,3)) ] ;
    i = i+1 ;
    SurfNorm_base = surfacenorm(no,new_el(:,1:3));
    Vector41 = no(el(:,4),:) - no(el(:,1),:) ;
    Wrong_order = find(sum(SurfNorm_base.*Vector41,2)<0) ;
end
end
