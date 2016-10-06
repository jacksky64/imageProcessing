function [ ldrLinear ] = linearTonemapping( hdr )

    luminanceMap = makeLuminanceMap(hdr);
    maximum = max(max(luminanceMap));
    luminanceMapLinear = luminanceMap / maximum;
    
    ldrLinear = applyColor(hdr, luminanceMapLinear, 0.5);
    
    
