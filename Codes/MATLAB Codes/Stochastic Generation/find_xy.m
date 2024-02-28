function [x,y,m] = find_xy(posz,s)
% Randomly look for x and y position to put a particle, with the lowest
% z position m

% -------------------------
% INPUTS
%  posz: [nxm array] For each (x,y) coordinates, position of the highest z
%  value with AM
%  s: [1x3 array] Size of the particle to add
% OUTPUTS
%  x: [double] X position to add the particle
%  y: [double] Y position to add the particle
%  m: [double] Z position to add the particle
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
S = size(posz) ;
m = 1000 ;
x = [] ;
y = [] ;
for i = 1 : 5000
    xb = randi(S(1)-s(1)) ;
    yb = randi(S(2)-s(2)) ;
    temp = mean(posz(xb:xb+s(1)-1,yb:yb+s(2)-1),"all") ;
    if temp < m
        m = temp ;
        x = xb ;
        y = yb ;
    end
    if m == 1
        break
    end
end
end
