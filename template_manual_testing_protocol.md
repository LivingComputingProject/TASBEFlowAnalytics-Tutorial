## Manual Testing Protocol for Excel Interface
For each test, run for both `batch_template.xlsm` and `batch_template_csv.xlsm`:
1. Update plate
  1. Clear a cell in one of the plate sheets
  2. Click update plate button
  3. Make sure cleared cell contains correct name
2. Update filename
  1. Clear one of the filenames in the `Samples` sheet
  2. Click update filename button
  3. Make sure cleared cell contains correct filename
3. Colormodel
  1. Click run button in `Calibration` sheet
  2. Make sure TASBESession clears
  3. Ensure "Color Model Created!" message appears without error
  4. Check that there are figures in the `Calibration Figures` sheet
4. Batch analysis without point cloud
  1. Make sure value is blank for `flow.outputPointCloud` row in `Optional Settings` sheet
  2. Click run button in `Samples` sheet
  3. Make sure TASBESession clears
  4. Ensure "Batch Analysis Completed!" message appears without error
  5. Check that the `Batch Results` and `Batch Figures` sheets are populated
5. Batch analysis with point cloud
  1. Make sure value is 1 for `flow.outputPointCloud` row in `Optional Settings` sheet
  2. Click run button in `Samples` sheet
  3. Make sure TASBESession clears
  4. Ensure "Batch Analysis Completed!" message appears without error
  5. Check that the `Batch Results` and `Batch Figures` sheets are populated
  6. Check that point cloud files are saved to specified location
6. Comparative analysis
  1. Click run button in `Comparative Analysis` sheet
  2. Make sure TASBESession clears
  3. Ensure "Plusminus Analysis Completed!" message appears without error
  4. Check that there are figures in the `Comparative Figures` sheet
7. Transfer curve analysis
  1. Click run button in `Transfer Curve Analysis` sheet
  2. Make sure TASBESession clears
  3. Ensure "Transfer Curve Analysis Completed!" message appears without error
  4. Check that there are figures in the `Transfer Curve Figures` sheet

**Open up issues if any errors occur.**
