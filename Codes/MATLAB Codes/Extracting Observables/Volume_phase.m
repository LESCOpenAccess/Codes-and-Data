function Volume = Volume_phase(node,elem,phase)
% -------------------------
% Developed by Dr Mehdi Chouchane under the supervision of Pr Y. Shirley Meng
% University of Chicago, 2023
% Please cite the following article:
% 'Improved rate capability for dry thick electodes through finite elements
% method and machine learning coupling', M.Chouchane et al. (2024)
position = find(elem(:,5)==phase);
AB = node(elem(position,1),:) - node(elem(position,4),:) ; 
BC = node(elem(position,2),:) - node(elem(position,4),:) ; 
AC = node(elem(position,3),:) - node(elem(position,4),:) ; 
Volume = 0 ; 
for i = 1 : length(position)
    Volume = Volume + abs((1/6) * det([AB(i,:); BC(i,:); AC(i,:)])) ;
end
end
