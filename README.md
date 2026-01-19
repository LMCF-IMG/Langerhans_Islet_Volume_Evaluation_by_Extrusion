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

Automated process step by step:
1. **Dialog window pops up:** Input and Output directories; Pixel size [µm/px]; Minimum islet size [µm] (calculated automatically as the diameter of a cirle with same area as the projection area); model choice between Vmod (the Sphiracle model) and Vext (spherical extrusion). Both png and tiff formats, either greyscaleor RGB are acceptable.
2. **Individual islets are identified and numbered:** using 4-connectivity.
3. **Islet size is calculated:** from projection area defined by the contour.
4. **Contours are extruded:** either spherical extrusion alone (Vext) or with sizeadjusted height (Vmod).
5. **Volume is calculated:** vertical symmetry of islets is assumed.
6. **Results are displayed and saved:** graphical and tabular output.

**Table of results:**  
Pixel size [µm/px]  
Minimum islet size [µm/px]  
Image ID;  
Islet index: for each image counted from 1;  
Islet area [µm2]: defined by the detected contour;  
Mean: height of the extrusion, corresponds to grayscale;  
Volume by Vmod or Vext [µm3], [nl], [IEQ]: IEQ Islet Equivalent  
See [Ricordi C, et al: Acta Diabetol Lat. 27, 1990: 185–195](https://link.springer.com/article/10.1007/BF02581331);

**Fig. 1:** Dialog window.

<img width="707" height="199" alt="Macro_Dialog_Window" src="https://github.com/user-attachments/assets/8b3c5f0d-f9fb-4541-bc5d-e6bf306292c6" />

**Fig. 2:**  Input image (left); Output image, contours and extruded heights of the identified islets with (right).

<img width="941" height="403" alt="Example_Islets_Processing" src="https://github.com/user-attachments/assets/06d5d66e-2fa0-4db8-9cde-7be7ef4ebdac" />
