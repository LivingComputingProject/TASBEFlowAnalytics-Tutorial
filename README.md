# TASBE Flow Analytics Tutorial
This is a tutorial for how to use the [TASBE Flow Analytics package](https://github.com/TASBE/TASBEFlowAnalytics).

Example code in this tutorial is distributed, insofar as possible, in
the public domain.

**If you make use of the TASBE Flow Analytics package, please cite
the following two publications:**

* Jacob Beal, "Bridging the Gap: A Roadmap to Breaking the Biological
  Design Barrier," Frontiers in Bioengineering and Biotechnology,
  2:87. doi:10.3389/fbioe.2014.00087, January 2015.

* Jacob Beal, Ron Weiss, Fusun Yaman, Noah Davidsohn, and Aaron Adler,
  "A Method for Fast, High- Precision Characterization of Synthetic
  Biology Devices," MIT CSAIL Tech Report 2012-008, April 2012. 
  http://hdl.handle.net/1721.1/69973
  
# Organization

The material in this tutorial is organized into three collections:

## Quick Start Templates

These are prototypical templates for using the TASBE Flow Analytics package.
Most common uses can be executed simply by copying these files, changing configuration commands to match your machine, and replacing the example FCS files it references with your own.

* template_colormodel: Use a set of controls to build a "color model", which TASBE Flow Analytics uses to gate and compensate data and to translate it into calibrated units.(This folder also contains a template that allows for beadfile comparisons.)
* template_analysis: Use a color model to analyze experimental data, for any experiment organized in one of several standard designs.

## Prototypical Example Data

The quick-start templates can be applied to prototypical example data to see how they work and get a feel for what good results look like:

* example_controls: flow cytometry files for building a color model
* example_assay: flow cytometry files from an experiment characterizing the input/output relationship of a repressor

Example flow cytometry files are provided courtesy of Prof. Ron Weiss (MIT).

## Educational Material on Flow Cytometry

This material is optional, and is intended to help the user understand better how calibrated flow cytometry works and why controls are organized the way they are in order to build color models.

* 01_flow_cytometry: How Flow Cytometry Works
* 02_flow_compensation: Autofluorescence and Compensation in Cells
* 03_flow_MEFL: From Arbitrary to Absolute Units
