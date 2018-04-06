% This template shows how to perform parametric analysis of a transient
% transfection transfer curve
TASBEConfig.checkpoint('init');

% load the color model
load('../template_colormodel/CM120312.mat');


% set up metadata
experimentName = 'LacI Transfer Curve';
device_name = 'LacI-CAGop';
inducer_name = 'Dox';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
input = channel_named(CM, 'EBFP2');
output = channel_named(CM, 'EYFP');
constitutive = channel_named(CM, 'mKate');
AP = AnalysisParameters(bins,{'input',input; 'output',output; 'constitutive' constitutive});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');
% By default, analysis tries to fit constitutive to transformed and non-transformed components
% If your distribution is more complex or less complex, you can change the number of components
% AP=setNumGaussianComponents(AP,3);

% Make a map of induction levels to file sets
stem1011 = '../example_assay/LacI-CAGop_';
level_file_pairs = {...
  0.1,    {[stem1011 'B3_B03_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  0.2,    {[stem1011 'B4_B04_P3.fcs']};
  0.5,    {[stem1011 'B5_B05_P3.fcs']};
  1.0,    {[stem1011 'B6_B06_P3.fcs']};
  2.0,    {[stem1011 'B7_B07_P3.fcs']};
  5.0,    {[stem1011 'B8_B08_P3.fcs']};
  10.0,   {[stem1011 'B9_B09_P3.fcs']};
  20.0,   {[stem1011 'B10_B10_P3.fcs']};
  50.0,   {[stem1011 'B11_B11_P3.fcs']};
  100.0,  {[stem1011 'B12_B12_P3.fcs']};
  200.0,  {[stem1011 'C1_C01_P3.fcs']};
  500.0,  {[stem1011 'C2_C02_P3.fcs']};
  1000.0, {[stem1011 'C3_C03_P3.fcs']};
  2000.0, {[stem1011 'C4_C04_P3.fcs']};
  };
experiment = Experiment(experimentName,{inducer_name}, level_file_pairs);

% Execute the actual analysis
fprintf('Starting analysis...\n');
[results, sampleresults] = process_transfer_curve( CM, experiment, AP);

% Make output plots
TASBEConfig.set('OutputSettings.StemName','Fine');

% Plot how the constitutive fluorescence was distributed
TASBEConfig.set('OutputSettings.DeviceName',device_name);
plot_bin_statistics(sampleresults);

% Plot the relation between inducer and input fluorescence
TASBEConfig.set('OutputSettings.DeviceName',inducer_name);
plot_inducer_characterization(results);

% Plot the relation between input and output fluorescence
TASBEConfig.set('OutputSettings.DeviceName',device_name);
plot_IO_characterization(results);

% Save the results of computation
save('-V7','LacI-CAGop-Fine.mat','experiment','AP','sampleresults','results');
