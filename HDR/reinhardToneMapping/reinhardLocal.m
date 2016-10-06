% Implements the Reinhard local tonemapping operator
%
% parameters:
% hdr: high dynamic range radiance map, a matrix of size rows * columns * 3
% luminance map: the corresponding lumiance map of the hdr image
% 
%
%

function [ ldrPic, luminanceCompressed, v, v1Final, sm ] = reinhardLocal( hdr, saturation, eps, phi )

  
    fprintf('Computing luminance map\n');
    luminanceMap = makeLuminanceMap(hdr);

    alpha = 1 / (2*sqrt(2));
    key = 0.18;
    
    v1 = zeros(size(luminanceMap,1), size(luminanceMap,2), 8);
    v = zeros(size(luminanceMap,1), size(luminanceMap,2), 8);
  
    
    % compute nine gaussian filtered version of the hdr luminance map, such
    % that we can compute eight differences. Each image gets filtered by a
    % standard gaussian filter, each time with sigma 1.6 times higher than
    % the sigma of the predecessor.
    for scale=1:(8+1)
        
        %s = exp(sigma0 + ((scale) / range) * (sigma1 - sigma0)) * 8
        s = 1.6 ^ (scale-1);

        sigma = alpha * s;
        
        % dicretize gaussian filter to a fixed size kernel.
        % a radius of 2*sigma should keep the error low enough...
        kernelRadius = ceil(2*sigma);
        kernelSize = 2*kernelRadius+1;
        
        
        gaussKernelHorizontal = fspecial('gaussian', [kernelSize 1], sigma);
        v1(:,:,scale) = conv2(luminanceMap, gaussKernelHorizontal, 'same');
        gaussKernelVertical = fspecial('gaussian', [1 kernelSize], sigma);
        v1(:,:,scale) = conv2(v1(:,:,scale), gaussKernelVertical, 'same');
    end
    
    for i = 1:8    
        v(:,:,i) = abs((v1(:,:,i)) - v1(:,:,i+1)) ./ ((2^phi)*key / (s^2) + v1(:,:,i));    
    end
    
        
    sm = zeros(size(v,1), size(v,2));
    
    for i=1:size(v,1)
        for j=1:size(v,2)
            for scale=1:size(v,3)
                
                % choose the biggest possible neighbourhood where v(i,j,scale)
                % is still smaller than a certain epsilon.
                % Note that we need to choose that neighbourhood which is
                % as big as possible but all smaller neighbourhoods also
                % fulfill v(i,j,scale) < eps !!!
                if v(i,j,scale) > eps
                    
                    % if we already have a high contrast change in the
                    % first scale we can only use that one
                    if (scale == 1) 
                        sm(i,j) = 1;
                    end
                    
                    % if we have a contrast change bigger than epsilon, we
                    % know that in scale scale-1 the contrast change was
                    % smaller than epsilon and use that one
                    if (scale > 1)
                        sm(i,j) = scale-1;
                    end
                    
                    break;
                end
            end
        end
    end
    
    % all areas in the pic that have very small variations and therefore in
    % any scale no contrast change > epsilon will not have been found in
    % the loop above.
    % We manually need to assign them the biggest possible scale.
    idx = find(sm == 0);
    sm(idx) = 8;
    
    
    v1Final = zeros(size(v,1), size(v,2));

    % build the local luminance map with luminance values taken
    % from the neighbourhoods with appropriate scale
    for x=1:size(v1,1)
        for y=1:size(v1,2)
            v1Final(x,y) = v1(x,y,sm(x,y));
        end
    end
    
    
    % TODO: try local scaling with a/key as in the global operator.
    % But compute key for each chosen neighbourhood!
    %numPixels = size(hdr,1) * size(hdr,2);
    %delta = 0.0001;
    %key = exp((1/numPixels)*(sum(sum(log(v1Final + delta)))))
    %scaledLuminance = v1Final * (a/key);
    %luminanceCompressed = (luminanceMap* (a/key)) ./ (1 + scaledLuminance);
    
    
    % Do the actual tonemapping
    luminanceCompressed = luminanceMap ./ (1 + v1Final);

    % re-apply color according to Fattals paper "Gradient Domain High Dynamic
    % Range Compression"
   
   
        % (hdr(:,:,i) ./ luminance) MUST be between 0 an 1!!!!
        % ...but hdr often contains bigger values than luminance!!!???
        % so the resulting ldr pic needs to be clamped
        ldrPic = ((hdr ./ luminanceMap) .^ saturation) .* luminanceCompressed;

    % clamp ldrPic to 1
    indices = find(ldrPic > 1);
    ldrPic(indices) = 1;
   
    
    
    
    
    
    
    
    
    
    
    
    