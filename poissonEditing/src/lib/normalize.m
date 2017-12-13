function I = normalize(Iin,range)
maxx = max(Iin(:));
minn = min(Iin(:));

I = (Iin - minn)/(maxx-minn);          % I in [0 1]
I = I*(range(2)-range(1)) + range(1);  % I in [range(1) range(2)]
end

