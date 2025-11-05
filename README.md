# Langerhans_Islet_Volume_Evaluation_by_Extrusion

**Macro for [ImageJ/Fiji](https://fiji.sc/).**

It was developed in cooperation with **Dr. David Habart** from the [Laboratory for Pancreatic Islets, Center for Experimental Medicine, Institute for Clinical and
Experimental Medicine (IKEM), Prague, Czech Republic](https://www.ikem.cz/en/centrum-exp-mediciny/oddeleni-centra/laborator-langerhansovych-ostruvku-lloe/a-1671/), who provided image data for testing and valuable feedback comments.

## Overview

The macro uses the technique of **"spherical extrusion"** to evaluate the volumes of Langerhans islets from their 2D microscopic image projections from a wide-field microscope, developed by [**Dr. Jiří Janáček**](https://github.com/jiri-janacek), [Laboratory of advanced microscopy and data analyses, Institute of Physiology of the Czech Academy of Sciences, Prague, Czech Republic](https://fgu.cas.cz/en/research-and-laboratories/service-departments/laboratory-of-advanced-microscopy-and-data-analyses/).

[**Spherical extrusion**](https://github.com/jiri-janacek/biomat) is an ImageJ/Fiji plugin that estimates the 3D volume of a shape from a single 2D picture (its silhouette): Think of your 2D object as a gentle “bump” made of spherical slices; the plugin figures out how tall that bump would be at every point inside the outline and then totals it up. In practice, it produces a height map (how “tall” the bump is across the object) and uses a simple rule of thumb to get volume: Volume ≈ 2 × (area of the 2D shape) × (mean height). It also shows a quick 3D reconstruction of the inferred object so you can visually check the result. This tool lives in ImageJ/Fiji under **Plugins → Biomat → Spherical Extrusion** and is meant for roughly roundish objects where that spherical “bump” assumption is reasonable.
