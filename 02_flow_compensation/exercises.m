%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminaries: set up TASBE analytics package:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% example: addpath('~/Downloads/TASBEFlowAnalytics/');
addpath('../../TASBEFlowAnalytics/'); % input your-path-to-analytics
% turn off sanitized filename warnings:
warning('off','TASBE:SanitizeName');

colordata = '../example_controls/';
dosedata = '../example_assay/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples of spectral overlap (Fig1 to Fig15):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's look at some single-color positive controls:
% no significant spectral overlap
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',1,[0 0; 6 6],1); % Fig1
% minor spectral overlap
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','PE-TxRed YG-A',1,[0 0; 6 6],1); % Fig2
% significant spectral overlap
fcs_scatter([colordata '07-29-11_mkate_P3.fcs'],'PE-TxRed YG-A','FITC-A',1,[0 0; 6 6],1); % Fig3
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','AmCyan-A',1,[0 0; 6 6],1); % Fig4
% massive spectral overlap
fcs_scatter([colordata '07-29-11_EBFP2_P3.fcs'],'Pacific Blue-A','AmCyan-A',1,[0 0; 6 6],1); % Fig5

% let's look at some of these without blending (plot 'density' set to 0):
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','PE-TxRed YG-A',0,[0 0; 6 6],1); % Fig6
fcs_scatter([colordata '07-29-11_EYFP_P3.fcs'],'FITC-A','AmCyan-A',0,[0 0; 6 6],1); % Fig7
fcs_scatter([colordata '07-29-11_EBFP2_P3.fcs'],'Pacific Blue-A','AmCyan-A',0,[0 0; 6 6],1); % Fig8
% notice that these are extremely tight compared to a two-color experiment:
fcs_scatter([colordata '2012-03-12_EBFP2_EYFP_P3.fcs'],'Pacific Blue-A','FITC-A',0,[0 0; 6 6],1); % Fig9

% What does autofluorescence look like?
[raw hdr data] = fca_readfcs([colordata '07-29-11_blank_P3.fcs']);
% histogram of EBFP2:
figure; hist(data(:,10),100); % Fig10
% with random blurring to damp quantization:
figure; hist(data(:,10)+(rand(size(data(:,10)))-0.5),100); % Fig11
% Notice that the presence of negative values means that we are necessarily dealing with a combination
% of autofluorescence and instrument error.  There is not currently any elegant way of separating these.

% fit to a gaussian model:
mu = mean(data(:,10))
sigma = std(data(:,10))

% Notice that the fit to a gaussian is pretty good:
range = -100:5:150;
figure; % Fig12
plot(range,histc(data(:,10),range),'b-'); hold on; 
% plot(range,numel(data(:,10))*5*normpdf(range,mu,sigma),'r--'); 
% commented out for testing purposes, normpdf undefined in Octave

% we can simulate a distribution as a sum of three terms: random (bleed) signal, autofluorescence, and read error
% here are some arbitrary values to explore as an example:
n = 1e5; 
signal = 10.^(randn(n,1)*1+2.5);
autofluorescence = @(n)(10.^(randn(n,1)*0.2 + 0.5));
error = @(n)(randn(n,1)*30);

overlap = 0.001;
figure; % Fig13
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);

overlap = 0.01;
figure; % Fig14
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);

overlap = 0.1;
figure; % Fig15
loglog(signal + autofluorescence(n) + error(n),signal*overlap + autofluorescence(n) + error(n),'.','MarkerSize',1);
xlim([1e0 1e6]); ylim([1e0 1e6]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compensation for spectral overlap (Plots folder and Fig16 to Fig17):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To build compensation models, we need a negative (blank) control and 
% positive controls for a single fluorophore
% Negative controls might be "wild-type" (not transfected) or transfected with blank
% Note: These can sometimes be very different!

beadfile = [colordata '2012-03-12_Beads_P3.fcs'];
blankfile = [colordata '2012-03-12_blank_P3.fcs'];

% Create one channel / colorfile (positive control) pair for each color
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
CM=set_translation_plot(CM, true);
CM=set_noise_plot(CM, true);

TASBEConfig.set('beads.beadModel','SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
TASBEConfig.set('beads.beadBatch','Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot
% Can also set bead channel if, for some reason, you don't want to use fluorescein as standard
% This defaults to FITC as it is strongly recommended to use fluorescein standards.
% TASBEConfig.set('beadChannel','FITC');

CM = set_ERF_channel_name(CM, 'FITC-A'); % We'll explain this in the next exercise

% Now let's read some files...
raw = read_filtered_au(CM,[dosedata 'LacI-CAGop_C3_P3.fcs']);
% compensated = readfcs_compensated_au(CM,[dosedata 'LacI-CAGop_C3_P3.fcs'],0,1);
% You should see an error: need to "resolve" the color model first! Comment
% out above line of code and run again.

CM = resolve(CM); %resolve computes a ColorModel from all of the pointers that are set up in ColorModel.m

% Ignore the warnings about finding only one bead peak and translation and 
% mapping files (if received): those have to do with ERF conversion, which we'll cover
% in our next exercise

% Resolving the colormodel just produced a whole lot of files within a folder titled "plots": let's take a
% look at the ones having to do with compensation.

% There is one "autofluorescence-C" graph for each channel.
% This model covers both true autofluorescence and sensor noise, and it is
% built from the negative control. These are fit against a gaussian
% model: the solid red line shows mean, and the dotted lines +/- 2 std.dev.
% Notice that there is a small scatter of more highly fluorescent data points.
% The autofluorescence model attempts to avoid being overly influenced by 
% these outliers by dropping the top and bottom 0.1% of data.
% Usually autofluorescence is insignificant, but in some cell lines it is strong.

% The "color-compensation-C-for-C" graphs show the color compensation model, computed
% as a linear transform, after subtraction of autofluorescence.
% The model is computed only from those subpopulations that are significantly
% above autofluorescence.
% 
% The linear factors plus autofluorescence make up an affine transform that
% compensates for spectral overlap. It turns a measurement of fluorescence
% from the cell plus fluorescence from protein into just a measurement of
% fluorescence from protein.
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


compensated = readfcs_compensated_au(CM,[dosedata 'LacI-CAGop_C3_P3.fcs'],0,1);
% The last two arguments are:
% 1) Whether to add autofluorescence back in after reading (generally not done)
% 2) Whether to map all values <= 0 to 1 (which is zero on the log scale)
%    We typically use this when data is going to be interpreted on the log scale,
%    and we aren't planning to filter it ourselves differently later,
%    but it has the unfortunate side effect of creating a large number of
%    1s. We can also remove negative values before compensation by adding a gate that filters them out. 

% Compare red vs. yellow in compensated and raw:
figure; loglog(compensated(:,2),compensated(:,3),'.','MarkerSize',1); % Fig16
xlim([1e0 1e6]); ylim([1e0 1e6]); xlabel('PE-Tx-Red-YG a.u.'); ylabel('FITC a.u.'); title('Compensated');
figure; loglog(raw(:,10),raw(:,7),'.','MarkerSize',1); % Fig17
xlim([1e0 1e6]); ylim([1e0 1e6]); xlabel('PE-Tx-Red-YG a.u.'); ylabel('FITC a.u.'); title('Raw');


% Note that the size of the effect changes based on the relative levels
% We thus cannot apply the same color model to data taken with the same colors
% with different settings or on different machines.

% An important question for the future:
% Is it possible to set error bars on the data points that are corrected
% after compensation? 
