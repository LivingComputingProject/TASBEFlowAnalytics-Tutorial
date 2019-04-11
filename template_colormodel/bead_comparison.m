TASBEConfig.checkpoint('init');

stem0312 = '../example_controls/2012-03-12_';

beadfiles = {DataFile('fcs', [stem0312 'Beads_P3.fcs']), DataFile('fcs', [stem0312 'Beads_P3.fcs'])}; % Input beadfiles to compare into the beadfiles array

beadfile = beadfiles{1}; % A ColorModel will be built using the first beadfile
blankfile = '';

% Create one channel / colorfile pair for each color
channels = {}; 
colorfiles = {};
colorpairfiles = {};
% Channel takes FCS channel name, laser frequency (nm), filter center (nm), filter width (nm)
% Do not duplicate laser/filter information, as this may cause analysis collisions
channels{1} = Channel('FITC-A', 488, 515, 20);
channels{1} = setPrintName(channels{1}, 'EYFP'); % Name to print on charts
channels{1} = setLineSpec(channels{1}, 'y'); % Color for lines, when needed
colorfiles{1} = DataFile('fcs', [stem0312 'EYFP_P3.fcs']); % can't have empty colorfiles when doing bead comparisons

channels{2} = Channel('PE-Tx-Red-YG-A', 561, 610, 20);
channels{2} = setPrintName(channels{2}, 'mKate');
channels{2} = setLineSpec(channels{2}, 'r');
colorfiles{2} = DataFile('fcs', [stem0312 'mkate_P3.fcs']);

channels{3} = Channel('Pacific Blue-A', 405, 450, 50);
channels{3} = setPrintName(channels{3}, 'EBFP2');
channels{3} = setLineSpec(channels{3}, 'b');
colorfiles{3} = DataFile('fcs', [stem0312 'ebfp2_P3.fcs']);

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);

TASBEConfig.set('beads.plot', false);
TASBEConfig.set('beads.beadModel','SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
TASBEConfig.set('beads.beadBatch','Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot (does not need to be exact)
% Can also set bead channel if, for some reason, you don't want to use fluorescein as standard
% This defaults to FITC as it is strongly recommended to use fluorescein standards.
% TASBEConfig.set('beadChannel','FITC');

CM=set_ERF_channel_name(CM, 'FITC-A');
% Computes beads_to_ERF for the color model/ first beadfile in beadfiles
[UT, CM] = beads_to_ERF_model(CM,beadfile);
CM = set_unit_translation(CM, UT);

% Iterate through the rest of the beadfiles and determine whether they are
% identicial to the CM's beadfile. Change the CM's beadfile if you want to 
% modify the reference beadfile. 
tolerance = 0.5; % optional argument, default of 0.5
for i=2:numel(beadfiles)  
    [ok, ratios] = check_beads_identical(CM, beadfiles{i}, tolerance);
    fprintf('Ratios between peaks:');
    fprintf(' %.2f',ratios);
    fprintf('\n');
    % A warning is thrown if two beadfiles are not considered identical
    if ok
        fprintf('Bead file %i confirmed sufficiently identical\n',i);
    else
        warning('Beadfiles %bf1 and %bf2 are not identical to each other!', beadfile, beadfiles{i});
    end
end