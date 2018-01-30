%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminaries: set up TASBE analytics package:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% example: addpath('~/Downloads/TASBEFlowAnalytics/');
addpath('your-path-to-analytics');
% turn off sanitized filename warnings:
warning('off','TASBE:SanitizeName');

colordata = '../example_controls/';
dosedata = '../example_assay/';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples of spectral overlap:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's look at some single-color positive controls:
% no significant spectral overlap
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',1,[0 0; 6 6],1);
% minor spectral overlap
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','PE-TxRed YG-A',1,[0 0; 6 6],1);
% significant spectral overlap
fcs_scatter([colordata '07-29-11_mkate_P3.fcs'],'PE-TxRed YG-A','FITC-A',1,[0 0; 6 6],1);
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','AmCyan-A',1,[0 0; 6 6],1);
% massive spectral overlap
fcs_scatter([colordata '07-29-11_EBFP2_P3.fcs'],'Pacific Blue-A','AmCyan-A',1,[0 0; 6 6],1);

% let's look at some of these without blending:
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','PE-TxRed YG-A',0,[0 0; 6 6],1);
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','AmCyan-A',0,[0 0; 6 6],1);
fcs_scatter([colordata '07-29-11_EBFP2_P3.fcs'],'Pacific Blue-A','AmCyan-A',0,[0 0; 6 6],1);
% notice that these are extremely tight compared to a two-color experiment:
fcs_scatter([colordata '2012-03-12_EBFP2_EYFP_P3.fcs'],'Pacific Blue-A','FITC-A',0,[0 0; 6 6],1);


% What does autofluorescence look like?
[raw hdr data] = fca_readfcs([colordata '07-29-11_blank_P3.fcs']);
% histogram of EBFP2:
figure; hist(data(:,10),100);
% with random blurring to damp quanization:
figure; hist(data(:,10)+(rand(size(data(:,10)))-0.5),100);
% Notice that the presence of negative values means that we are necessarily dealing with a combination
% of autofluorescence and instrument error.  There is not currently any elegant way of separating these.

% fit to a gaussian model:
mu = mean(data(:,10))
sigma = std(data(:,10))

% Notice that the fit is pretty good:
range = -100:5:150;
figure;
plot(range,histc(data(:,10),range),'b-'); hold on;
plot(range,numel(data(:,10))*5*normpdf(range,mu,sigma),'r--');


% we can simulate a distribution as a sum of three terms: random (bleed) signal, autofluorescence, and read error
% here are some arbitrary values to explore as an example:
n = 1e5; 
signal = 10.^(randn(n,1)*1+2.5);
autofluorescence = @(n)(10.^(randn(n,1)*0.2 + 0.5));
error = @(n)(randn(n,1)*30);

overlap = 0.001;
figure;
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);

overlap = 0.01;
figure;
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);

overlap = 0.1;
figure;
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compensation for spectral overlap:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To build compensation models, we need a negative (blank) control and 
% positive controls of single fluorophores
% Negative might be "wild-type" or transfected with blank
%   These can sometimes be very different!

beadfile = [colordata '2012-03-12_Beads_P3.fcs'];
blankfile = [colordata '2012-03-12_blank_P3.fcs'];

channels = {}; colorfiles = {};
channels{1} = Channel('Pacific Blue-A', 405,450,50);
channels{1} = setPrintName(channels{1},'Blue');
colorfiles{1} = [colordata '2012-03-12_ebfp2_P3.fcs'];
channels{2} = Channel('PE-Tx-Red-YG-A', 561,610,20);
channels{2} = setPrintName(channels{2},'Red');
colorfiles{2} = [colordata '2012-03-12_mkate_P3.fcs'];
channels{3} = Channel('FITC-A', 488,530,30);
channels{3} = setPrintName(channels{3},'Yellow');
colorfiles{3} = [colordata '2012-03-12_EYFP_P3.fcs'];

colorpairfiles = {};
CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);
CM = set_ERF_channel_name(CM, 'FITC-A'); % We'll explain this in the next exercise

% Now let's read some files...
raw = read_filtered_au(CM,[dosedata 'LacI-CAGop_C3_C03_P3.fcs']);
compensated = readfcs_compensated_au(CM,[dosedata 'LacI-CAGop_C3_C03_P3.fcs'],0,1);
% You should see an error: need to "resolve" the color model first!

CM = resolve(CM);

% Ignore the warnings about finding only one bead peak and translation and 
% mapping files: those have to do with ERF conversion, which we'll cover
% in our next exercise

% Resolving the colormodel just produced a whol lot of files: let's take a
% looks at the ones having to do with compensation.
%
% There is one "autofluorescence-C" graph for each channel.
% This model covers both true autofluorescence and sensor noise, and it
% built from the negative control.  These are fit against a gaussian
% model: the solid red line shows mean, and the dotted lines +/- 2 std.dev.
% Notice that there is a small scatter of more highly fluorescent data points.
% The autofluorescence model attempt to avoid being overly influenced by 
% these outliers by dropping the top and bottom 0.1% of data.
% Usually autofluorescence is insignificant, but in some cell lines it is strong.
%
% The "color-compensation-C-for-C" graphs show the color compensation model, computed
% as a linear transform, after subtraction of autofluorescence.
% The model is computed only from those subpopulations that are significantly
% above autofluorescence.
% 
% The linear factors plus autofluorescence make up an affine transform that
% compensates for spectral overlap.
%
% Finally, the "compensated-" graphs show the results of applying the
% compensation transform to the positive controls.  The black lines show
% the mean for each decile of the population.  They should be near zero 
% (no more than ~20 a.u. away is a good rule of thumb) and not show a 
% significant trend up or down.  The range of variation should be even on both
% sides of zero, and likely will grow significantly toward the upper end.
% This is because some portion of the noise is multiplicative, but correction
% is subtracting, not dividing.  This spread of noise is thus an inherent 
% limitation of the assay, and one of the reasons to avoid high overlap,
% even when it can be compensated for.


compensated = readfcs_compensated_au(CM,[dosedata 'LacI-CAGop_C3_C03_P3.fcs'],0,1);
% The last two arguments are:
% 1) Whether to add autofluorescence back in after reading (generally not done)
% 2) Whether to map all values <= 0 to 1 (which is zero on the log scale)
%    We typically use this when data is going to be interpreted on the log scale,
%    and we aren't planning to filter it ourselves differently later,
%    but it has the unfortunate side effect of creating a large number of 1s

% Compare red vs. yellow in compensated and raw:
figure; loglog(compensated(:,2),compensated(:,3),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]); xlabel('PE-Tx-Red-YG a.u.'); ylabel('FITC a.u.'); title('Compensated');
figure; loglog(raw(:,10),raw(:,7),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]); xlabel('PE-Tx-Red-YG a.u.'); ylabel('FITC a.u.'); title('Raw');


% Note that the size of the effect changes based on the relative levels
% We thus cannot apply the same color model to data taken with the same colors
% with different settings or on different machines

% An important question for the future:
% We need to be able to set error bars on the data points that we correct.  Can we?
