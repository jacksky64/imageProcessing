function dat = BodyMaterialCompositionFunc
%    function dat = BodyMaterialCompositionFunc
%    returns a struct with fields composition tables for some body materials
%    inputs:
%      none
%    outputs:
%      dat: a struct with fields
%         adipose
%         blood
%         bone_compact  
%         bone_cortical
%         brain
%         lung
%         muscle_skeletal
%         muscle_striated
%         skin
%         soft_tissue
%         water
%         summary
%      each field (except summary) is a 2 column matrix [atomic_number fraction_by_weight]
%         summary is a matrix with a row for each atomic number in the data and 
%              the columns the fraction by weight (0 if not present). First column is atomic numbers
%      the first row has -1 in 1st column and the density (gm/cm^3) in 2nd column
% from BodyMaterialComposition.m
% density is in first row,  atomic number -1 for first row
% from http://physics.nist.gov/cgi-bin/Star/compos.pl?matno=123
% REA 2/10-5/25/09

s = (1:31)'; % will hold summary data

d = [ ... % fat
-1	0.92   % -1=> density
1 	0.119477
6 	0.637240
7 	0.007970
8 	0.232333
11 	0.000500
12 	0.000020
15 	0.000160
16 	0.000730
17 	0.001190
19 	0.000320
20 	0.000020
26 	0.000020
30 	0.000020
];
dat.adipose = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [...
-1	1.06
1 	0.101866
6 	0.100020
7 	0.029640
8 	0.759414
11 	0.001850
12 	0.000040
14 	0.000030
15 	0.000350
16 	0.001850
17 	0.002780
19 	0.001630
20 	0.000060
26 	0.000460
30 	0.000010
];
dat.blood = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [ ...
-1	1.85
1 	0.063984
6 	0.278000
7 	0.027000
8 	0.410016
12 	0.002000
15 	0.070000
16 	0.002000
20 	0.147000
];
dat.bone_compact = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [ ...
-1	1.85
1 	0.047234
6 	0.144330
7 	0.041990
8 	0.446096
12 	0.002200
15 	0.104970
16 	0.003150
20 	0.209930
30 	0.000100
];
dat.bone_cortical = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [ ...
1 	0.110667
6 	0.125420
7 	0.013280
8 	0.737723
11 	0.001840
12 	0.000150
15 	0.003540
16 	0.001770
17 	0.002360
19 	0.003100
20 	0.000090
26 	0.000050
30 	0.000010
];
dat.brain = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [ ...
-1	1.05
1 	0.101278
6 	0.102310
7 	0.028650
8 	0.757072
11 	0.001840
12 	0.000730
15 	0.000800
16 	0.002250
17 	0.002660
19 	0.001940
20 	0.000090
26 	0.000370
30 	0.000010
];
dat.lung = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [ ...
-1	1.04
1 	0.100637
6 	0.107830
7 	0.027680
8 	0.754773
11 	0.000750
12 	0.000190
15 	0.001800
16 	0.002410
17 	0.000790
19 	0.003020
20 	0.000030
26 	0.000040
30 	0.000050
];
dat.muscle_skeletal = d;
s(d(2:end,1),end+1) = d(2:end,2);


d = [ ...
-1	1.04
1 	0.101997
6 	0.123000
7 	0.035000
8 	0.729003
11 	0.000800
12 	0.000200
15 	0.002000
16 	0.005000
19 	0.003000
];
dat.muscle_striated = d;
s(d(2:end,1),end+1) = d(2:end,2);


d = [ ...
-1	1.1
1 	0.100588
6 	0.228250
7 	0.046420
8 	0.619002
11 	0.000070
12 	0.000060
15 	0.000330
16 	0.001590
17 	0.002670
19 	0.000850
20 	0.000150
26 	0.000010
30 	0.000010
];
dat.skin = d;
s(d(2:end,1),end+1) = d(2:end,2);


d = [
-1	1.0
1 	0.104472
6 	0.232190
7 	0.024880
8 	0.630238
11 	0.001130
12 	0.000130
15 	0.001330
16 	0.001990
17 	0.001340
19 	0.001990
20 	0.000230
26 	0.000050
30 	0.000030
];
dat.soft_tissue = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [
-1	1.0
1 	0.1118944
8 	0.8881056
];
dat.water = d;
s(d(2:end,1),end+1) = d(2:end,2);

d = [
-1	1.0
1 	0.0002
8 	0.4143
15 	0.1853
20 	0.3984
];
dat.calcium_hydro = d;
s(d(2:end,1),end+1) = d(2:end,2);

dat.summary = s;










