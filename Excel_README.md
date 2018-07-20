# TASBE Flow Analytics Excel Wrapper Instruction Guide

A new feature of the TASBE Flow Analytics package is an Excel wrapper that provides a user-friendly interface between raw FCS data and current TASBE data analysis tools. Using a template spreadsheet, scientists can document important aspects of their experiments without having to worry about writing Matlab code. Currently, the template is organized into 6 sheets: 
* "Experiment": includes all of the general experiment information and filename templates
* "Samples": includes important information regarding samples and batch analysis
* "Calibration": includes information to generate a Color Model
* "Comparative Analysis": includes information to run plusminus analysis
* "Transfer Curve Analysis": includes information to run transfer curve analysis
* "Optional Settings": TASBEConfig preferences that should not be changed unless absolutely necessary

## User Instructions
An example of the template is located in the TASBEFlowAnalytics-Tutorial titled ```batch_template.xlsm```. This example spreadsheet uses the tutorial
FCS data. The code needed to run the template is in the TASBEFlowAnalytics [coverney.excel](https://github.com/TASBE/TASBEFlowAnalytics/tree/coverney.excel) branch. The following sections describe specific features for each template sheet. There are more notes highlighted in green throughout the spreadsheet.

### Experiment
* Filename templates are used to generate the correct FCS filenames without having to type all of them out. Each filename template is separated into numbered sections with some sections being static and some being variable. The variable sections must correspond to column names in "Samples". 
(i.e. A template of 1_2_3.fcs would have the numbers replaced with the three correct inputs.) 
* The conditions keys are used to make sure that the values for a certain column name in "Samples" is valid. The keys are used to obtain the sets for plusminus analysis. 

### Samples 
* The Sample Name column is necessary for the analysis and needs to be manually filled out.
* Information for each replicate should be in the same row with commas separating the values (i.e. sample locations for three replicates could look like A1,A2,A3). This feature is not applicable to the experimental condition columns.

### Calibration
* Multiple bead files can be compared by listing out their sample names in the "Sample Name" cell within the "Rainbow Beads" section. (i.e. Beads,Beads2,Beads3). The "Bead Comparison Tolerance" determines how identical you want the bead files to be. The results of the comparisons will be included in the TASBESession located at the bottom of the sheet. 
* The "Constitutive/Input/Output" cells within the "Fluorochromes" section are optional for batch analysis but required for plusminus and transfer curve analysis. If this feature will be used, exactly one channel must be marked as Constitutive. The minimum is 2 colors with the second color acting as both the input and output. (It only needs to be labeled as one of the two.) For 3 or more colors, all pairwise combinations between labeled inputs and outputs will be analyzed. Colors not labeled will be ignored. 
* The "Relevant Channels" cell within the "Color Translation" section determines which colors to consider when creating the Color Model. A value of "all" means all listed colors will be used. 

### Comparative Analysis
* "Comparison Group(s)" contains sample column name-value pairs that determine which samples in the "Samples" sheet are compared.
* "Comparisons" consist of the required primary comparison sets (i.e. +,-) and the secondary ordering inductions, which are optional. Both the primary and secondary sets are in the form of sample column names for a single plusminus analysis. 
* Multiple plusminus analysis can be run as long as the Comparison Groups are aligned with their respective Comparison values. Additional preferences including stem name and plot path are required for each analysis. 

### Transfer Curve Analysis
* "Comparison Group(s)" contains sample column name-value pairs that determine which samples in the "Samples" sheet are analyzed. Each pair should correspond to a value in "Comparisons".
* "Comparisons" consists of the sample column name with the transfer curve conditions. It is important for the values to be numerical. Additional preferences including stem name and plot path are required for each analysis. 

### Optional Settings
* To change a preference, input the new value within the Value column.
* MEFL-converted point clouds can be obtained by setting the value of the "flow.outputPointCloud" preference to 1. 

### Next Steps
**Before running TASBEFlowAnalytics, make sure you have installed TASBE and are not just running it from the directory. Installation instructions are located in the TASBEFlowAnalytics [README](https://github.com/TASBE/TASBEFlowAnalytics/blob/develop/README.md).** 
After completing and saving the template spreadsheet, the actual analysis can be run in two ways:
1) Run the function ```analyzeFromExcel``` (located in the code directory of TASBEFlowAnalytics)
with the file path of the spreadsheet as the input and the type ('colormodel', 'batch', 'plusminus', or 'transfercurve'). ```analyzeFromExcel``` will then create a TemplateExtraction object and run the correct analysis.
2) Click the run buttons located in each sheet of the template. From there, ```analyzeFromExcel``` is automatically called with the correct inputs. The TASBESession log would then be outputted near the bottom of the relevant sheet. The template contains some more detailed instructions to set up the buttons. **This feature currently only works with Windows.** 

**Note**: The code is based on the coordinates of several important variables. You can adjust those coordinates accordingly using the ```setExcelCoordinates``` function within the ```TemplateExtraction``` class. 