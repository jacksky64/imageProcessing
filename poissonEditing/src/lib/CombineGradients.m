
% ======================================================= %
% G = CombineGradients(G_Background, G_Object, Omega, Mode)
% ======================================================= %
function G = CombineGradients(G_Ba, G_Ob, Omega, Mode)
% Input,
%   - G_Ba: Struct that contains, G.x and G.y (HxWxC) images that
%            corresponds to the background partial derivative.
%   - G_Ob: Idem G_Ba but for the object we want to insert.
%   - Omega: (HxWxC) binary image defining the domain where the object
%            should be inserted. length(Omega==1) should be equal to the
%            length(Obj).
%   - Mode:
%       'Replace', (def) G_Ba outside O = Omega U d_Omega and G_Ob inside.
%       'Max'    , G_Ba outside O and max{G_Ob,G_Ba} inside.
%       'Average', G_Ba outside O and 1/2*(G_Ob+G_Ba) inside.
%       'Sum',     G_Ba outside O and G_Ob+G_Ba inside.
%
% Output,
%   - G: struct with the combination of the gradients.
%
% ------------------------------------------------------------ %
% Reference:
%   M. Di Martino, G. Facciolo and E. Meinhardt-Llopis.
%   "Poisson Image Image Editing", Image Processing On Line IPOL,
%   2015.
%
% ------------------------------------------------------------ %
% Other relevant refs:
% [Perez et al. 2003]
%   Pérez, P., Gangnet, M., & Blake, A. (2003).
%   Poisson image editing. ACM Transactions on Graphics, 22(3).
% [Morel et al. 2012]
%   Morel, J. M., Petro, a. B., & Sbert, C. (2012).
%   Fourier implementation of Poisson image editing.
%   Pattern Recognition Letters, 33(3), 342–348.
% ------------------------------------------------------------ %
% copyright (c) 2015,
% Matias Di Martino <matiasdm@fing.edu.uy>
% Gabriele Facciolo <facciolo@cmla.ens-cachan.fr>
% Enric Meinhardt   <enric.meinhardt@cmla.ens-cachan.fr>
%
% Licence: This code is released under the AGPL version 3.
% Please see file LICENSE.txt for details.
% ------------------------------------------------------------ %
% Comments and suggestions are welcome at: matiasdm@fing.edu.uy
% M. Di Martino, G. Facciolo and E. Meinhardt-Llopis
% Paris                                                 9/2015
% ============================================================ %

% We will modify the set O = Omega U d_Omega
O = padarray(Omega,[1 1],0,'both');
O = circshift(O,[1 0]) | circshift(O,[-1 0]) ...
  | circshift(O,[0 1]) | circshift(O,[0 -1]);
O = O(2:end-1,2:end-1,:);
% O is the set of pixels in Omega U d_Omega,

% init.
G             = G_Ba;

switch Mode,
    case 'Replace',
        G.x(O==1) = G_Ob.x(O==1);
        G.y(O==1) = G_Ob.y(O==1);
    case 'Average',
        G.x(O==1) = 1/2 * (G_Ob.x(O==1) + G_Ba.x(O==1) );
        G.y(O==1) = 1/2 * (G_Ob.y(O==1) + G_Ba.y(O==1) );
    case 'Sum'
        G.x(O==1) = G_Ob.x(O==1) + G_Ba.x(O==1);
        G.y(O==1) = G_Ob.y(O==1) + G_Ba.y(O==1);
    case 'Max',
        Mask_x = abs(G_Ba.x(O==1)) > abs(G_Ob.x(O==1));
        Mask_y = abs(G_Ba.y(O==1)) > abs(G_Ob.y(O==1));
        G.x(O==1) = G_Ba.x(O==1).*Mask_x +  G_Ob.x(O==1).*(1-Mask_x);
        G.y(O==1) = G_Ba.y(O==1).*Mask_y +  G_Ob.y(O==1).*(1-Mask_y);
    otherwise,
        error('[CombineGradients] Mode Unknown')
end % switch

end % function
