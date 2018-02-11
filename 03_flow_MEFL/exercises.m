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
% Calibration beads:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's look at an example of SpheroTech RCP-30-5A calibration beads:
fcs_scatter([colordata '2012-03-12_Beads_P3.fcs'],'Pacific Blue-A','PE-Tx-Red-YG-A',1,[0 0; 6 6],1);
% and without blending...
fcs_scatter([colordata '2012-03-12_Beads_P3.fcs'],'Pacific Blue-A','PE-Tx-Red-YG-A',0,[0 0; 6 6],1);
% Notice that there is a nice, nearly linear sequence of 5 peaks
% the last one is pretty blurry, as it comes down into autofluorescence
% There are actually 8 peaks here: the bottom one blends all 4 of the low peaks together
% Notice also that the peaks are spaced irregularly.
% This is intentional by the manufacturer, and allows us to know which peaks we are
% looking at.

% Mammalian cells are usually quite big, with lots of fluorophores, and 
% end up at the top of the scale, while bacteria are quite small and end up
% down near the bottom instead.

% Let's take a look at a different pair of channels:
fcs_scatter([colordata '2012-03-12_Beads_P3.fcs'],'PE-Tx-Red-YG-A','FITC-A',1,[0 0; 6 6],1);
fcs_scatter([colordata '2012-03-12_Beads_P3.fcs'],'PE-Tx-Red-YG-A','FITC-A',0,[0 0; 6 6],1);
% Notice that the relationship of the peaks is not linear any more.
% This is because the FITC peaks are much lower, and are blurring into autofluorescence
% Thus, we need to calibrate using only peaks far from autofluorescence.

% Each channel is calibrated to a separate standard fluorophore.  The units
% are ME[F]: Mean Equivalent [Fluorophore abbreviation].
% They are also generically called ERF (Equivalent Reference Fluorophore), 
% or MESF (Mean Equivalent Standard Fluorophore)
% which is problematic because it makes different units appear the same.
% We recommend standardizing on one: MEFL, from the FITC channel

% So, beads give us the ability to standardize any channel, but no converstion
% between the units of channels.  That is what we do with multi-color controls (next section)


% Let's build a model and look at peak calibration...
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
colorpairfiles{1} = {channels{1}, channels{3}, channels{2}, [colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs']};
colorpairfiles{2} = {channels{2}, channels{3}, channels{1}, [colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs']};
colorpairfiles{3} = {channels{2}, channels{1}, channels{3}, [colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs']};

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);
CM = set_ERF_channel_name(CM, 'FITC-A'); % Name the channel we'll use for ERF units
CM=set_dequantization(CM, 1); % important at low levels
CM=set_bead_min(CM, 1); % Don't consider beads less than this amount
% Things we'll talk about in the next section...
CM=set_translation_plot(CM, true); 
CM=set_translation_channel_min(CM,[2,2,2]);
% and build it!
CM = resolve(CM);

% Let's take a look at the "bead-calibration-C" graphs
% Each one is a 1D histogram, with automatic identification of the peaks (red lines)
% Notice that the highest peaks have more than 1000 events/bin.  This is good,
% because it means we're not likely badly affected by random error.  When the numbers
% are low (e.g., a couple hundred), the data is often a total mess and hard to salvage.

% The FITC channel is the one that we will key off 
% The identification is pretty terrible, though!
% Two things are going wrong here:
% 1) We're getting smearing of peaks from autofluorescence: bead_min should be raised
% 2) Automatic threshold detection is not finding the right value, because there
%    is not a distinct enough "valley" in the FITC graph
% Notice also that you got a warning that: "Warning: Bead calibration probably incorrect"
% When peaks are mis-detected, this typically leads to a bad fit against the
% expected sequence gaps, giving warning of failures.

CM=set_bead_min(CM, 2); % Don't consider beads less than this amount
CM=set_bead_peak_threshold(CM, 200); % override default peak threshold
CM = resolve(CM);

% We get a new warning: "Warning: Only one bead peak found, assuming brightest"
% This is because the FITC channel is tuned for such bright fluorescence
% that we only get the top peak.  Look to verify that's really what's
% happening, but it usually is.

% Looking at the other channels, we still have some spurious peaks.
% Those don't matter, because we will only use FITC in the end.
% The "sub-peaks" slightly higher in a.u. than the main peaks are likely
% due to beads clumping together.

% Room for improvement:
% We could detect peaks better and more precisely if we used multi-dimensional
% gaussian fitting rather than 1D histograms.  This would be particularly
% useful for when some channels have beads much closer to autofluorescence
% than others (e.g. FITC vs. PE-Tx-Red-YG-A)

% Some more notes:
% - We currently only support RCP-30-5A, but others could presumably be supported
% - Does spectral overlap play a significant role in the measured values?  
%   Probably not (e.g. 10% shift vs. a 1000x range), but not certain...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Translation between channels:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% How do we measure red or blue in ERF?
% Note that the different channels have wildly different calibrations!
% We need a conversion factor on our fluorophores, to answer questions
% of the form: "what if I had used yellow here instead of red?"

% For this, we need controls with 2-3 colors, one of which is the FITC color.
% They must be under control of identical promoters, and not joined together
% in a way that could affect their expression levels.

% We recommend 3 colors as best practices:
% Let's look at such a multi-color control file:
fcs_scatter([colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',1,[0 0; 6 6],1);
% and without blending...
fcs_scatter([colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs'],'FITC-A','Pacific Blue-A',0,[0 0; 6 6],1);
% Notice that it's only nicely linear for the higher levels, 
% and that it's much smearier than our compensation controls
% The first is what set_translation_channel_min is for

% The way we partition is controlled by the colorpairfiles configuration:
% colorpairfiles{1} = {channels{1}, channels{3}, channels{2}, [colordata '2012-03-12_mkate_EBFP2_EYFP_P3.fcs']};
% The first two are the colors to convert between, the third is the color to segment by.
% For a 3-color file, we segment into bins by the 3rd and compute means for the first two in each bin.
% If the third is identical to one of the first two, then we do a 'diagonal' 
% segmentation by the geometric mean of the 1st two values.

% To see the fits, let's look at the color-translation-C-to-C graphs
% The black stars are the means, the dots the standard deviations, and 
% the red line is the computed translation fit, which assumes a pure linear
% conversion with no offset (since these are computed with compensated a.u.)

% A weighted average then gives a linear fit, producing a matrix:
getScales(get_color_translation_model(CM))
% These will usually be fairly close to 1, but it depends on the strength of
% the fluorophores and how precisely they are matched

