function mt_printtime(t)

days = floor(t/86400);
rest = mod(t,86400);
hours = floor(rest/3600);
rest = mod(rest,3600);
mins = floor(rest/60);
sec = mod(rest,60);

if days>0,
    str = ['time : ' num2str(sec) 's ' num2str(mins) 'm ' ...
           num2str(hours) 'h ' num2str(days) 'd .\n'];
elseif hours>0,
    str = ['time : ' num2str(sec) 's ' num2str(mins) 'm .\n' ...
           num2str(hours) 'h .'];
elseif mins>0,
    str = ['time : ' num2str(sec) 's ' num2str(mins) 'm .\n'];
elseif sec>0,
    str = ['time : ' num2str(sec,'%4.2f') 's . \n'];
end
fprintf(str);

end

