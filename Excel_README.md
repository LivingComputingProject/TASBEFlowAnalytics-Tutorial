# TASBEFlowAnalytics Excel Interface Instruction Guide

A new feature of the TASBEFlowAnalytics package is an Excel interface that provides a user-friendly interface between raw FCS data and current TASBE data analysis tools. Using a template spreadsheet, scientists can document important aspects of their experiments without having to worry about writing Matlab code. Currently, the template is organized into the following sheets: 
* "Experiment": includes all of the general experiment information and filename templates
* "Samples": includes important information regarding samples and batch analysis
* "Calibration": includes information to generate a Color Model
* "Comparative Analysis": includes information to run plusminus analysis
* "Transfer Curve Analysis": includes information to run transfer curve analysis
* "Optional Settings": TASBEConfig preferences that should not be changed unless absolutely necessary
* "96w, 48w, 24w": Plate layouts labeled with sample names used for better visualization

**Note**: All file paths are relative to the location of the spreadsheet template unless they are absolute paths.

## User Instructions
An example of the template is located at [TASBEFlowAnalytics-Tutorial](https://github.com/TASBE/TASBEFlowAnalytics-Tutorial) titled ```batch_template.xlsm```. This example spreadsheet uses the tutorial
FCS data. The code needed to run the template is in the newest release of [TASBEFlowAnalytics](https://github.com/TASBE/TASBEFlowAnalytics/releases). The following sections describe specific features for each template sheet. There are more notes highlighted in green throughout the spreadsheet.

### Experiment
* Filename templates are used to generate the correct FCS filenames without having to type all of them out. Each filename template is separated into numbered sections with some sections being static and some being variable. The variable sections must correspond to column names in "Samples". 
(i.e. A template of 1_2_3.fcs would have the numbers replaced with the three correct inputs.) **Make sure to update the blueprint of number placeholders right below the Filename Template header.**
* The conditions keys are used to make sure that the values for a certain column name in "Samples" is valid. The keys are used to obtain the sets for plusminus and transfer curve analysis. 

### Samples 
* The SAMPLE NAME column is necessary for the analysis and needs to be manually filled out.
* Information for each replicate should be in the same row with commas separating the values (i.e. sample locations for three replicates could look like A1, A2, A3). This feature is not applicable to the experimental condition columns.
* The "Click to Update Filenames" button serves to generate sample filenames using the filename templates. These filenames are used in the TASBE ```getExcelFilename``` function, so it is important to click the "Update Filenames" button before running any analysis.
* "Statistics Filename", "Statistics Filepath", "Point Cloud Filename", and "Point Cloud Filepath" are preferences for batch analysis. "Point Cloud Filename" takes in a filename template number instead of a string name since Point Cloud files are generated for multiple samples.
* The "Click to Update Plates" button fills out the plate layout sheets. Values for the plate layout column should consist of the plate sheet name followed by the plate name (i.e. 96w,Plate 1). It is also important for the SAMPLE LOCATION(s) column to be updated since it is used to determine where to put the sample names. 

### Calibration
* Multiple bead files can be compared by listing out their sample names in the "Sample Name" cell within the "Rainbow Beads" section. (i.e. Beads,Beads2,Beads3). The "Bead Comparison Tolerance" determines how identical you want the bead files to be. The results of the comparisons will be included in the TASBESession log located at the bottom of the sheet. 
* The "Constitutive/Input/Output" cells within the "Fluorochromes" section are optional for batch analysis but required for plusminus and transfer curve analysis. If this feature will be used, exactly one channel must be marked as Constitutive. The minimum is 2 colors with the second color acting as both the input and output. (It only needs to be labeled as one of the two.) For 3 or more colors, all pairwise combinations between labeled inputs and outputs will be analyzed. Colors not labeled will be ignored. 
* The "Relevant Channels" cell within the "Color Translation" section determines which colors to consider when creating the Color Model. A value of "all" means all listed colors will be used. 

### Comparative Analysis
* "Comparison Group(s)" contains sample column name-value pairs that determine which samples in the "Samples" sheet are compared. The format is "Sample Column Name = Value". Multiple name-value pairs can be listed out to further specify the comparison groups (i.e.  ColName1 = Value1, ColName2 = Value2). Leave this section blank if all samples should be considered for analysis.
* "Comparisons" consist of the required primary comparison sets (i.e. +, -) and the secondary ordering inductions, which are optional. Both the primary and secondary sets are in the form of sample column names for a single plusminus analysis. 
* Multiple plusminus analysis can be run as long as the Comparison Groups are aligned with their respective Comparison values. Additional preferences including output filename and plot path are required to differentiate between different analyses. 
* The stem and device name cells were removed and replaced by automatically generated condition names in the format of "sample column name = value" for each Comparison Group.

### Transfer Curve Analysis
* "Comparison Group(s)" contains sample column name-value pairs that determine which samples in the "Samples" sheet are analyzed. Each pair should correspond to a value in "Comparisons". The format for Comparison Groups is "Sample Column Name = Value". Multiple name-value pairs can be listed out to further specify the comparison groups (i.e.  ColName1 = Value1, ColName2 = Value2). Leave this section blank if all samples should be considered for analysis.
* "Comparisons" consists of the sample column name with the transfer curve conditions. It is important for the values to be numerical. Additional preferences including stem name and plot path are required to differentiate between different analyses. 
* Device name cells were removed. The defaults for stem names are in the format of "column name = value" for each Comparison Group, or they are the experiment name.

### Optional Settings
* To change a preference, input the new value within the Value column.
* MEFL-converted point clouds can be obtained by setting the value of the "flow.outputPointCloud" preference to 1.
* Outputted Histogram and Statistic CSV files from batch analysis can be controlled with the "flow.outputHistogramFile" and "flow.outputStatisticsFile" preferences.  

### Next Steps
**Before running TASBEFlowAnalytics, make sure you have installed TASBE and are not just running it from the directory. Installation instructions are located in the TASBEFlowAnalytics [README](https://github.com/TASBE/TASBEFlowAnalytics/blob/develop/README.md).** 

After completing and saving the template spreadsheet, the actual analysis can be run in two ways:
1) Run the function ```analyzeFromExcel``` (located in the code directory of TASBEFlowAnalytics) from MATLAB
with the file path of the spreadsheet as the input and the type ('colormodel', 'batch', 'plusminus', or 'transfercurve'). ```analyzeFromExcel``` will then create a TemplateExtraction object and run the correct analysis. **Don't forget to click the "Update Filenames" button before running any analysis.**
2) Click the run buttons located in each sheet of the template. From there, ```analyzeFromExcel``` is automatically called with the correct inputs. The TASBESession log would then be outputted near the bottom of the relevant sheet in the form of a progress bar. The template contains some more detailed instructions to set up the buttons. There are also cancel buttons for each analysis. Cooperative multitasking is implemented to allow users to continue modifying the template while an analysis is running. **This feature currently only works with Windows.** 

**Note**: The code is based on the coordinates of several important variables. You can adjust those coordinates accordingly using the ```setExcelCoordinates``` function within the ```TemplateExtraction``` class. 
