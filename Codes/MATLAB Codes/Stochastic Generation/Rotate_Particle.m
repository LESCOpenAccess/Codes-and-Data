function part_rotated = Rotate_Particle(part,rot_angle,varargin)
% Rotate the particle with rot_angle

% -------------------------
% INPUTS
%  part: [nxmxp array] Particle to rotate
%  rot_angle: [1x3 array] rotation angle for each axis 
% OUTPUTS
%  part_rotated: [nxmxp array] Rotated particle
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)

centroid = round(im_ctr(part)) ; 
S = size(part); 
if nargin==1
    rot_angle = randi(180,[3,1]) ; 
end
mat_rot = cat(3,rotx(rot_angle(1)), roty(rot_angle(2)), rotz(rot_angle(3))) ; 
order = randperm(3);
mat_rot = mat_rot(:,:,order(1)) * mat_rot(:,:,order(2)) * mat_rot(:,:,order(3));
solid = find(part) ; 
[x,y,z] = ind2sub(S,solid) ; 
solid = [x,y,z]' - centroid' ; 
a = round((mat_rot * solid)*10) ; 
b = a + abs(min(a,[],2)) + 1 ; 
new_S = max(b,[],2) ; 
ind = sub2ind(new_S,b(1,:)',b(2,:)',b(3,:)'); 
part_rotated = zeros(new_S');
part_rotated(ind) = 1 ; 
part_rotated = imresize3(part_rotated,0.1,'Method','linear') ; 
part_rotated = double(part_rotated>1e-4) ; 
end
