// @File(label = "Input directory with binary images of islets", style = "directory") dirIn
// @String(label = "Pixel size [µm]", value="0.843") pixelSizeStr
// @String(label = "Which model", choices = {"Vext", "Vmod"}) modelName
// @String(label = "Minimum islet size (diameter) [µm]", value="50.0") isletDiamStr
// @Boolean(label = "Fill interior voids", value = true) fillInteriorVoids
// @Boolean(label = "Save thresholded images", value = false) saveThresholdedImages
// @File(label = "Output directory for storing results", style = "directory") dirOut

saveSettings();

var ricordi_nL = 0;
var ricordi_IEQ = 0;

run("Set Measurements...", "area mean redirect=None decimal=6");
setOption("BlackBackground", true);
pixSizeNumber = parseFloat(pixelSizeStr);
isletDiamNumber = parseFloat(isletDiamStr);
areaIslet = PI * (isletDiamNumber/2.0) * (isletDiamNumber/2.0); // in µm2
circularityMin = 0.15;

interiorVoidsFilledText = "no";
if (fillInteriorVoids)
	interiorVoidsFilledText = "yes";

setBatchMode(true);
soubory = getFileList(dirIn);
Array.sort(soubory);

print("\\Clear");
if (modelName == "Vmod")
	print("Image,Pixel Size [µm/px],Minimum Islet Size [µm],Islet ID,Islet Size [µm],Area [µm2],Mean,Vmod [µm3],Vmod [nl],Vmod [IEQ],Vsphe [nl],Vsphe [IEQ],Vrico [nL],Vrico [IEQ],Interior voids filled");
else
	print("Image,Pixel Size [µm/px],Minimum Islet Size [µm],Islet ID,Islet Size [µm],Area [µm2],Mean,Vext [µm3],Vext [nl],Vext [IEQ],Vsphe [nl],Vsphe [IEQ],Vrico [nL],Vrico [IEQ],Interior voids filled");

for (ind = 0; ind < soubory.length; ind++) {
	fileNameLower = toLowerCase(soubory[ind]);
	if (endsWith(fileNameLower, ".png") || endsWith(fileNameLower, ".tif") || endsWith(fileNameLower, ".tiff")) {
		path = dirIn + File.separator + soubory[ind];
		open(path);
		doProcessingMorphoLibJ(soubory[ind]);
	}
}

selectWindow("Log");
if (modelName == "Vmod")
	path = dirOut + File.separator + "Volumes-Vmod.csv";
else
	path = dirOut + File.separator + "Volumes-Vext.csv";
saveAs("text", path);
run("Close");
close("*");

setBatchMode(false);
restoreSettings();

///////////////////////////////////////////////////////////////////////////////////////////
function doProcessingMorphoLibJ(filename) {
	// input: binary image
	setVoxelSize(pixSizeNumber, pixSizeNumber, 1.0, "um");
	title = filename;
	name = substring(title, 0, lastIndexOf(title,"."));

	run("8-bit");
	setThreshold(150, 255);
	run("Convert to Mask");
	rename("Mask");
	if (saveThresholdedImages) {
		thresholdedPath = dirOut + File.separator + name + "_thresholded.tif";
		saveAs("Tiff", thresholdedPath);
		rename("Mask");
	}

	selectImage("Mask");
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	rename("Labels");
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=lab%03d");
	run("Tile");

	selectImage("Labels");
	// Create a binary image from all initially detected labels.
	setThreshold(1, 65535, "raw");
	run("Convert to Mask");
	rename("Masks_from_Labels");

	roiCount = roiManager("count");
	if (roiCount == 0) {
		showStatus("Skipping image without detected objects: " + filename);
		roiManager("reset");
		close("*");
		return;
	}

	// Process each object separately so filling cannot affect neighbouring objects.
	for (i = 0; i < roiCount; i++) {
		selectWindow("Masks_from_Labels");
		run("Select None");
		run("Duplicate...", "title=temp");
		selectWindow("temp");
		roiManager("Select", i);
		run("Clear Outside");
		if (fillInteriorVoids)
			run("Fill Holes");
		selectWindow("temp");
		roiManager("Select", i);
		run("Copy");
		selectWindow("Masks_from_Labels");
		roiManager("Select", i);
		run("Paste");
		close("temp");
	}

	roiManager("reset");
	close("Mask");

	// Model
	selectWindow("Masks_from_Labels");
	run("Spherical Extrusion");
	if (modelName == "Vmod") {
		run("Divide...", "value=188.65");
		run("Add...", "value=1");
		run("Log");
		run("Multiply...", "value=188.650");
		run("Multiply...", "value=1.07541");
	}
	rename("Model");

	selectWindow("Masks_from_Labels");
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	rename("Labels");
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=lab%03d");
	run("Tile");

	// Label Map to ROIs can expose enclosed background voids as separate ROIs.
	// Remove ROIs containing no foreground pixels, while preserving the voids in the mask.
	selectWindow("Masks_from_Labels");
	for (i = roiManager("count") - 1; i >= 0; i--) {
		roiManager("select", i);
		getStatistics(voidArea, voidMean);
		if (voidMean == 0)
			roiManager("delete");
	}

	// Labels with optional interior-void filling applied.
	selectImage("Labels");
	run("Analyze Regions", "area circularity");

	selectWindow("Labels-Morphometry");
	path = dirOut + File.separator + name + "-Labels-Morphometry.txt";
	save(path);
	run("Close");

	content = File.openAsString(path);
	success = File.delete(path); // delete auxiliary file

	lines = split(content, "\n");
	indices = newArray(roiManager("count"));
	for (i = 0; i < indices.length; i++)
		indices[i] = 0;

	for (i = 1; i < lines.length; i++) { // skip header
		line = trim(lines[i]);
		if (line == "") continue;
		values = split(line, "\t");
		if (values.length >= 3) {
			area = parseFloat(values[1]);
			circularity = parseFloat(values[2]);
			// Keep only ROIs satisfying both area and circularity thresholds.
			if (area < areaIslet || circularity < circularityMin)
				indices[i-1] = 1;
		}
	}

	// Iterate backwards to preserve indices while deleting ROIs.
	for (i = roiManager("count") - 1; i >= 0; i--) {
		if (indices[i] != 0) {
			roiManager("select", i);
			roiManager("delete");
		}
	}

	circleRadius = 0;

	selectWindow("Model");
	for (i = 0; i < roiManager("count"); i++) {
		roiManager("select", i);
		getStatistics(area, mean, min, max, std, histogram); // from Model
		circleRadius = sqrt(area/PI);
		ricordi_nL = 0;
		ricordi_IEQ = 0;
		ricordiValues(2*circleRadius);
		print(title + "," + pixelSizeStr + "," + isletDiamStr + "," + (i+1) + "," + d2s(2*circleRadius, 3) +
				"," + d2s(area, 3) + "," + d2s(mean, 3) + "," + d2s(2*area*mean, 0) + "," + d2s(2*area*mean*1E-6, 3) +
				"," + d2s(2*area*mean*1E-6/1.7671, 3) + "," + d2s((4/3)*PI*pow(circleRadius, 3)*1E-6, 3) +
				"," + d2s((4/3)*PI*pow(circleRadius, 3)*1E-6/1.7671, 3) +
				"," + d2s(ricordi_nL, 3) + "," + d2s(ricordi_IEQ, 3) + "," + interiorVoidsFilledText);
	}

	selectWindow("Model");
	roiManager("Deselect");
	roiManager("Show None");
	roiManager("Show All with labels");

	if (modelName == "Vmod")
		path = dirOut + File.separator + name + "-Vmod.tif";
	else
		path = dirOut + File.separator + name + "-Vext.tif";
	save(path);
	close("*");

	roiManager("reset");
}

function ricordiValues(isletsize) {
	if (isletsize<50) {
		ricordi_nL = 0.0;
		ricordi_IEQ = 0.0;
	}
	else if (isletsize>=50 && isletsize<100) {
		ricordi_nL = 0.295;
		ricordi_IEQ = 0.167;
	}
	else if (isletsize>=100 && isletsize<150) {
		ricordi_nL = 1.178;
		ricordi_IEQ = 0.667;
	}
	else if (isletsize>=150 && isletsize<200) {
		ricordi_nL = 3.004;
		ricordi_IEQ = 1.7;
	}
	else if (isletsize>=200 && isletsize<250) {
		ricordi_nL = 6.185;
		ricordi_IEQ = 3.5;
	}
	else if (isletsize>=250 && isletsize<300) {
		ricordi_nL = 11.133;
		ricordi_IEQ = 6.3;
	}
	else if (isletsize>=300 && isletsize<350) {
		ricordi_nL = 18.378;
		ricordi_IEQ = 10.4;
	}
	else if (isletsize>=350) {
		ricordi_nL = 27.920;
		ricordi_IEQ = 15.8;
	}
}
