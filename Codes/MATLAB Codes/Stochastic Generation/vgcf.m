function im_out = vgcf(im,id,N,L_max,it)
% Add fibers to an existing im
% -------------------------
% INPUTS
%  im: [nxmxp array] Image of the electrode
%  id: [double] Value attributed to the fibers in im_out
%  N: [double] Maximal pixel length of the fiber
%  it: [double] Controls the thickness of the fibers
% OUTPUTS
%  im_out: [nxmxp array] Image of the electrode with fibers
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
im_out = im ;
S = size(im) ;
indpore = find(im == 0) ;
n = 0 ;
mat_orientation = [-1 +1 +1
    0 +1 1
    +1 +1 +1
    +1 0 +1
    +1 -1 +1
    0 -1 +1
    -1 -1 +1
    -1 0 +1
    -1 +1 0
    0 +1 0
    +1 +1 0
    +1 0 0
    +1 -1 0
    0 -1 0
    -1 -1 0
    -1 0 0
    -1 +1 -1
    0 +1 -1
    +1 +1 -1
    +1 0 -1
    +1 -1 -1
    0 -1 -1
    -1 -1 -1
    -1 0 -1
    0 0 +1
    0 0 -1] ;
while n<N
    list = zeros(L_max,1) ;
    c_list = 1 ;
    L = 1 ;
    start = indpore(randi(length(indpore))) ;
    list(c_list) = start ;
    c_list = c_list + 1 ;
    im_out(start) = id ;
    [startx,starty,startz] = ind2sub(S,start);
    start = [startx,starty,startz] ;
    randi_orientation = randi(26) ;
    orientation = mat_orientation(randi_orientation,:) ;
    while L<L_max
        start = start + orientation ;
        if sum(start > S) == 0 && sum(start==0) == 0
            im_out(start(1),start(2),start(3)) = im(start(1),start(2),start(3)) ;
            if im_out(start(1),start(2),start(3)) == 0
                im_out(start(1),start(2),start(3)) = id ;
                list(c_list) = sub2ind(S,start(1),start(2),start(3)) ;
                c_list = c_list + 1 ;
                a = sub2ind(S,start(1),start(2),start(3)) ;
                for i = 1 : it
                    neighbor_solid = findNeighboursMat26(a',S);
                    neighbor_solid = neighbor_solid(:,2) ;
                    neighbor_solid(im_out(neighbor_solid)~=0,:) = [] ;
                    neighbor_solid = unique(neighbor_solid) ;
                    startb = start + orientation ;
                    if         sum(startb > S) == 0 && sum(startb==0) == 0
                        neighbor_solid(neighbor_solid== sub2ind(S,startb(1),startb(2),startb(3)))=[] ;
                    end
                    im_out(neighbor_solid) = id ;
                    l = length(neighbor_solid) ;
                    list(c_list:c_list+l-1) = neighbor_solid ;
                    c_list = c_list + l ;
                    a = neighbor_solid ;
                end
            else
                neighbor_vgcf = findNeighboursMat26(sub2ind(S,start(1)-orientation(1),start(2)-orientation(2),start(3)-orientation(3)),S);
                neighbor_solid = findNeighboursMat26(sub2ind(S,start(1),start(2),start(3)),S);
                neighbor_solid(im_out(neighbor_solid(:,2))~=0,:) = [] ;
                neighbor_vgcf(im_out(neighbor_vgcf(:,2))~=0,:) = [] ;
                temp = neighbor_vgcf(ismember(neighbor_vgcf(:,2),neighbor_solid(:,2)),2) ;
                if isempty(temp)
                    break
                else
                    [x,y,z] = ind2sub(S,temp) ;
                    [~,pos_min] = min(sum(abs([x y z] - start),2)) ;
                    im_out(temp(pos_min)) = id ;
                    list(c_list) = pos_min ;
                    c_list = c_list + 1 ;
                    start = [x(pos_min) , y(pos_min), z(pos_min)] ;
                    a = temp(pos_min) ;
                    for i = 1 : it
                        neighbor_solid = findNeighboursMat26(a',S);
                        neighbor_solid = neighbor_solid(:,2) ;
                        neighbor_solid(im_out(neighbor_solid)~=0,:) = [] ;
                        neighbor_solid = unique(neighbor_solid) ;
                        startb = start + orientation ;
                        if         sum(startb > S) == 0 && sum(startb==0) == 0
                            neighbor_solid(neighbor_solid== sub2ind(S,startb(1),startb(2),startb(3)))=[] ;
                        end
                        im_out(neighbor_solid) = id ;
                        l = length(neighbor_solid) ;
                        list(c_list:c_list+l-1) = neighbor_solid ;
                        c_list = c_list + l ;
                        a = neighbor_solid ;
                    end

                end
            end
        else
            break
        end
        L = L + 1  ;
    end    
    list = list(list>0) ;
    n = n + length(list) ;
    indpore(ismember(list,indpore)) = [] ;
        n/N
end
