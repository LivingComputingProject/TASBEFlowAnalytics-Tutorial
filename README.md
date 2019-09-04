# TASBE Flow Analytics Tutorial
[![Build Status](https://travis-ci.org/TASBE/TASBEFlowAnalytics-Tutorial.svg?branch=master)](https://travis-ci.org/TASBE/TASBEFlowAnalytics-Tutorial)

This is a tutorial for how to use the [TASBE Flow Analytics package](https://github.com/TASBE/TASBEFlowAnalytics). More information about the package can be found in the [TASBE project website](https://tasbe.github.io/).

Example code in this tutorial is distributed, insofar as possible, in
the public domain.

**If you make use of the TASBE Flow Analytics package, please cite
the following publication:**

* Jacob Beal, Cassandra Overney, Aaron Adler, Fusun Yaman, Lisa Tiberio, and Meher Samineni. "TASBE Flow Analytics: A Package for Calibrated Flow Cytometry Analysis," ACS Synthetic Biology, 8(7), pp 1524--1529, May 2019
  
## Organization

The material in this tutorial is organized into three collections:

### Quick Start Templates

These are prototypical templates for using the TASBE Flow Analytics package.
Most common uses can be executed simply by copying these files, changing configuration commands to match your machine, and replacing the example FCS files it references with your own.

* template_colormodel: Use a set of controls to build a "color model", which TASBE Flow Analytics uses to gate and compensate data and to translate it into calibrated units. (This folder also contains a template that allows for beadfile comparisons.)
* template_analysis: Use a color model to analyze experimental data, for any experiment organized in one of several standard designs.

### Prototypical Example Data

The quick-start templates can be applied to prototypical example data to see how they work and get a feel for what good results look like:

* example_controls: flow cytometry files for building a color model
* example_assay: flow cytometry files from an experiment characterizing the input/output relationship of a repressor

Example flow cytometry files are provided courtesy of Prof. Ron Weiss (MIT).

### Educational Material on Flow Cytometry

This material is optional, and is intended to help the user understand better how calibrated flow cytometry works and why controls are organized the way they are in order to build color models.

* 01_flow_cytometry: How Flow Cytometry Works
* 02_flow_compensation: Autofluorescence and Compensation in Cells
* 03_flow_MEFL: From Arbitrary to Absolute Units
