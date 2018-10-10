TASBEConfig.checkpoint('init');

stem0312 = '../example_controls/2012-03-12_';


beadfile = [stem0312 'Beads_P3.fcs'];
blankfile = [stem0312 'blank_P3.fcs'];

% Autodetect gating with an N-dimensional gaussian-mixture-model
AGP = AutogateParameters();
% Adjust AGP values if needed.  The most common adjustments are below:
% These are the most common values to adjust:
% Match t
%AGP.channel_names = {'FSC-A','SSC-A','FSC-H','FSC-W','SSC-H','SSC-W'};
% Typically two components: one tight single-cell component, one diffuse 
% non-cell or clump component.  More complex distributions may need more.
%AGP.k_components = 2;
%AGP.selected_components = [1];
autogate = GMMGating(blankfile,AGP,'plots');

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
% Channel takes FCS channel name, laser frequency (nm), filter center (nm), filter width (nm)
% Do not duplicate laser/filter information, as this may cause analysis collisions
channels{1} = Channel('FITC-A', 488, 515, 20);
channels{1} = setPrintName(channels{1}, 'EYFP'); % Name to print on charts
channels{1} = setLineSpec(channels{1}, 'y'); % Color for lines, when needed
colorfiles{1} = [stem0312 'EYFP_P3.fcs']; % If there is only one channel, the color file is optional

channels{2} = Channel('PE-Tx-Red-YG-A', 561, 610, 20);
channels{2} = setPrintName(channels{2}, 'mKate');
channels{2} = setLineSpec(channels{2}, 'r');
colorfiles{2} = [stem0312 'mkate_P3.fcs'];

channels{3} = Channel('Pacific Blue-A', 405, 450, 50);
channels{3} = setPrintName(channels{3}, 'EBFP2');
channels{3} = setLineSpec(channels{3}, 'b');
colorfiles{3} = [stem0312 'ebfp2_P3.fcs'];

% FSC and SSC channels can be added to be read unprocessed to MEFL
channels{4} = Channel('FSC-A', 488, 488, 10);
channels{4} = setPrintName(channels{4}, 'FSC');
channels{4} = setLineSpec(channels{4}, 'k');
% If the name is FSC or SSC (or one of those with '-A', '-H', or '-W') it will automatically be unprocessed; otherwise, set it 
% channels{4} = setIsUnprocessed(channels{4}, true);


% Multi-color controls are used for converting other colors into ERF units
% Any channel without a control mapping it to ERF will be left in arbirary units.
colorpairfiles = {};
% Entries are: channel1, channel2, constitutive channel, filename
% This allows channel1 and channel2 to be converted into one another.
% If you only have two colors, you can set consitutive-channel to equal channel1 or channel2
colorpairfiles{1} = {channels{1}, channels{2}, channels{3}, [stem0312 'mkate_EBFP2_EYFP_P3.fcs']};
colorpairfiles{2} = {channels{1}, channels{3}, channels{2}, [stem0312 'mkate_EBFP2_EYFP_P3.fcs']};

% Size bead files are used for processing FSC-A units into uM equivalent diameter
% They are optional, and will not be used if size bead file is not set
% sizebeadfile = [];
sizebeadfile = '../example_controls/180614_PPS6K_A02.fcs';

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles, sizebeadfile);
CM=set_translation_plot(CM, true);
CM=set_noise_plot(CM, true);

TASBEConfig.set('beads.beadModel','SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
TASBEConfig.set('beads.beadBatch','Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot
% Can also set bead channel if, for some reason, you don't want to use fluorescein as standard
% This defaults to FITC as it is strongly recommended to use fluorescein standards.
% TASBEConfig.set('beadChannel','FITC');

% Ignore all bead data below 10^[rangeMin] as being too "smeared" with noise
TASBEConfig.set('beads.rangeMin', 2);
% The peak threshold determines the minumum count per bin for something to
% be considered part of a peak.  Set if automated threshold finds too many or few peaks
%TASBEConfig.set('beads.peakThreshold', 200);
CM=set_ERF_channel_name(CM, 'FITC-A');
% Ignore channel data for ith channel if below 10^[value(i)]
CM=set_translation_channel_min(CM,[2,2,2]);

% Configuration for size beads, if used
TASBEConfig.set('sizebeads.beadModel','SpheroTech PPS-6K'); % Entry from BeadCatalog.xls matching your beads
% Can also set bead channel or batch, if alternatives are available
% Ignore all size bead data below 10^[rangeMin] as being too "smeared" with noise
TASBEConfig.set('sizebeads.rangeMin', 2);
CM=set_uM_channel_name(CM, 'FSC-A');

% When dealing with very strong fluorescence, use secondary channel to segment
% TASBEConfig.set('beads.secondaryBeadChannel','PE-Tx-Red-YG-A');
CM = add_prefilter(CM,autogate);

% Execute and save the model
CM=resolve(CM);
save('-V7','CM120312.mat','CM');
