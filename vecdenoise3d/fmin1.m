% Vector Field Denoising with DIV-CURL Regularization
% 
% Author: Pouya Dehghani Tafti <pouya.tafti@a3.epfl.ch>
%         Biomedical Imaging Group, EPFL, Lausanne
%         http://bigwww.epfl.ch/
% 
% Dates:  08 Feb. 2012 (current release)
%         ?? Feb. 2011 (this implementation)
% 
% References:
% 
% P. D. Tafti and M. Unser, On regularized reconstruction of vector fields,
% IEEE Trans. Image Process., vol. 20, no. 11, pp. 3163–78, 2011.
% 
% P. D. Tafti, R. Delgado-Gonzalo, A. F. Stalder, and M. Unser, Variational
% enhancement and denoising of flow field images, Proc. 8th IEEE Int. Symp.
% Biomed. Imaging (ISBI 2011), pp. 1061–4, Chicago, IL, 2011.

function [lmbest ctxt finished] = fmin1(obj,lmin,lmax,relerr,objerr,ctxt,singlestep)

if ~( exist('ctxt','var') && isfield(ctxt,'dirty') && isfield(ctxt,'ombest') && isfield(ctxt,'lmbest') && isfield(ctxt','l') )
    o      = zeros(4,4);
    dirty  = ones(4,4);
    ombest = inf;

%   l(1,:) = exp(linspace(log(lmin(1)),log(lmax(1)),4));
%   l(2,:) = exp(linspace(log(lmin(2)),log(lmax(2)),4));
    l(1,:) = linspace(lmin(1),lmax(1),4);
    l(2,:) = linspace(lmin(2),lmax(2),4);
else
    o      = ctxt.o;
    dirty  = ctxt.dirty;
    ombest = ctxt.ombest;
    lmbest = ctxt.lmbest;

    l      = ctxt.l;
end;

if ~exist('singlestep','var')
    singlestep = 0;
end;

finished = 0;
while true
    fprintf('.');

    o = evaldirty(obj,o,dirty,l);
    dirty = ones(4,4);

    [om imi] = min(o); [om imj] = min(om); imi=imi(imj);
    ogap = max(o(:))-min(o(:));
    fprintf('imi,imj: %1.0f,%1.0f\n',imi,imj);

    if om < ombest
        ombest = om
        lmbest = [l(1,imi) l(2,imj)]
    end;

    lmin(1) = l(1,max(imi-1,1));
    lmax(1) = l(1,min(imi+1,4));

    o(1,:)  = o(max(imi-1,1),:);
    o(4,:)  = o(min(imi+1,4),:);
    dirty(1,:) = dirty(1,:) - .5;
    dirty(4,:) = dirty(4,:) - .5;

    switch imi
    case {1,4}
        l(1,:) = linspace(lmin(1),lmax(1),4);
    case 2
        l(1,:) = [lmin(1) 0.618*lmin(1)+0.382*l(1,imi) l(1,imi) lmax(1)];
        o(3,:)     = o(imi,:);
        dirty(3,:) = dirty(3,:)-.5;
    case 3
        l(1,:) = [lmin(1) l(1,imi) 0.618*l(1,imi)+0.382*lmax(1) lmax(1)];
        o(2,:)     = o(imi,:);
        dirty(2,:) = dirty(2,:)-.5;
    end;


    lmin(2) = l(2,max(imj-1,1));
    lmax(2) = l(2,min(imj+1,4));

    o(:,1)  = o(:,max(imj-1,1));
    o(:,4)  = o(:,min(imj+1,4));
    dirty(:,1) = dirty(:,1) - .5;
    dirty(:,4) = dirty(:,4) - .5;

    switch imj
    case {1,4}
        l(2,:) = linspace(lmin(2),lmax(2),4);
    case 2
        l(2,:) = [lmin(2) 0.618*lmin(2)+0.382*l(2,imj) l(2,imj) lmax(2)];
        o(:,3)     = o(:,imj);
        dirty(:,3) = dirty(:,3)-.5;
    case 3
        l(2,:) = [lmin(2) l(2,imj) 0.618*l(2,imj)+0.382*lmax(2) lmax(2)];
        o(:,2)     = o(:,imj);
        dirty(:,2) = dirty(:,2)-.5;
    end;

    ogap
    if  ( ( log(abs(lmax(1))) - log(abs(lmin(1))) ) + ...
        ( log(abs(lmax(2))) - log(abs(lmin(2))) ) < 2*relerr ) && ...
        ( ogap < objerr )
        finished = 1;
        break;
    end;

    if singlestep
        break;
    end;
end;

ctxt.o      = o;
ctxt.dirty  = dirty;
ctxt.ombest = ombest;
ctxt.lmbest = lmbest;
ctxt.l      = l;


function o = evaldirty(obj,oin,d,l)

d
o = oin;
for i=1:size(d,1)
for j=1:size(d,2)
if  d(i,j) > 0
    fprintf('%1.0f,%1.0f ',i,j);
    o(i,j) = obj(l(1,i),l(2,j));
end;
end;
end;
o
