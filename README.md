# Langerhans_Islet_Volume_Evaluation_by_Extrusion

**Macro for [ImageJ/Fiji](https://fiji.sc/).**

This macro was developed in collaboration with **Dr. David Habart** from the [Laboratory for Pancreatic Islets, Center for Experimental Medicine, Institute for
Clinical and Experimental Medicine (IKEM), Prague, Czech Republic](https://www.ikem.cz/en/centrum-exp-mediciny/oddeleni-centra/laborator-langerhansovych-ostruvku-lloe/a-1671/), who initiated the request and provided image data for testing and feedback.

## Overview

The script offers two options for calculating the volume of 3D cell clusters, a specific and a generic approach. The volume of isolated pancreatic islets is calculated from their 2D projections in a dish, using an empirical model, Sphiracle, that combines spherical extrusion of the projection contours with size-dependent height adjustments specific to pancreatic islets from mouse, rat, and human. Alternatively, the script calculates the volume of spherical extrusion alone, which is potentially applicable to other 3D cell clusters. The ImageJ/Fiji spherical extrusion plugin used here, as well as the islet-specific height adjustment formula, were developed by [**Dr. Jiří Janáček**](https://github.com/jiri-janacek), [Laboratory of Advanced Microscopy and Data Analyses, Institute of Physiology of the Czech Academy of Sciences, Prague, Czech Republic](https://fgu.cas.cz/en/research-and-laboratories/service-departments/laboratory-of-advanced-microscopy-and-data-analyses/), in collaboration with **Dr. David Habart**. It is available [here](https://imagej.net/plugins/biomat#morphological-operations-with-quadratic-structuringfunction).

Spherical extrusion is constructed as a union of spheres entirely fitting within the object contour and with centers in the plane of the contour. Volume calculation assumes vertical symmetry of the extruded object (multiplication by 2). For pancreatic islets, the height of the spherically extruded contour must be reduced to account for size-dependent flattening, hence the Sphiracle model.

## Macro: Islet_Volume_Extrusions_Dialog.ijm

Required plugins in Imagej/Fiji: [**Biomat**](https://github.com/jiri-janacek/biomat), [**MorphoLibJ**](https://imagej.net/plugins/morpholibj)

The input of this small automated script is a segmented image of a batch of images comprising a single or multiple islets settled at the bottom of a dish in orientations guided by their 3D shapes and gravity. The output includes corresponding images displaying the contours and the top portion of grayscaleencoded extrusion heights, along with csv file with calculated volumes

Here’s what it does step by step:

1. **Asks the user for settings** – a dialog pops up so you can choose *Input and Output directories*, and set parameters such as *Pixel size [µm]*, *Which model to apply* (Vmod=standard model, Vext=model with extrusion), *Minimum islet size (diameter) [µm]* expected. PNG or TIF binary image files are expected as input, thought these can be in both in greyscale and RGB.
2. **Processes the image** – it prepares the image to isolate islets using 4-connectivity.
3. **Performs “extrusions”** – this means it takes the 2D shape and projects it into 3D, assuming the object is roughly spherical or symmetrical.
4. **Calculates volume and shape information** – it uses geometry to estimate how big (in 3D) the object would be.
5. **Shows results and saves them** – at the end, it outputs measurements (volumes, area) both in a table or as images.

**Evaluated parameters in the resulting table:**
* Islet ID - the number of the islet in the resulting picture;

* Islet Size [µm] - its diameter;

* Area [µm2];

* Mean - mean height after spherical extrusion ??;

* Vext [µm3], [nl], [IEQ] - islet volume evaluated using spherical extrusion in units and Islet Equivalent;

* Vsphe [nl], [IEQ] - islet volume evaluated using a standard method in units and Islet Equivalent;

**Fig. 1:** A macro dialog window requiring input parameters.

<img width="707" height="199" alt="Macro_Dialog_Window" src="https://github.com/user-attachments/assets/8b3c5f0d-f9fb-4541-bc5d-e6bf306292c6" />

**Fig. 2:** Input binary image with islets (left); Result with found, spherically extruded and evaluated islets (right).

<img width="941" height="403" alt="Example_Islets_Processing" src="https://github.com/user-attachments/assets/06d5d66e-2fa0-4db8-9cde-7be7ef4ebdac" />
