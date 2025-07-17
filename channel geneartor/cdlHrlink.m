clear all;close all; clc
format longG;
dataset_n = 100;
fc = 6e9;                             % carrier frequency (Hz)
bsPosition = [22.287092,114.140886]; % lat, lon
bsAntSize = [8 16];                    % number of RIS elements 512
bsArrayOrientation = [180 0].';       % azimuth (0 deg is East, 90 deg is North) and elevation (positive points upwards) in deg
ueAntSize = [8 8];                    % number of Rx antennas
ueArrayOrientation = [0 0].';      % azimuth (0 deg is East, 90 deg is North) and elevation (positive points upwards)  in deg
reflectionsOrder = 5;                 % number of reflections for ray tracing analysis (0 for LOS)
 
% Bandwidth configuration, required to set the channel sampling rate and for perfect channel estimation
SCS = 15; % subcarrier spacing
NRB = 52; % number of resource blocks, 10 MHz bandwidth

bsSite = txsite("Name","Base station", ...
    "Latitude",bsPosition(1),"Longitude",bsPosition(2),...
    "AntennaAngle",bsArrayOrientation(1:2),...
    "AntennaHeight",4,...  % in m
    "TransmitterFrequency",fc);

% 在 x 和 y 方向上生成均匀分布的采样点
uePosition = [22.286922,114.140850]; %intial point of UE location
x_samples = linspace(0, 1.78e-10, sqrt(dataset_n/2.61)); % x个采样点
y_samples = linspace(114.140850, 114.140385, 2.61*sqrt(dataset_n/2.61)); % y个采样点
[X,Y] = meshgrid(x_samples,y_samples);
X = (X + uePosition(1)); 
for i = 1:1:size(X,1)
 for j = 1:1:size(X,2)
    ueSite = rxsite("Name","UE", ...
    "Latitude",X(i),"Longitude",Y(j),...
    "AntennaHeight",1,... % in m
    "AntennaAngle",ueArrayOrientation(1:2));

pm = propagationModel("raytracing","Method","sbr","MaxNumReflections",reflectionsOrder);
rays = raytrace(bsSite,ueSite,pm,"Type","pathloss");


pathToAs = [rays{1}.PropagationDelay]-min([rays{1}.PropagationDelay]);  % Time of arrival of each ray (normalized to 0 sec)
avgPathGains  = -[rays{1}.PathLoss];                                    % Average path gains of each ray
pathAoDs = [rays{1}.AngleOfDeparture];                                  % AoD of each ray
pathAoAs = [rays{1}.AngleOfArrival];                                    % AoA of each ray
isLOS = any([rays{1}.LineOfSight]);                                     % Line of sight flag

channel = nrCDLChannel;
channel.DelayProfile = 'CDL-A';

c = physconst('LightSpeed');
lambda = c/fc;

% UE array (single panel)
ueArray = phased.NRRectangularPanelArray('Size',[ueAntSize(1:2) 1 1],'Spacing', [0.5*lambda*[1 1] 1 1]);
ueArray.ElementSet = {phased.IsotropicAntennaElement};   % isotropic antenna element
channel.ReceiveAntennaArray = ueArray;
channel.ReceiveArrayOrientation = [ueArrayOrientation(1); (-1)*ueArrayOrientation(2); 0];  % the (-1) converts elevation to downtilt

% Base station array (single panel)
bsArray = phased.NRRectangularPanelArray('Size',[bsAntSize(1:2) 1 1],'Spacing', [0.5*lambda*[1 1] 1 1]);
bsArray.ElementSet = {phased.NRAntennaElement('PolarizationAngle',-45) phased.NRAntennaElement('PolarizationAngle',45)}; % cross polarized elements
channel.TransmitAntennaArray = bsArray;
channel.TransmitArrayOrientation = [bsArrayOrientation(1); (-1)*bsArrayOrientation(2); 0];   % the (-1) converts elevation to downtilt

ofdmInfo = nrOFDMInfo(NRB,SCS);
channel.SampleRate = ofdmInfo.SampleRate;

channel.ChannelFiltering = false;
[pathGains,sampleTimes] = channel();
channelsize = size(pathGains);
HrLink(:,:,i,j) = squeeze(sum(squeeze(pathGains(1,:,:,:)),1))';
[i,j]
 end
end
HrLink = reshape(HrLink,[size(HrLink,1), size(HrLink,2),size(HrLink,3)*size(HrLink,4)]);
save('HrLink.mat', 'HrLink', '-v7.3');