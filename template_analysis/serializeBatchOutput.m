% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults, pathToOutputFiles)

    % Grab all the data in separate data structures. Then format for output
    % files.
    numConditions = size(file_pairs,1);
    histogramFile = [pathToOutputFiles '/histogramFile.csv'];
    
    channels = getChannels(CM);
    sampleIds = file_pairs(:,1);
    binCenters = get_bin_centers(getBins(AP));
    
    for i=1:numConditions
        binCounts{i} = sampleresults{i}{1}.BinCounts;
        geoMeans{i} = sampleresults{i}{1}.Means;
        geoStdDev{i} = sampleresults{i}{1}.StandardDevs;
    end
    
    % Formats and writes the output to the Statistics file.
    statisticsFile = writeStatisticsCsv(numConditions, channels, sampleIds, binCounts, geoMeans, geoStdDev, pathToOutputFiles);
    
    % Formats and writes the output to the Histogram file.
    histogramFile = writeHistogramCsv(numConditions, channels, sampleIds, binCounts, binCenters, pathToOutputFiles);
    
    % Write the data points to a file (without headers for now). This is 
    %  just a wrapper around readfcs_compensated_ERF. It returns
    % the data, but for now ignore it because I'm testing writing files.
    %fcsToCsvFlowConverterFileWriter(CM, filename, getUseAutoFluorescence(AP), floor);

end

