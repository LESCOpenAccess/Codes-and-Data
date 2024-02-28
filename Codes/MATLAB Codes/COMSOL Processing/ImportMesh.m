function [node,face,elem] = ImportMesh(filename)
% Import in Matlab a .bdf mesh file
% -------------------------
% INPUTS
%  filename: [string] adress of the .bdf mesh file to import
% OUTPUTS
%  node: [nx3 array] nodes of the mesh
%  face: [nx4 array] faces of the mesh
%  elem: [nx5 array] elements of the mesh
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article: 
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

file = fopen(filename);
mesh_data_node_face = textscan(file,'%s %f %f %f %f %f','Delimiter',',') ; 
pos = find(mesh_data_node_face{1,2} == 1,2) ; 
pos_elem = find(isnan(mesh_data_node_face{1,2}(pos(2)-1:round(2*end/3))),1) + pos(2) - 3 ; 
file = fopen(filename);
textscan(file,'%s %f %f %f %f %f',pos_elem-1,'Delimiter',',') ; 
mesh_data_elem = textscan(file,'%s %f %f %f %f %f %f','Delimiter',',') ; 
fclose(file) ; 
node = [mesh_data_node_face{1,4}(2:pos(2)-1) mesh_data_node_face{1,5}(2:pos(2)-1) mesh_data_node_face{1,6}(2:pos(2)-1)] ;
face = [mesh_data_node_face{1,3}(pos(2):pos_elem-1) mesh_data_node_face{1,4}(pos(2):pos_elem-1) mesh_data_node_face{1,5}(pos(2):pos_elem-1) mesh_data_node_face{1,6}(pos(2):pos_elem-1) ]; 
elem = [mesh_data_elem{1,4} mesh_data_elem{1,5} mesh_data_elem{1,6} mesh_data_elem{1,7} mesh_data_elem{1,3} ];
end
