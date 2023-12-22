function surface = surfaceTriangle(no,fc)
% Compute the surface of a triangle
% -------------------------
% INPUTS
%  no: [nx3 array] nodes of the mesh
%  fc: [nx4 array] faces of the mesh
% OUTPUTS
%  suface: [nx1 array] surface of each face in fc
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article: 
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

     VectBA = no(fc(:,1),:) - no(fc(:,2),:);    
     VectCB = no(fc(:,1),:) - no(fc(:,3),:);
     NormBA = sqrt(sum(VectBA.^2,2))  ;
     NormCB = sqrt(sum(VectCB.^2,2))  ;
     AngleBAC = acos(sum(VectBA.*VectCB,2)./(NormBA.*NormCB)) ;  
     surface = NormBA.*NormCB .* sin(AngleBAC) ./ 2 ; 
end
