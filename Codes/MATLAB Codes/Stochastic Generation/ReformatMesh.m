function [no,fc,el] = ReformatMesh(no,fc,el)
% Reformat the faces, and elements of a mesh by removing duplicated
% faces, adding new phase IDs for selection purpose in COMSOL, and
% modifying the elements IDs
% -------------------------
% INPUTS
%  no: [nx3 array] nodes of the mesh
%  fc: [nx4 array] faces of the mesh
%  el: [nx5 array] elements of the mesh
% OUTPUTS
%  no: [nx3 array] nodes of the mesh
%  fc: [nx4 array] faces of the mesh
%  el: [nx5 array] elements of the mesh
%
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article: 
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

% Change the IDs of the elements
el_id = unique(el(:,5)) ; 
el_id(1:3) = [] ; 
c = 1 ; 
for i = el_id'
    i
    el(el(:,end)==i,end) = 1000*c ;
    fc(fc(:,end)==i,end) = 1000*c ;
    c = c + 1 ; 
end
el(el(:,end)==3,end) = 20 ;
fc(fc(:,end)==3,end) = 20 ; 
fc(fc(:,end)==1,end) = 0 ; 
el(el(:,end)==1,end) = 0 ;
save_fc = fc ; 
[face,pos] = unique(fc(:,1:3),'rows');
pos_identical = find(fc(pos,end) == fc(pos+1,end)) ; 
fc = [face fc(pos,4)+fc(pos+1,4)]; 
fc(fc(:,end)==0,end) = 10 ;
fc(fc(:,end)==40,end) = 30 ;
fc(pos_identical,end) = save_fc(pos_identical,end) + 10 ; 
% Add a surface selecton for the Current Collector
PosZ = mink(no(unique(fc(:,1:3)),3),2) ; 
PosZ_no = reshape(no(fc(:,1:3)',3),3,length(fc)) ; 
pos = find(sum(PosZ_no)<3*PosZ(1)+ (7*PosZ(2)/3))';
fc(pos(fc(pos,4)~=10),end) = 98 ; 
% Add a surface selecton for the Li Foil
PosZ = maxk(no(unique(fc(:,1:3)),3),2) ; 
PosZ_no = reshape(no(fc(:,1:3)',3),3,length(fc)) ; 
pos = find(sum(PosZ_no)<3*PosZ(1)- (7*PosZ(2)/3))';
fc(pos(fc(pos,4)~=10),end) = 97 ; 
end
