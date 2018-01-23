%% Tutorial for PhotonAttenuation Package
% *By Jarek Tuszynski*
% (jaroslaw.w.tuszynski@leidos.com)
%
% Package PhotonAttenuation provides set of functions for modeling of 
% photons (x-ray, gamma-ray, etc.), passing through different materials. The
% tools are based on attenuation and energy absorption coefficients of
% photons in various materials. The tables of absorption coefficients were 
% copied from NIST[1][2] and embedded in the MATLAB code.
%
% Package consist of 4 functions:
%
% * *PhotonAttenuation* - the main function returning variuos physical
% quantaties for photons of various energies passing through different
% materials of different thickness
%
% * *PhotonAttenuationQ* - the helper function providing bare-bones access to
% NIST tables hardwired into the code. Simpler version of PhotonAttenuation 
% function with much fewer input and output options. Allow access to
% absorbtion edge tables.
%
% * *ParseChemicalFormula* - converts many different styles of names used for 
% elements, compounds and mixtures to uniform list of elements and their 
% weight ratios.
%
% * *PhysProps* - provides physical properties (like ratio of atomic number to 
% mass or density), needed by PhotonAttenuation function, for all elements 
% and some selected compounds. 
%
%% Input and output parameters of PhotonAttenuation function
%  Format:
%   X = PhotonAttenuation(Material, Energy, Options, Thickness)
%
%  Input :
% 1) Material - string, number or array of strings, numbers or cells 
%     describing material type. 
%     - Element atomic number Z - in 1 to 100 range
%     - Element symbols - 'Pb', 'Fe'
%     - Element names   - 'Lead', 'Iron', 'Cesium' or 'Caesium'
%     - Some common names and full compound names - 'Water', 'Polyethylene' 
%       (see function PhysProps for more details)
%     - Compound formulas - 'H2SO4', 'C3H7NO2'- those are case sensitive 
%     - Mixtures of any of above with fractions by weight - like
%       'H(0.057444)C(0.774589)O(0.167968)' for Bakelite or  
%       'B(10)H(11)C(58)O(21)' for Borated Polyethylene (BPE-10)
%     Note: For 'Options' other than 'mac' or 'meac', 'Material' has to be
%     recognized by 'PhysProps' function since densities are needed for
%     calculation.
% 2) Energy - Energy of the photons. Can be single energy or vector of 
%       energies. Several formats are allowed: 
%     - Energy in MeV, should be in [0.001, 20] MeV range. 
%     - Wavelengths in nano-meters. Encoded as negative numbers. The valid
%     range is 6.1982e-5 to 1.2396 nm;
%     - Continuous Spectrum - Encoded in 2 columns: column one contains 
%       energy in MeV and column two contains relative number of photons at that 
%       energy. Spectrum is assumed to be continuous and output is
%       calculated through integration using 'trapz' function.
% 3) Options - specifies what to return. String or number:
%     1 - 'mac' - function returns Mass Attenuation Coefficients in cm^2/g
%     2 - 'meac' - function returns Mass Energy-Absorption Coefficients 
%           in cm^2/g. See link below for more info:
%           http://physics.nist.gov/PhysRefData/XrayMassCoef/chap3.html
%     3 - 'cross section' or 'x' - function returns cross section in barns per
%          atom (convert to cm^2 per atom by multiplying by 10^-24). 
%          Available only for elements.
%     4 - 'mean free path' or 'mfp' - function returns mean free path (in cm) of 
%           photon in the given material . Available only for chemicals 
%           recognized by 'PhysProps' function (since density is needed).
%     5 - 'transmission' or 't' - fraction of protons absorbed by given thickness
%          of material
%     6 - 'ln_T' - log of transmission
%     7 - 'lac' - Linear Attenuation Coefficients in 1/cm same as 1/(Cross
%          Section) or mac*density.
%     8 - 'half value layer' or 'hvl' - function returns half-value layer (in cm) of 
%           photon in the given material.
%     9 - 'tenth value layer' or 'tvl' - analogous to 'hvl' . 
% 4) Thickness - Thickness of material in cm. Either scalar or vector of 
%      the same length as number of materials. Negative numbers indicate
%      mass thickness measured in g/cm^2 (density*thickness). Needed only
%      if energy spectrum is used or in case of Options set to
%      'Transmission'.
% Output :
%   X  - output depends on 'Options' parameter. Columns always correspond
%        to the materials and rows correspond to energy. In case of spectrum
%        input only single row is returned.
% 
%% References
% [1] Tables are based on "X-Ray Attenuation and Absorption for Materials 
%     of Dosimetric Interest" (XAAMDI) database (NIST 5632 report): J. 
%     Hubbell and S.M. Seltzer, "Tables of X-Ray Mass Attenuation 
%     Coefficients and Mass Energy-Absorption Coefficients 1 keV to 20 MeV 
%     for Elements Z = 1 to 92 and 48 Additional Substances of Dosimetric 
%     Interest, "National Institute of Standards and Technology report 
%     NISTIR 5632 (1995). http://physics.nist.gov/PhysRefData/XrayMassCoef/cover.html
%
% [2] MAC values for elements 93 to 100 (Neptunium to Fermium) came from 
%     XCOM: Photon Cross Sections Database (NBSIR 87-3597): Those tables 
%     give photon's "total attenuation coefficients" for elements with 
%     atomic number (Z) smaller than 100. Photon energy range is from 0.001 
%     MeV to 100 GeV. http://physics.nist.gov/PhysRefData/Xcom/Text/XCOM.html
%
% [3] Element properties:  http://physics.nist.gov/PhysRefData/XrayMassCoef/tab1.html
%
% [4] Material properties: http://physics.nist.gov/cgi-bin/Star/compos.pl
%
%% History
% * Original code was written in 2006 by Jarek Tuszynski (SAIC) and
% published as package "PhotonAttenuation"
% (http://www.mathworks.com/matlabcentral/fileexchange/11442-photonattenuation)
% * Code was inspired by John Schweppe Mathematica code avaiable at http://library.wolfram.com/infocenter/MathSource/4267/
% * Aug  2006 - new version of the code was published as "PhotonAttenuation2"
% * Sep  2011 - minor corrections and changes to the tutorial script
% * July 2013 - minor corrections and changes to the tutorial script
% * Aug  2014 - minor correction to error handling
%
%% Licence
% The package is distributed under BSD License
close all
clear variables
format compact; % viewing preference
clear variables;
type('license.txt')
colormap(jet);

%% Plot Photon Attenuation Coefficients for Uranium
% Input and output parameters are very simple so PhotonAttenuationQ
% function can be used
% Compare with http://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z92.html
figure(1); clf;
E = logspace(log10(0.001), log10(20), 500);  % define energy grid
mac  = PhotonAttenuationQ(92, E, 'mac'); 
meac = PhotonAttenuationQ(92, E, 'meac');
loglog(E, mac); hold on;
loglog(E, meac, 'b-.');
legend({'mac', 'meac'});
ylabel('Attenuation in cm^2/g');
xlabel('Photon Energy in MeV');
title({'Photon Attenuation Coefficients for Uranium',...
'see http://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab/z92.html'});

%% Plot Photon Attenuation Coefficients, using different input styles
% Input and output parameters are more varied which can be handled by
% PhotonAttenuation function 
figure(1); clf;
E = logspace(log10(0.001), log10(20), 500);  % define energy grid
Z = {'Concrete', 'Air', 'B(10)H(11)C(58)O(21)', 100, 'Ag'};
mac  = PhotonAttenuation(Z, E, 'mac');
loglog(E, mac);
legend({'Concrete', 'Air', 'BPE-10', 'Fermium', 'Silver'});
ylabel('Attenuation in cm^2/g');
xlabel('Photon Energy in MeV');
title('Photon Attenuation Coefficients for different materials');

%% Plot Photon Mass Attenuation Coefficients and absorbtion edges
% Plot as a function of energy and atomic number of elements
% See http://physics.nist.gov/PhysRefData/XrayMassCoef/chap2.html for
% details
figure(1); clf;
Z = 1:100;  % elements with Z in 1-100 range 
E = logspace(log10(0.001), log10(20), 500);  % define energy grid
[mac, CEdge] = PhotonAttenuationQ(Z, E);
imagesc(log10(mac)); colorbar;
title('Log of Photon Mass Attenuation Coefficients (in cm^2/g) and absorbtion edges');
xlabel('Atomic Number of Elements');
ylabel('Energy in MeV');
zlabel('Attenuation in cm^2/g');
set(gca,'YTick',linspace(1, length(E), 10));
set(gca,'YTickLabel',1e-3*round(1e3*logspace(log10(0.001), log10(20), 10)))
hold on
ed = accumarray([CEdge(:,1),CEdge(:,2)],CEdge(:,3)); % get per element energies of 14 absorbtion edges 
ed = 500*(log(ed')-log(0.001))/(log(20)-log(0.001)); % convert energy to row numbers of the image
plot(ed ,'LineWidth',3);                             % plot absorbtion edges
L = {'K','L1','L2','L3','M1','M2','M3','M4','M5','N1','N2','N3','N4','N5'};
legend(L, 'Location', 'southwest'); % add legend
hold off;

%% Plot Log of Mass Energy-Absorption Coefficients
% Plot as a function of energy and atomic number of elements
% See http://physics.nist.gov/PhysRefData/XrayMassCoef/chap3.html for
% details
figure(1); clf;
Z = 1:92; % elements with Z in 1-92 range (Elements higher than 92 are not defined)
E = logspace(log10(0.001), log10(20), 500);  % define energy grid
meac = PhotonAttenuationQ(Z, E, 'meac');
imagesc(log10(meac)); colorbar;
title('Log of Photon Mass Energy-Absorption Coefficients in cm^2/g');
xlabel('Atomic Number of Elements');
ylabel('Energy in MeV');
set(gca,'YTick',linspace(1, length(E), 10));
set(gca,'YTickLabel',1e-3*round(1e3*logspace(log10(0.001), log10(20), 10)))

%% Plot mean free path of photons in different media
% Plot as function of energy and atomic number of media/element
figure(1); clf;
Z = 1:99; % elements with Z in 1-99 range (Fermium Z=100 was dropped since its density is not known)
E = -logspace(log10(6.198e-5), log10(1.2395), 500); % wavelength instead of energy
X = PhotonAttenuation(Z, E, 'mean free path');
imagesc(log10(X)); colorbar;
title({'Log of Mean-free-path of photons in different media (in cm)', ...
       '(Vertical bars are due to low density of gases)'});
xlabel('Atomic Number of Elements');
ylabel('Photon wavelength in nm');
set(gca,'YTick',linspace(1, length(E), 10));
set(gca,'YTickLabel',1e-4*round(1e4*logspace(log10(6.198e-5), log10(1.2395), 10)))

%% Plot Cross sections of elements for different energy photons 
figure(1); clf;
Z = 1:100; % elements with Z in 1-100 range
E = logspace(log10(0.001), log10(20), 500);  % define energy grid
X = PhotonAttenuation(Z, E, 'cross section');
imagesc(log10(X)); colorbar;
title({'Log of Cross sections of elements for different energy photons',...
       ' In barns/atom or in 10E-24 cm^2'});
xlabel('Atomic Number of Elements');
ylabel('Photon Energy in MeV');
set(gca,'YTick',linspace(1, length(E), 10));
set(gca,'YTickLabel',1e-3*round(1e3*logspace(log10(0.001), log10(20), 10)))

%% Hardening of Bremsstrahlung Spectum
% Spectra change differently as they pass through different materials
figure(1); clf; %Define 9 MeV Bremsstrahlung Spectrum
E=[0.05,0.0506,0.0664,0.0873,0.1147,0.1506,0.1979,0.2599,0.3414,0.4485,...
0.5891,0.7738,1.0165,1.3352,1.7539,2.3038,3.0262,3.9751,5.2215,6.8587,8,9]';
S=[1,3,6,23,90,175,280,365,400,415,392,374,358,326,281,223,175,119,81,44,20,1]'; 
T_Al = PhotonAttenuation('Aluminum', E, 'transmission', 5);
T_Pb = PhotonAttenuation('Lead'    , E, 'transmission', 1);
S_Al = repmat(S,1,25);
S_Pb = repmat(S,1,25);
for i=2:10
  S_Al(:,i) = S_Al(:,i-1).*T_Al;
  S_Pb(:,i) = S_Pb(:,i-1).*T_Pb;
end
subplot(2,1,1)
loglog(E,S_Al);
xlim([0.05, 9]);
ylim([1, 500]);
ylabel('Number of photons');
title({'Hardening of Bremsstrahlung Spectum by Aluminum.'
       'Each line coresponds to 5 cm of Al'})
subplot(2,1,2)
loglog(E,S_Pb);
xlim([0.05, 9]);
ylim([1, 500]);
xlabel('Photon Energy in MeV');
ylabel('Number of photons');
title({'Hardening of Bremsstrahlung Spectum by Lead.'
       'Each line coresponds to 1 cm of lead'})

%% Dual x-ray ability to recognize different materials, using Mono-energetic energies and Flat Spectra.
% Notice that ratio of logs of transmitions for 10 MeV and 5 MeV photons 
% is depent on thickness of the material in case of flat spectras, but is
% independent of thickness in case of mono-energetic energies
E0 = 0.5;
EH = exp(log(E0):0.005:log(10)); % define spectrum range
EL = exp(log(E0):0.005:log(5));
EH = [EH; ones(1,length(EH))];   % define flat spectrum
EL = [EL; ones(1,length(EL))];
T  = logspace(0,log10(400),50);  % mass thickness in g/cm^2
Z  = 1:99;                       % elements with Z in 1-99 range
TL1 = zeros(length(T),length(Z));
TH1 = TL1; TL2 = TL1; TH2 = TL1;
for i = 1:length(T)
  TL1(i,:) = -log(PhotonAttenuation(Z,  5, 'Transmission', -T(i)));
  TH1(i,:) = -log(PhotonAttenuation(Z, 10, 'Transmission', -T(i)));
  TL2(i,:) = -log(PhotonAttenuation(Z, EL, 'Transmission', -T(i)));
  TH2(i,:) = -log(PhotonAttenuation(Z, EH, 'Transmission', -T(i)));
end

ratio1 = TH1./TL1;
ratio2 = TH2./TL2;
[~, i]=min(ratio1(:)); ratio2( 1 )=ratio1(i); % make sure ranges ... 
[~, i]=max(ratio1(:)); ratio2(end)=ratio1(i); % .. are the same
figure('Position',[1 1 800 600])
colormap(jet);

subplot(1,2,2); imagesc(ratio1'); colorbar;
title('Mono-energetic 5 & 10 MeV sources.');
ylabel('Atomic Number Z');
xlabel('Mass Thickness in g/cm^2');
t = 1:8:50;
set(gca,'XTick',t);
lab = cell (1,length(t));
for i = 1:length(t), lab{i} = num2str(round(T(t(i)))); end
set(gca,'XTickLabel',lab);

subplot(1,2,1); imagesc(ratio2'); %colorbar;
title('Flat spectra Min=0.5, Max=5 & 10 MeV.');
xlabel('Mass Thickness in g/cm^2');
set(gca,'XTick',t);
set(gca,'XTickLabel',lab);

%% Get properties of concrete 
% Show how to use PhysProps, ParseChemicalFormula & PhotonAttenuation 
% functions for accesing various physical properties of materials
X = PhysProps('Concrete');
Concrete.Density      = X{2}; % material density
Concrete.Composition  = X{3}; % element composition
Concrete.Z_A          = X{1}; % mean atomic number to atomic mass ratio
[Z, R] = ParseChemicalFormula(X{3});
MFP = PhotonAttenuation(X{3}, 0.662, 'mean free path');
Concrete.ElementZ     = Z';   % atomic numbers of elements
Concrete.ElementRatio = R';   % weight ratio of elements
Concrete.MeanFreePath = MFP;  % Mean Free Path of gammas from Cs-137 source
disp(Concrete)                % display the data

%% Get absorbtion Edge information for Lead
[~, AbsEdge] = PhotonAttenuationQ(82);
L = {'K','L1','L2','L3','M1','M2','M3','M4','M5','N1','N2','N3','N4','N5'};
for i=1:size(AbsEdge,1)
  fprintf('Edge %s: location: %6.3f keV, Mass Attenuation Coefficients: [%5.1f %5.1f] cm^2/g\n',...
    L{AbsEdge(i,1)}, AbsEdge(i,3)*1000, AbsEdge(i,4),AbsEdge(i,5));
end

%% Access Element Properties through PhysProps
P = PhysProps('Element Data');
display([{'Atomic Number', 'Element Symbol', 'Z/A'} ; num2cell((1:100)'), P]);

%% Access List of Compound names recognized by PhysProps, PhotonAttenuation and ParseChemicalFormula functions
P = PhysProps('Compound Names');
P = [{'Name', 'Alternative Name', 'Molecular Formula'} ; P(:,[2 1 3])];
idx = find( cellfun(@length, P(:,1)) < 20 );
display(P(idx,:)) % display only names shorter than 20 characters

%% Test ParseChemicalFormula 
% Run and make sure nothing crashes
ParseChemicalFormula('Pb');       % Element Symbol
ParseChemicalFormula('Lead');     % Element Name
ParseChemicalFormula('Water');    % Common name
ParseChemicalFormula('H2SO4');    % Molecular formula
ParseChemicalFormula('CO2(3)CO(5)'); % Mix of Molecular formulas
Bakelite = 'H(0.057444) C(0.774589) O(0.167968)';
ParseChemicalFormula(Bakelite);   % Mix of Elements using fractions
GafChromic = 'H(0.0897) C(0.6058) N2O3(0.3045)';  
ParseChemicalFormula(GafChromic); % Mix of Molecular formulas
BPE10 = 'B(10)H(11)C(58)O(21)';
ParseChemicalFormula(BPE10);      % Mix of Elements using ratios

%% Test consistency between stored and calculated Z/A values
P = PhysProps('All Data');
ZA = [P{:,1}]'; % extract ZA of all materials
za = zeros(size(ZA));
for i=1:(size(P,1)-1)
  [Z, R]  = ParseChemicalFormula(P{i,3});
  za(i) = dot(R,ZA(Z));
end
fprintf('Maximum discrepancy between calculated and stored <Z/A> = %f\n', max(abs(za-ZA)));