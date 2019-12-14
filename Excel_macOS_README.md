## TASBE Flow Analytics Excel Interface macOS User Guide
This user guide contains information on how to set up the Excel interface in macOS, so analyses can be run using buttons within the interface. Please open up issues [here](https://github.com/TASBE/TASBEFlowAnalytics-Tutorial/issues) if any difficulties arise while following this guide.

### Setting up AppleScriptTask
Many built-in VBA commands don't work in macOS. We can work around this problem by using AppleScript. Microsoft has an "AppleScriptTask" command that accesses and runs an AppleScript file located outside the sandboxed app, which means that we need to have a separate script file that is located in a specified location. You can set this up by executing the following steps

1. Download the `RunMatlab.scpt` file from [here](/RunMatlab.scpt)
2. Open a Finder Window and click **Go** in the Finder menu bar
3. Hold the **Alt** key and click **Library**
4. Click **Application Scripts** (if it doesn't exist, create this folder)
5. Click **com.microsoft.Excel** (if it doesn't exist, create this folder)
6. Copy `RunMatlab.scpt` to the **com.microsoft.Excel** folder

**Note:** You can add the **com.microsoft.Excel** folder to your Favorites in Finder with the shortcut: **cmd Ctrl T**.

### Running Analyses
Now, you are almost ready to use the run buttons in the interface. Just make sure that you have installed TASBE and are not just running it from the directory. It is important to note that **cancel buttons don't work in macOS**. Lastly, whenever Excel needs to access a particular file or folder, a dialog box will pop up and you will have to manually press the **Grant Access** button. An example of the dialog box is displayed below.

![grant access dialog box](/grant_access.png)

**Note:** Sometimes, Excel could crash depending on what sorts of tasks you do while the session log is updating. More features will be created in the future to combat this problem.   
