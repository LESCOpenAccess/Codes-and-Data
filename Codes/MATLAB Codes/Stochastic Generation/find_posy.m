function posy = find_posy(im)
% Find the highest y position of AM pixel for each (x,z) coordinates in im
% -------------------------
% INPUTS
%  im: [nxmxp array] Image of the electrode or particle
% OUTPUTS
%  posy: [nxm array] Highest y position of AM pixel for each (x,z) coordinates in im
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
        im = permute(im,[1 3 2]) ; 
        S = size(im) ; 
        temp = double(im>0) ;
        a =  permute(repmat(flip(1:S(3)),[S(2),1,S(1)]),[3 1 2]) ;
        posy = max(a.*temp,[],3) ; 
end
