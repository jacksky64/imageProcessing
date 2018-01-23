figure(1); clf;
E = logspace(log10(0.001), log10(1), 500);  % define energy grid
material = 'Al';
material = 'Plexiglass';
mac  = PhotonAttenuation(material, E, 'mac'); 
loglog(E*1e3, mac); hold on;
legend({'mac'});
ylabel('Attenuation in cm^2/g');
xlabel('Photon Energy in KeV');
title({'Photon Attenuation Coefficients for Uranium',...
'see http://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z92.html'});


figure(2); clf;
E = logspace(log10(0.001), log10(1), 500);  % define energy grid
lac = PhotonAttenuation(material, E, 'lac');
loglog(E*1e3, lac); hold on;
legend({'lac'});
ylabel('Linear attenuation in 1/cm');
xlabel('Photon Energy in KeV');
title({'Photon Attenuation Coefficients for Uranium',...
'see http://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z92.html'});
