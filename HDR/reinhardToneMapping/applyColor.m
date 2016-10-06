function [ ldrPic ] = applyColor( hdr, luminanceMapCompressed, saturation )

    luminanceMap = makeLuminanceMap(hdr);
    ldrPic = zeros(size(hdr));
    
    for i=1:3
        % (hdr(:,:,i) ./ luminance) MUST be between 0 an 1!!!!
        % ...but hdr often contains bigger values than luminance!!!???
        % so the resulting ldr pic needs to be clamped
        ldrPic(:,:,i) = ((hdr(:,:,i) ./ luminanceMap) .^ saturation) .* luminanceMapCompressed;
    end

    % clamp ldrPic to 1
    indices = find(ldrPic > 1);
    ldrPic(indices) = 1;

