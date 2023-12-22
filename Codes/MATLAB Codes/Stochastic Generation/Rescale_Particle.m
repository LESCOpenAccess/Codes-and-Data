function particle_out = Rescale_Particle(particle,desired_res)
% Rescale a particle to a new resolution, starting from an initial
% resolution of 0.1 um/pxl in all axes
% -------------------------
% INPUTS
%  particle: [nxmxp array] Particle to rescale
%  desired_res: [double] New resolution of the output particle (um/pxl)
% OUTPUTS
%  particle_out: [nxmxp array] Particle with the desired resolution
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
scalingFactor = [0.1 0.1 0.1]/desired_res ; 
axis1 = 1:1/scalingFactor(1):size(particle,1);
axis2 = 1:1/scalingFactor(2):size(particle,2);
axis3= 1:1/scalingFactor(3):size(particle,3);
[Axis1, Axis2, Axis3] = ndgrid(axis1, axis2, axis3);
particle_out = interpn(particle, Axis1, Axis2, Axis3,'nearest');
end
