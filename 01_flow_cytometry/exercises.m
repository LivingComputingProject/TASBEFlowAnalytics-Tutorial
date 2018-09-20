%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminaries: set up TASBE analytics package:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% example: addpath('~/Downloads/TASBEFlowAnalytics/');
addpath('/home/travis/build/TASBE/TASBEFlowAnalytics-Tutorial/TASBEFlowAnalytics/'); % input your-path-to-analytics
% turn off sanitized filename warnings:
warning('off','TASBE:SanitizeName');

colordata = '../example_controls/';
dosedata = '../example_assay/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples of flow data (Fig1 to Fig4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pure scatter - often hard to interpret
fcs_scatter([dosedata 'LacI-CAGop_C4_P3.fcs'],'PE-Tx-Red-YG-A','Pacific Blue-A',0,[0 0; 6 6],1); % Fig1
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',0,[0 0; 6 6],1); % Fig2
% smoothed density plot omits details but often summarizes collective better
data1 = fcs_scatter([dosedata 'LacI-CAGop_C4_P3.fcs'],'PE-Tx-Red-YG-A','Pacific Blue-A',1,[0 0; 6 6],1); % Fig3
data2 = fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',1,[0 0; 6 6],1); % Fig4

% Things to notice:
% - look at the size of data1 and data2: there's a *LOT* of points in these samples
% - because there is so much of it, pure scatter graphs are not sufficient for interpreting the data
% - the axes are logarithmic, and variation is evenly distributed on the log scale
% - the data runs up against the axes: values less than zero (sensor error) are not shown
% - low values are quantized, but not rounded
% - the very highest values saturate, at around 10^5.5 in these files
% - the populations of cells are complex, multimodal, and range widely in observed fluorescence


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What's in an FCS 3.0 file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rawdata hdr data] = fca_readfcs([colordata '07-29-11_EYFP_P3.fcs']);

hdr

% Things to notice:
% - Date and time stamp
% - 50K data points gathered in one minute
% - "par" contains all the information about channels
% - "timestep" says what the units of the time field are
% - Most other information is not very useful

{hdr.par(:).name}

% Things to notice:
% - High-dimensional data!
% - (H)eight, (W)idth, and (A)rea channels
% - FSC, SSC: Forward scatter and side scatter
% - Time

hdr.par(7)

% Things to notice:
% - saturation at 2^18
% - configurability of reported resolution: "decade", "log", "logzero"
%   This can cause real problems!
%   c.f. read_filtered_au early data exclusion

sum(data(:,7)<=0)
% How much FITC is less than zero?  Quite a bit!

data(data(:,7)>260000,7)
% ans = 262143
% How high was this really?  We cannot know because it is saturated!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making a ColorModel (Fig5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
channels = {};

channels{1} = Channel('Pacific Blue-A', 405, 450, 50);
channels{1} = setPrintName(channels{1}, 'EBFP2');
channels{1} = setLineSpec(channels{1}, 'b');
colorfiles{1} = [colordata '2012-03-12_' 'ebfp2_P3.fcs'];

channels{2} = Channel('PE-Texas Red-A', 561, 610, 20);
channels{2} = setPrintName(channels{2}, 'mKate');
channels{2} = setLineSpec(channels{2}, 'r');
colorfiles{2} = [colordata '2012-03-12_' 'mkate_P3.fcs'];

channels{3} = Channel('FITC-A', 488, 530, 30);
channels{3} = setPrintName(channels{3}, 'EYFP'); % Name to print on charts
channels{3} = setLineSpec(channels{3}, 'y'); % Color for lines, when needed
colorfiles{3} = [colordata '2012-03-12_' 'EYFP_P3.fcs']; % If there is only one channel, the color file is optional

CM = ColorModel('','',channels,colorfiles,{}); % simplified ColorModel, more features will be introduced in future tutorials

filtered = read_filtered_au(CM,[colordata '07-29-11_EYFP_P3.fcs']); % applies any filters set in ColorModel

CM = set_dequantization(CM,true); % dequantization adds noise to spread the data out more, especially useful at low levels
[dequantized hdr] = read_filtered_au(CM,[dosedata 'LacI-CAGop_C4_P3.fcs']);
xc = dequantized(:,10); yc = dequantized(:,11);
pos = xc>0 & yc>0;
figure; smoothhist2D(log10([xc(pos) yc(pos)]),10,[200, 200],[],'image',[0 0; 6 6]); % Fig5
% if desired, quantization can be smoothed out by introduction of small noise
