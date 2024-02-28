function ctrd = im_ctr(im)
% Determine the centroid of an image 
% -------------------------
% INPUTS
%  im: [nxmxp array] Electrode without CBD
% OUTPUTS
%  centroid: [1x3 array] centroid
% -------------------------
	a = 0 ; 
	b = 0 ;
	c = 0 ;
	d = 0 ;
	dim = size(im); 
	for i = 1 : dim(1)
		for j = 1 : dim(2)
			for k = 1 : dim(3)
				a = a + im(i,j,k) ;
				b = b + im(i,j,k)*i ;
				c = c + im(i,j,k)*j ;
				d = d + im(i,j,k)*k ;
            end
        end
    end
	a = a ; 
	b = b ;
	c = c  ;
	d = d  ;
    ctrd = [b/a,c/a,d/a] ; 
end
