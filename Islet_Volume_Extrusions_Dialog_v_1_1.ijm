// @File(label = "Input directory with binary images of islets", style = "directory") dirIn
// @String(label = "Pixel size [µm]", value="0.843") pixelSizeStr
// @String(label = "Which model", choices = {"Vext", "Vmod"}) modelName
// @String(label = "Minimum islet size (diameter) [µm]", value="50.0") isletDiamStr
// @File(label = "Output directory for storing results", style = "directory") dirOut

saveSettings();

run("Set Measurements...", "area mean redirect=None decimal=6");
setOption("BlackBackground", true);
pixSizeNumber = parseFloat(pixelSizeStr);
isletDiamNumber = parseFloat(isletDiamStr);
areaIslet = PI * (isletDiamNumber/2.0) * (isletDiamNumber/2.0); // in µm2
circularityMin = 0.15;

setBatchMode(true);
soubory = getFileList(dirIn);
Array.sort(soubory);

print("\\Clear");
if (modelName == "Vmod")
	print("Image,Pixel Size [µm/px],Minimum Islet Size [µm],Islet ID,Islet Size [µm],Area [µm2],Mean,Vmod [µm3],Vmod [nl],Vmod [IEQ],Vsphe [nl],Vsphe[IEQ]");
else
	print("Image,Pixel Size [µm/px],Minimum Islet Size [µm],Islet ID,Islet Size [µm],Area [µm2],Mean,Vext [µm3],Vext [nl],Vext [IEQ],Vsphe [nl],Vsphe[IEQ]");

for (ind = 0; ind < soubory.length; ind++) {
	if ( endsWith(soubory[ind], ".png") || endsWith(soubory[ind], ".tif") ) {
		path = dirIn + File.separator + soubory[ind];
		open(path);
		doProcessingMorphoLibJ(soubory[ind]);
	}
}

selectWindow("Log");
path = "";
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
	//input: binary image
	// Use image calibration if present (µm); otherwise fall back to dialog value
	getPixelSize(unitStr, pw, ph);
	usedPixSizeStr = pixelSizeStr; // default to dialog value
	if ( ((unitStr != "pixel") && (unitStr != "")) && pw != 1.0 && ph != 1.0) {
		uLower = toLowerCase(unitStr);
		if (indexOf(uLower, "µm")!=-1 || indexOf(uLower, "um")!=-1 || startsWith(uLower, "micron") || startsWith(uLower, "microm")) {
			setVoxelSize(pw, ph, 1.0, "um");
			usedPixSizeStr = d2s(pw, 6); // store the used pixel size in µm/px (X)
		} else {
			// Unit not in micrometers: ignore and use dialog value to keep outputs in µm
			setVoxelSize(pixSizeNumber, pixSizeNumber, 1.0, "um");
		}
	} else
		setVoxelSize(pixSizeNumber, pixSizeNumber, 1.0, "um");

	title = filename;
	dirIn = getDirectory("image");
	name = substring(title, 0, lastIndexOf(title,"."));
	
	run("8-bit");
	setThreshold(150, 255);	
	run("Convert to Mask");
	rename("Mask");
		
	selectImage("Mask");
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	rename("Labels");
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=lab%03d");
	run("Tile");
	
	selectImage("Labels");
	setThreshold(1, 65535, "raw");
	run("Convert to Mask");
	rename("Masks_from_Labels");
	// inspecting all ROIs and filling
	roiCount = roiManager("count");
	if (roiCount == 0) {
	    exit("ROI Manager is empty.");
	}
	for (i = 0; i < roiCount; i++) {
	    selectWindow("Masks_from_Labels");
	   	run("Select None");
	    run("Duplicate...", "title=temp");
	    selectWindow("temp");
	    roiManager("Select", i);    
	    run("Clear Outside");	    
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
	
	// Labels without holes now
	selectImage("Labels");
	run("Analyze Regions", "area circularity");
	
	selectWindow("Labels-Morphometry");
	path = "";
	path = dirOut + File.separator + name + "-Labels-Morphometry.txt";
	save(path);
	run("Close");
	
	content = File.openAsString(path);
	success = File.delete(path);				
	
	lines = split(content, "\n");				
    indices = newArray(roiManager("count"));
    for (i = 0; i < indices.length; i++)
    	indices[i] = 0;

	for (i = 1; i < lines.length; i++) {		
    	line = trim(lines[i]);
    	if (line == "") continue; 				
    		values = split(line, "\t");			
    	if (values.length >= 3) {
        	area = parseFloat(values[1]);
        	circularity = parseFloat(values[2]);        		        
			if (area < areaIslet || circularity < circularityMin)
    			indices[i-1] = 1;
    	}
	}
	
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
		getStatistics(area, mean, min, max, std, histogram);	// from Model
		circleRadius = sqrt(area/PI);
		print(title + "," + usedPixSizeStr + "," + isletDiamStr + "," + (i+1) + "," + d2s(2*circleRadius, 3) + 
				"," + d2s(area, 3) + "," + d2s(mean, 3) + "," + d2s(2*area*mean, 0) + "," + d2s(2*area*mean*1E-6, 3) +
				"," + d2s(2*area*mean*1E-6/1.7671, 3) + "," + d2s((4/3)*PI*pow(circleRadius, 3)*1E-6, 3)  + 
				"," + d2s((4/3)*PI*pow(circleRadius, 3)*1E-6/1.7671, 3));	
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
