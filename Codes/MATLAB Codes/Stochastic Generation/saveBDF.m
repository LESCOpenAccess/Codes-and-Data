function saveBDF(no,fc,el,filename)
% Save a mesh as a .bdf file
% -------------------------
% INPUTS
%  no: [nx3 array] nodes of the mesh
%  fc: [nx4 array] faces of the mesh
%  el: [nx5 array] elements of the mesh
%  filename: [string] adress where to save the .bdf mesh file
%
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article: 
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
pos = find(filename=='.') ; 
if ~isempty(pos)
    filename(filename(pos:end)) = '' ; 
end
Filename = strcat(filename,'.bdf') ; 
Length_no = size(no,1);
Length_fc = size(fc,1);
Length_el = size(el,1);
el(:,5) = el(:,5)+1 ; 
fp = fopen(Filename,'wt');
fprintf(fp,'$ Nastran Free (.bdf) mesh file \n');
fprintf(fp,'GRID,%d,%d,%d,%d,%d\n',([(1:Length_no)',zeros(Length_no,1),no])');
fprintf(fp,'\nCTRIA3,%d,%d,%d,%d,%d',([(1:Length_fc)',fc(:,[4 1:3])])');
fprintf(fp,'\nCTETRA,%d,%d,%d,%d,%d,%d',([(1:Length_el)'+Length_fc,el(:,[5 1:4])])');
fprintf(fp,'\nENDDATA');
fclose(fp);
end