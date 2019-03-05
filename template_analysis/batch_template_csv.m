% This template shows how to perform a simple batch analysis of a set of conditions
% Each color is analyzed independently
TASBEConfig.checkpoint(TASBEConfig.checkpoints());

% load the color model
load('../template_colormodel/CM120312.mat');
% can also add filters, such as gating out all "low transfection" red less than 10^6 MEFL:
%CM = add_postfilter(CM,RangeFilter('PE-Tx-Red-YG-A',[1e6 inf]));


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
stem1011 = 'csv/LacI-CAGop_Dox';
root1011 = '_PointCloud.csv';
file_pairs = {...
  'Dox 0.1',    {[stem1011 '01' root1011]}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  'Dox 0.2',    {[stem1011 '02' root1011]};
  'Dox 0.5',    {[stem1011 '05' root1011]};
  'Dox 1.0',    {[stem1011 '1' root1011]};
  'Dox 2.0',    {[stem1011 '2' root1011]};
  'Dox 5.0',    {[stem1011 '5' root1011]};
  'Dox 10.0',   {[stem1011 '10' root1011]};
  'Dox 20.0',   {[stem1011 '20' root1011]};
  'Dox 50.0',   {[stem1011 '50' root1011]};
  'Dox 100.0',  {[stem1011 '100' root1011]};
  'Dox 200.0',  {[stem1011 '200' root1011]};
  'Dox 500.0',  {[stem1011 '500' root1011]};
  'Dox 1000.0', {[stem1011 '1000' root1011]};
  'Dox 2000.0', {[stem1011 '2000' root1011]};
  };

n_conditions = size(file_pairs,1);

% Execute the actual analysis
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
% Set CSVReaderHeader (temporary feature)
TASBEConfig.set('flow.defaultCSVReadHeader','csv/LacI-CAGop.json');
% Generate point cloud csv files
%TASBEConfig.set('flow.outputPointCloud', true);
[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'EYFP','mKate', 'EBFP2'},AP);

% Make output plots
plot_batch_histograms(results,sampleresults,CM); % linespecs obtained from CM
% can enter own linespecs for plot_batch_histograms:
% plot_batch_histograms(results,sampleresults,CM,{'b','g','r'});

[statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults);

save('LacI-CAGop-batch.mat','AP','bins','file_pairs','results','sampleresults');
