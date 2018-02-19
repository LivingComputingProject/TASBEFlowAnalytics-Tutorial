% This template shows how to perform a simple batch analysis of a set of conditions
% Each color is analyzed independently

% load the color model
load('../template_colormodel/CM120312.mat');

% set up metadata
experimentName = 'LacI Transfer Curve';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
AP = AnalysisParameters(bins,{});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');
% By default, analysis tries to fit constitutive to transformed and non-transformed components
% If your distribution is more complex or less complex, you can change the number of components
% AP=setNumGaussianComponents(AP,3);

% Make a map of condition names to file sets
stem1011 = '../example_assay/LacI-CAGop_';
file_pairs = {...
  'Dox 0.1',    {[stem1011 'B3_B03_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  'Dox 0.2',    {[stem1011 'B4_B04_P3.fcs']};
  'Dox 0.5',    {[stem1011 'B5_B05_P3.fcs']};
  'Dox 1.0',    {[stem1011 'B6_B06_P3.fcs']};
  'Dox 2.0',    {[stem1011 'B7_B07_P3.fcs']};
  'Dox 5.0',    {[stem1011 'B8_B08_P3.fcs']};
  'Dox 10.0',   {[stem1011 'B9_B09_P3.fcs']};
  'Dox 20.0',   {[stem1011 'B10_B10_P3.fcs']};
  'Dox 50.0',   {[stem1011 'B11_B11_P3.fcs']};
  'Dox 100.0',  {[stem1011 'B12_B12_P3.fcs']};
  'Dox 200.0',  {[stem1011 'C1_C01_P3.fcs']};
  'Dox 500.0',  {[stem1011 'C2_C02_P3.fcs']};
  'Dox 1000.0', {[stem1011 'C3_C03_P3.fcs']};
  'Dox 2000.0', {[stem1011 'C4_C04_P3.fcs']};
  };

n_conditions = size(file_pairs,1);

% Execute the actual analysis
[results sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'EBFP2','EYFP','mKate'},AP);

% Make output plots
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
plot_batch_histograms(results,sampleresults,{'b','y','r'},CM);

[statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults);

save('LacI-CAGop-batch.mat','AP','bins','file_pairs','results','sampleresults');
