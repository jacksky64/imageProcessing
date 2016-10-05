function H = vl_tightsubplot(varargin)

ml = 0 ;
mr = 0 ;
mt = 0 ;
mb = 0 ;

use_outer=0 ;

% --------------------------------------------------------------------
%                                                      Parse arguments
% --------------------------------------------------------------------

K = varargin{1} ;
p = varargin{2} ;
N = ceil(sqrt(K)) ;
M = ceil(K/N) ;

a=3 ;
NA = length(varargin) ;
if NA > 2
  if isa(varargin{3},'char')
    % Called with K and p
  else
    % Called with M,N and p
    a = 4 ;
    M = K ;
    N = p ;
    p = varargin{3} ;
  end
end

for a=a:2:NA
  opt=lower(varargin{a}) ;
  arg=varargin{a+1} ;
  switch opt
    case 'margin'
      mt = arg ;
      mb = arg ;
      ml = arg ;
      mr = arg ;
    case 'marginleft'
      ml = arg ;      
    case 'marginright'
      mr = arg ;      
    case 'margintop'
      mt = arg ;      
    case 'marginbottom'
      mb = arg ;            
    case 'spacing'
      mt = arg/2 ;
      mb = arg/2 ;
      ml = arg/2 ;
      mr = arg/2 ;
    case 'box'      
      switch lower(arg)
        case 'inner'
          use_outer = 0 ;
        case 'outer'
          use_outer = 1 ;
        otherwise
          error(['Box is either ''inner'' or ''outer''']) ;
      end
    otherwise
      error(['Uknown parameter ''', varargin{a}, '''.']) ;
  end      
end

% --------------------------------------------------------------------
%                                                  Check the arguments
% --------------------------------------------------------------------

[j,i]=ind2sub([N M],p) ;
i=i-1 ;
j=j-1 ;

pos = [    j * 1/N       + ml,...
       1 - i * 1/M - 1/M + mb,...
       1/N - ml - mr, ...
       1/M - mt - mb] ;

switch use_outer
  case 0
    H = findobj(gcf, 'Type', 'axes', 'Position', pos) ;
    if(isempty(H))
      H = axes('Position', pos) ;
    else
      axes(H) ;
    end
    
  case 1
    H = findobj(gcf, 'Type', 'axes', 'OuterPosition', pos) ;
    if(isempty(H))
      H = axes('ActivePositionProperty', 'outerposition',...
               'OuterPosition', pos) ;
    else
      axes(H) ;
    end
end    
