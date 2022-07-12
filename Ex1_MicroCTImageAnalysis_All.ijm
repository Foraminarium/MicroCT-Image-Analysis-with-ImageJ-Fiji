// -------------------------------------------------------------------
// Written by: Theresa Fritz-Endres, OSU
// Date: 2022-06
// Contact: fritzent [at] oregonstate.edu
// -------------------------------------------------------------------

//1. Process and calculate statistics for microCT derived images

//This macro processes a block of microCT-derived images and calculates statistics for n individual objects (volume, surface area, mean greyscale value, etc.). 
//Output is saved to a new folder created along the directory path called "Processed". 
//The macro then takes the processed block and splits it into individual object stacks along user-defined ROIs processes that individual. 
//The macro loops through the block to select n number of individuals. 
//Processed files of individual objects and their histogram of greyscale values are saved to an “Individuals” folder created along the directory path.
//3D objects are generated from the individual object files and manually saved to the “Individuals” folder. 


//Set paths
path = getDirectory("Choose a Directory"); 
	print("directory: " + path);
//Create new folder to save into
newfolder_processed = path + "Processed" + File.separator;
File.makeDirectory(newfolder_processed);
	print("new folder created: " + newfolder_processed);
newfolder_individuals = path + "Individuals" + File.separator;
File.makeDirectory(newfolder_individuals);
	print("new folder created: " + newfolder_individuals);

//Open file
file = File.openDialog("Select a File to Process"); 
'This may take some time if file is large. Check that the max memory in Memory & Threads is large enough to open file.
open(file);
filename = getInfo("image.filename");
filenameNoExtension = File.nameWithoutExtension;
	print("file: " + filename + " opened");

//Crop out background and convert to 8-bit
waitForUser("Select a ROI","scroll through stack and select an ROI (suggested polygon tool) \nthat surrounds all objects and minimized background");
'Crop along ROI
run("Crop");
//'Clear outside ROI
//run("Clear Outside", "stack");
'Convert to 8-bit
run("8-bit"); 

//Subtrack background
type = getBoolean("Would you like to run Subtract Background?", "Yes", "No");
if (type==1) { //allow user to select if want to subtract background or not
	waitForUser("Draw a line","Draw a line that is about the length of the radius of the largest object \nthen click OK");
	run("Measure");
	length = getResult("Length", 0); //get length results from row 1 (index 0)
		print("Subtracking background using rolling ball radius= " + length + " pixels");
	run("Subtract Background...", "rolling=&length stack");
	saveAs("Tiff", newfolder_processed + filenameNoExtension + "_processed");
}

saveAs("Tiff", newfolder_processed + filenameNoExtension + "_processed"); //save outside of if statement (if user selects no)

//Set global scale to know distance per voxel
Dialog.create("Define scale (from Recon Repot)");
Dialog.addNumber("known scale:", 1.7);
Dialog.addString("units", "µm");
Dialog.addNumber("per # of voxels:", 1);
Dialog.show();
scale = Dialog.getNumber(); 
units = Dialog.getString(); 
voxels = Dialog.getNumber(); 
	
type = getBoolean("Would you like to run 3D Object Counter? This step takes a lot of processing power", "Yes", "No");
if (type==1) { //allow user to select if want to run 3D object counter or not
	'Run 3D object counter to calculate stats
	//select scale xfactor to reduce file size for 3D Object Counter
	type = getBoolean("Is your file bigger than 500 MB?", "Yes", "No"); //allow user to select if file needs to be scaled by 0.25 (file > 1 GB) or 0.5 (file < 1 GB)
	if (type==1) { 
		scale_xfactor = 0.25; 	
	}
	else {
		scale_xfactor = 0.5; 	
	}
		print("Scale reduced by: " + scale_xfactor + "to converse memory for 3D Object Counter");
	scaled_xfactor = scale * scale_xfactor; //Because we rescale by xfactor to reduce the file size, need to multiply scale by xfactor here

	run("Set Scale...", "distance=&voxels known=&scaled_xfactor unit=&units global"); //Units are set to be applied globally (to all open and subsequent files)
		print("Scale: " + scale + units + "/" + voxels + "voxels");

	//Reduce file size for 3D Object Counter
	selectWindow(filenameNoExtension + "_processed.tif"); 
	run("Scale...", "x=" + scale_xfactor + "y=" + scale_xfactor + "z=1.0 interpolation=Bilinear average process create title=" + filenameNoExtension + "_scaled.tif");

	//Define settings for 3D object counter. Here volume, surface area, mean greyscale, std dev greyscale, min greyscale, max greyscale will all be calculated. Store results in table
	run("3D OC Options", "volume surface mean_gray_value std_dev_gray_value minimum_gray_value maximum_gray_value dots_size=20 font_size=24 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none"); 

	//set threshold, min, and max for 3D Object Counter
	'Set threshold for 3D object Counter. Define threshold so only shell is included (i.e., not infill/background).
	selectWindow(filenameNoExtension + "_scaled.tif"); 
	run("Threshold...");
	waitForUser("Determine threshold","Within scaled image: \ndetermine desired threshold then close threshold window (WITHOUT APPLYING) and click OK");
	Dialog.create("3D Object Counter Parameters");
	Dialog.addNumber("threshold:", 40); 
	Dialog.show();
	threshold = Dialog.getNumber(); 

		print("Set minimum for 3D object counter. Define min (in " + units +  "^3) to be sufficiently large to exclude small particles that are not objects");
	run("Clear Results");
	waitForUser("Draw a circle","Within scaled image: \nDraw a circle that is smaller than the smallest object, then click OK");
	run("Measure");
	min = getResult("Area", 0); //get Area results from row 1 (index 0)
	close("Results");

		print("running 3D Object Counter with user defined settings. Threshold=" + threshold + ", Min=" + min);
	'This step may take some time. Track progress in imageJ control panel.
	selectWindow(filenameNoExtension + "_scaled.tif"); 
	run("3D Objects Counter", "threshold=&threshold min.=&min objects surfaces statistics summary"); 

	//save output and close windows
	n = getValue("results.count");
		print("Object count = " + n);
	close(filenameNoExtension + "_scaled.tif"); 
	selectWindow("Statistics for " + filenameNoExtension + "_scaled.tif"); 
	saveAs("Results", newfolder_processed + filenameNoExtension + "_stats.csv");
	//close(filenameNoExtension + "_stats.csv");
	selectWindow("Objects map of " + filenameNoExtension + "_scaled.tif");
	saveAs("Tiff", newfolder_processed + filenameNoExtension + "_object map");
	close(filenameNoExtension + "_object map.tif");
	selectWindow("Surface map of " + filenameNoExtension + "_scaled.tif");
	saveAs("Tiff", newfolder_processed + filenameNoExtension + "_surface map");
	close(filenameNoExtension + "_surface map.tif");
}

//if choose not to run 3D object counter, need to define number of individual objects in file
else {
Dialog.create("Number of Objects");
Dialog.addNumber("Number:", 6);
Dialog.show();
n = Dialog.getNumber(); 
}

//Splits stack into individuals by selecting a ROI and name for each object
run("ROI Manager...");

//set scale again based on earlier assignments, because of rescale for 3D Object Counter
run("Set Scale...", "distance=&voxels known=&scale unit=&units global"); 

//Loop through the unprocessed block, selecting n ROIs
selectWindow(filenameNoExtension + "_processed.tif");

for (i = 0; i < n; i++) {
	waitForUser("Select a ROI","Return to processed image: \nSelect a ROI (polygon suggested) that surrounds individual object number=" + i);
	roiManager("Add");
  	roiManager("select", i); 
   	Dialog.create("Filename");
	Dialog.addString("Title:", "filename");
	Dialog.show();
	filename = Dialog.getString(); 
	run("Duplicate...", "title=[" + filename + "_duplicate] duplicate");	
	//clear outside of ROI
	run("Clear Outside","stack");
	//create substack
	waitForUser("Determine Substack range","Scroll through stack and note Start and End slice numbers in which object appears");
	Dialog.create("Slices of Stack");
	//Define range of slices of the stack you want to keep
	Dialog.addNumber("Slice start:", 1);
	Dialog.addNumber("Slice end:", 200);
	Dialog.show();
	startslice = Dialog.getNumber(); 
	endslice = Dialog.getNumber(); 
	run("Make Substack...", " slices=" + startslice + "-" + endslice);
		print("Substack created from slice: " + startslice + "-" + endslice);
	
	//Save individual file
	saveAs("Tiff", newfolder_individuals + filename);
	close(filename + "_duplicate");
	roiManager("Show All with labels");

	//Get histogram results and save as .csv and .tif	
    	print("Calculating histogram for: " + filename); 
    nBins = 256;
	row = 0;
run("Clear Results");
      for (slice=1; slice<nSlices; slice++) {
          selectWindow(filename + ".tif");
          getHistogram(values,counts,nBins);
          for (s=0; s<nBins; s++) {
              setResult("Slice", row, slice);
              setResult("Value", row, values[s]);
              setResult("Count", row, counts[s]);
              row++;
              run("Next Slice [>]");
      		}
      }
   	updateResults();
	saveAs("Results",  newfolder_individuals + filename + ".csv"); 
	run("Histogram","stack");
	saveAs("Tiff", newfolder_individuals + "Histogram of " + filename);
	close("Histogram of " + filename);
	
	//Determine threshold for 3D Viewer
	selectWindow(filename + ".tif");
	run("Threshold...");
	waitForUser("Determine threshold","Note optimal threshold so only the object is included (i.e., not background) \nthen close threshold window (WITHOUT APPLYING) and click OK");
	close("Threshold");
	Dialog.create("3D Viewer Threshold");
	Dialog.addNumber("Threshold:", 42);
	Dialog.show();
	threshold = Dialog.getNumber(); 

	//Clear unwanted regions
	setTool("polygon");
	waitForUser("Clear Regions","Clear any unwanted regions using polygon or oval tool and the cut tool \nand then click OK");
	
	//save adjusted file
	selectWindow(filename + ".tif");
	saveAs("Tiff", path + filename);
		
	type = getBoolean("Would you like to Generate a 3D Object?", "Yes", "No");
		if (type==1) { //allow user to select if want to run 3D Object Viewer
		//Generate a 3D object
		//Remove scale for 3D Object Viewer
		run("Set Scale...", "distance=0 known=0 unit=pixel");

		//Adjust Brightness and Contrast for 3D Object Viewer
		run("In [+]"); //zoom in
		run("Brightness/Contrast...");
		waitForUser("Brightness & Contrast","Select Brightness & Contrast to enhance object and reduce background \nand click OK");
		run("Apply LUT", "stack");
		'Brightness and Contrast adjusted

		//Create 3D Object and save .stl
		run("3D Viewer");
		call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
		call("ij3d.ImageJ3DViewer.add", filename + ".tif", "White", filename + ".tif", threshold, "true", "true", "true", "1", "2"); //Define parameters of 3D object. Object is white, Threshold = user defined, display all channels (true), resampling factor is 1 (not compressed)
			print("3D Viewer used to generate 3D object with threshold = " + threshold + ", resampling factor = 1, and color = white");

		setTool("hand");
		waitForUser("Export the STL file by hand by selecting File>Export Surface> STL(binary), \nthen close 3D Viewer window");
		call("ij3d.ImageJ3DViewer.exportContent", "STL Binary", path + filename);  

		//save adjusted file
		selectWindow(filename + ".tif");
		saveAs("Tiff", path + filename + "_adjusted");
		close();
		}
		close();
}
//Save output
roiManager("save", newfolder_individuals + "RoiSet.zip");

selectWindow(filenameNoExtension + "_processed.tif");
saveAs("Tiff", newfolder_processed + filenameNoExtension + "_ROIs");

SelectWindow("Log.txt");
SaveAs("Text", newfolder_processed + "Log.txt"); 

print("All done processing! Check " + path + "Processed and " + path + "Individuals for saved output"); 