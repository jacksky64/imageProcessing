
function borders = srm_getborders(map)

dx = conv2(map, [-1 1], 'same');
dy = conv2(map, [-1 1]', 'same');
dy(end,:) = 0; % ignore the last row of dy
dx(:,end) = 0; % and the last col of dx
borders = find(dx ~= 0 | dy ~= 0);
