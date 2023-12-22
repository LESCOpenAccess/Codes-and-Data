function NeighboursInd, = findNeighboursMat26(Index,MatrixSize)
%% Modified from:
%%**************************************************************************
% Module name:      findNeighbours.m
% Version number:   2
% Revision number:  02
% Revision date:    9-2018
%%
% 2013 (C) Copyright by Patrick Granton, Maastro Clinic       
% Permitted Revision and Modification by A.Zankoor September 2018
%%
%  Inputs:
%      Index: Index of pixel/voxel whose neighbours are required 
%      MatrixSize: Size of the 2D/3D Matrix 
%      conn : for 2D matrix: 4 or 8 connectivity, pixels connected by sides only, sides or corners respectiveley.
%             for 3D matrix: 6,18 or 26 connectivity, voxels connected by faces only, faces or edges, faces or edges or corners respectiveley. 
%  Outputs:
%      NeighboursInd : The valid linear indices of  neighbouring pixels/voxels
%      (valid means not out of the Matrix boundaries)
%  Example: NeighboursInd = findNeighbours(14,[3 3 3],18)
%% Description:
%  This function is a correction and modification to findNeighbours function by Patrick Granton.
%  It gives the indices of valid neighbors to a pixel/voxel in a 2D/3D matrix. 
%  Given the linear index of the pixel/voxel, the size of the 2D/3D matrix and the type of connectivity considered 
%  (4 or 8 / 6,18 or 26 connectivity), the function gives the linear indices of the neighboring pixels/voxels within the matrix size.
%  Finds the valid 8,16 or 26 neighbours of a specific index (i.e. voxel) in a 3-D volume
%  Notes:
%  for a voxel with 26 valid neighbours it has : 6  face connected voxels f (each with two zero moves) ,12 edge (only) connected voxels e (each with one zero moves)
%  , 8 corner (only) connected voxel c  (no zero moves)
%*************************************************************************
%% 3D matrices (voxels)
Index = Index' ; 
%1 , e
Base = [+1 +1 0; ...
%2 , e
+1 -1 0; ...
%3 , c
+1 +1 +1; ...
%4 , e
+1 0 +1; ...
%5 , c
+1 -1 +1; ...
%6 , c
+1 +1 -1; ...
%7 , e
+1 0 -1; ...
%8 , c
+1 -1 -1; ...
%12 , e
0 +1 +1; ...
%14 , e
0 -1 +1; ...
%15 , e
0 +1 -1; ...
%17 , e
0 -1 -1; ...
%18 , e
-1 +1 0; ...
%19 , e
-1 -1 0; ...
%20 , c
-1 +1 +1; ...
%21 , e
-1 0 +1; ...
%22 , c
-1 -1 +1; ...
%23 , c
-1 +1 -1; ...
%24 , e
-1 0 -1; ...
%25 , c
-1 -1 -1; ...
%1 , f
+1 0 0; ...
%2 , f
0 +1 0; ...
%3 , f 
0 -1 0; ...
%4 , f
0 0 +1; ...
%5 , f
0 0 -1; ...
%6 , f
-1 0 0];

Nindex = length(Index) ; 
BASE = zeros(Nindex*26,3) ;
for i = 1 : 26
    BASE(Nindex*(i-1)+1:Nindex*i,:) = repmat(Base(i,:),[Nindex,1]) ;
end
[I J K] = ind2sub([MatrixSize],Index);
neighbours = BASE + repmat([I J K],[26 1]);


valid_neighbours =   neighbours(:,1) > 0 & neighbours(:,1) <= MatrixSize(1)...
                     & neighbours(:,2) > 0 & neighbours(:,2) <= MatrixSize(2)...
                     & neighbours(:,3) > 0 & neighbours(:,3) <= MatrixSize(3);
valid_neighbours_Indices = find(valid_neighbours ==1);
NeighboursInd = sub2ind([MatrixSize],[neighbours(valid_neighbours_Indices,1)],[neighbours(valid_neighbours_Indices,2)],[neighbours(valid_neighbours_Indices,3)]);
%%
template = repmat((1:Nindex)',[26,1]);
NeighboursInd = [template(valid_neighbours_Indices)  NeighboursInd] ; 
temp = NeighboursInd(:,2)- NeighboursInd(:,1) ; 
NeighboursInd(temp<0,:) = []; 
end
