function im_out = crop_electrode(im,h)
% Crop an electrode im at the desired thickness h
% -------------------------
% INPUTS
%  im: [nxmxp array] Image of the electrode or particle
%  h: [double] Z position where to crop
% OUTPUT
%  im_out: [nxmxp array] Cropped image of the electrode or particle
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
im_out = im(:,:,1:h) ; 
unik = unique(im_out(:,:,end)) ; 
for i = 1 : length(unik)
    ratio = length(find(im_out==unik(i)))/length(find(im==unik(i))) ;
    if ratio <0.65 
        im_out(im_out==unik(i)) = 0 ; 
        neighbor = findNeighboursMat6(find(im==unik(i))',size(im));
        temp = unique(im(neighbor(:,2)));
        temp(temp==unik(i)) = [] ; 
        temp2 = groupcounts(temp');
        if max(temp2)/sum(temp2) >0.8
            [~,pos] = max(temp2); 
            im_out(im_out==unik(i)) = temp(pos) ; 
        end
end
end
