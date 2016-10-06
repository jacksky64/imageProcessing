function w = weight(z, zmin, zmax)
    if z <= 0.5 * (zmin + zmax)
        w = ((z - zmin) + 1); % never let the weights be zero because that would influence the equation system!!!
    else
        w = ((zmax - z) + 1);
    end
    