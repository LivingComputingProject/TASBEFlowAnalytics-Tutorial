% This file shows how to perform a batch of +/- comparisons
TASBEConfig.checkpoint(TASBEConfig.checkpoints());

% load the color model
load('../template_colormodel/CM120312.mat');

% set up metadata
experimentName = 'LacI Transfer Curve';
device_name = 'LacI-CAGop';
inducer_name = '100xDox';

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

% Make a map of the batches comparisons to test, add in a list of batch
% names (e.g., {'+', '-'}) to signify possible sets.
% This analysis supports two variables: a +/- variable and a "tuning" variable
stem1011 = '../example_assay/LacI-CAGop_';
batch_description = {...
 {'Lows';'BaseDox';{'+', '-', 'control'};
  % First set is the matching "plus" conditions
  {0.1,  {[stem1011 'C3_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
   0.2,  {[stem1011 'C4_P3.fcs']}};
  {0.1,  {[stem1011 'B3_P3.fcs']};
   0.2,  {[stem1011 'B4_P3.fcs']}};
  {0.1,  {[stem1011 'B9_P3.fcs']}; 
   0.2,  {[stem1011 'B10_P3.fcs']}}};
 {'Highs';'BaseDox';{'+', '-'};
  {10,   {[stem1011 'C3_P3.fcs']};
   20,   {[stem1011 'C4_P3.fcs']}};
  {10,   {[stem1011 'B9_P3.fcs']};
   20,   {[stem1011 'B10_P3.fcs']}}};
 };

% Execute the actual analysis
TASBEConfig.set('OutputSettings.DeviceName',device_name);
results = process_plusminus_batch( CM, batch_description, AP);

% Make additional output plots
for i=1:numel(results)
    TASBEConfig.set('OutputSettings.StemName',batch_description{i}{1});
    TASBEConfig.set('OutputSettings.DeviceName',device_name);
    TASBEConfig.set('OutputSettings.PlotTickMarks',1);
    plot_plusminus_comparison(results{i}, batch_description{i}{3});
end

save('-V7','LacI-CAGop-plus-minus.mat','batch_description','AP','results');
