%lnExposures = log(exposures);
%data = zeros(256,9);
%for i=1:size(zRed,1)
%    for j=1:size(zRed,2)
%        data((zRed(i,j)+1), j) = lERed(i) + lnExposures(j);
%        
%    end
%end



%figure
%hold on
%plot(data(:,1), 's');
%plot(data(:,2), 's');
%plot(data(:,3), 's');
%plot(data(:,4), 's');
%plot(data(:,5), 's');
%plot(data(:,6), 's');
%plot(data(:,7), 's');
%%plot(data(:,8), 's');
%plot(data(:,9), 's');
%hold off





y = (0:255);
figure
hold on
subplot(2,2,1)
plot(gRed, y, 'r-');
xlabel('log Exposure X');
ylabel('Pixel Value Z');

subplot(2,2,2)
plot(gGreen, y, 'g-');
xlabel('log Exposure X');
ylabel('Pixel Value Z');

subplot(2,2,3)
plot(gBlue, y, 'b-');
xlabel('log Exposure X');
ylabel('Pixel Value Z');

subplot(2,2,4)
plot(gRed, y, 'r-', gGreen,y , 'g-', gBlue, y, 'b-');
xlabel('log Exposure X');
ylabel('Pixel Value Z');
hold off

figure
hold on
plot(gRed, y, 'r-', gGreen,y , 'g-', gBlue, y, 'b-');
xlabel('log Exposure X');
ylabel('Pixel Value Z');
hold off
