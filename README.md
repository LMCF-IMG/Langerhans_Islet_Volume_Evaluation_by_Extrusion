# Langerhans_Islet_Volume_Evaluation_by_Extrusion

**Macro for [ImageJ/Fiji](https://fiji.sc/).**

It was developed in cooperation with **Dr. David Habart** from the [Laboratory for Pancreatic Islets, Center for Experimental Medicine, Institute for Clinical and
Experimental Medicine (IKEM), Prague, Czech Republic](https://www.ikem.cz/en/centrum-exp-mediciny/oddeleni-centra/laborator-langerhansovych-ostruvku-lloe/a-1671/), who provided image data for testing and valuable feedback comments.

## Overview

The macro uses the technique of **"spherical extrusion"** to evaluate the volumes of Langerhans islets from their 2D microscopic image projections from a wide-field microscope, developed by [**Dr. Jiří Janáček**](https://github.com/jiri-janacek), [Laboratory of Advanced Microscopy and Data Analyses, Institute of Physiology of the Czech Academy of Sciences, Prague, Czech Republic](https://fgu.cas.cz/en/research-and-laboratories/service-departments/laboratory-of-advanced-microscopy-and-data-analyses/).

[**Spherical extrusion**](https://github.com/jiri-janacek/biomat) is an ImageJ/Fiji plugin that estimates the 3D volume of a shape from a single 2D picture (its silhouette): Think of your 2D object as a gentle “bump” made of spherical slices; the plugin figures out how tall that bump would be at every point inside the outline and then totals it up. In practice, it produces a height map (how “tall” the bump is across the object) and uses a simple rule of thumb to get volume: Volume ≈ 2 × (area of the 2D shape) × (mean height). It also shows a quick 3D reconstruction of the inferred object so you can visually check the result. This tool lives in ImageJ/Fiji under **Plugins → Biomat → Spherical Extrusion** and is meant for roughly roundish objects where that spherical “bump” assumption is reasonable.

## Macro: Islet_Volume_Extrusions_Dialog.ijm

Required plugins in Imagej/Fiji: [**Biomat**](https://github.com/jiri-janacek/biomat), [**MorphoLibJ**](https://imagej.net/plugins/morpholibj)

This is a small automated script that helps a user process microscope images without having to click through everything manually. It’s designed to **measure the 3D volume of pancreatic islets from 2D image data**. It’s a helper tool that lets a researcher take 2D microscope images of rounded biological structures and automatically estimate their 3D volumes, saving a lot of time compared to manual measurement.

Here’s what it does step by step:

1. **Asks the user for settings** – a dialog pops up so you can choose *Input and Output directories*, and set parameters such as *Pixel size [µm]*, *Which model to apply* (Vmod=standard model, Vext=model with extrusion), *Minimum islet size (diameter) [µm]* expected. PNG or TIF binary image files are expected as input, thought these can be in both in greyscale and RGB.
2. **Processes the image** – it prepares the image to isolate islets using 4-connectivity.
3. **Performs “extrusions”** – this means it takes the 2D shape and projects it into 3D, assuming the object is roughly spherical or symmetrical.
4. **Calculates volume and shape information** – it uses geometry to estimate how big (in 3D) the object would be.
5. **Shows results and saves them** – at the end, it outputs measurements (volumes, area) both in a table or as images.

**Evaluated parameters in the resulting table:**
Islet ID - the number of the islet in the resulting picture;
Islet Size [µm] -its diameter!;
Area [µm2];
Mean - mean intensity after spherical extrusion;
Vext [µm3], [nl], [IEQ] - islet volume evaluated using spherical extrusion in units and Islet Equivalent;
Vsphe [nl], [IEQ] - islet volume evaluated using a standard method in units and Islet Equivalent;

**Fig. 1:** A macro dialog window requiring input parameters.

<img width="707" height="199" alt="Macro_Dialog_Window" src="https://github.com/user-attachments/assets/8b3c5f0d-f9fb-4541-bc5d-e6bf306292c6" />

**Fig. 2:** Input binary image with islets (left); found, spherically extruded and evaluated islets (right).

<img width="941" height="403" alt="Example_Islets_Processing" src="https://github.com/user-attachments/assets/06d5d66e-2fa0-4db8-9cde-7be7ef4ebdac" />
