function posz = find_posz(im)
% Find the highest z position of AM pixel for each (x,y) coordinates in im
% -------------------------
% INPUTS
%  im: [nxmxp array] Image of the electrode or particle
% OUTPUTS
%  posz: [nxm array] Highest z position of AM pixel for each (x,y) coordinates in im
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
    im = flip(im,3) ;
    S = size(im) ;
    temp = double(im>0) ;
    temp(temp==0) = S(3)+1 ;
    a =  permute(repmat((1:S(3)),[S(2),1,S(1)]),[3 1 2]) ;
    posz = min(a.*temp,[],3) ;
    posz = S(3)+1 - posz ;
end
