# TASBE Flow Analytics Excel Wrapper Introduction

A new feature of the TASBE Flow Analytics package is an Excel wrapper that provides a user-friendly interface between raw FCS data and current TASBE data
analysis tools. Using a template spreadsheet, scientists can document important aspects of their experiments without having to worry about writing Matlab
code. Currently, the template is organized into 4 sheets: 
* "Exeriment": includes all of the general experiment information and filename templates
* "Cytometer": includes information to generate a Color Model
* "Samples": includes important information for batch analysis
* "Additional Settings": lists out all of the TASBEConfig preferences not already in the previous sheets

## User Instructions
An example of the template is located in the TASBEFlowAnalytics-Tutorial titled ```batch_template.xlsx```. This example spreadsheet uses the tutorial
FCS data. The following sections describe specific features for each template sheet. 

### Experiment
* The Data Directory Stem refers to the file path to access the FCS files.
* Filename templates are used to generate the correct FCS filenames without having to type all of them out. Each filename template is separated into numbered sections with some sections being static and some being variable. The variable sections must correspond to a specific column in "Samples". 
(i.e. A template of 1_2_3.fcs would have the numbers replaced with the three correct inputs.) 

### Cytometer 
* Contains many preferences needed to generate Color Models.
* The Translation Channel Min preference should be in the format of #,#,#. 

### Samples 
* The Dox column is used to find the blank, beads, and all files. 
* The Template # column determines which filename template table to reference.
* The Sample Name column is important for the samples in batch_analysis
* The File Name columns are used to override filenames from the filename template. (Currently replicates are not considered.)

### Additional Settings
* To change a preference, input the new value within the Value column.

### Next Steps
After completing and saving the template spreadsheet, run the function ```analyzeFromExcel``` (located in the code directory of TASBEFlowAnalytics)
with the file path of the spreadsheet as the input. ```analyzeFromExcel``` will then create an Excel object and Color Model and run a batch_analysis. 
(You can adjust the position of specific variables in the template using the ```setExcelCoordinates``` function within the ```Excel``` class.) 
