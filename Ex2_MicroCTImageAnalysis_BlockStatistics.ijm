// -------------------------------------------------------------------
// Written by: Theresa Fritz-Endres, OSU
// Date: 2022-06
// Contact: fritzent [at] oregonstate.edu
// -------------------------------------------------------------------

//2. Object Statistics and Counting for Block

//This macro processes a block of microCT derived images by converting to 8-bit, subtracking background, and setting the scale
//and identifies 3D individual objects and calculating statistics (volume, surface area, mean greyscale value, etc.).
//Processed block and output are saved to a new folder created along directory path named "Processed". 

//Set paths
path = getDirectory("Choose a Directory"); 
	print("directory: " + path);
//Create new folder to save into
newfolder_processed = path + "Processed" + File.separator;
File.makeDirectory(newfolder_processed);
	print("new folder created: " + newfolder_processed);

//Open file
file = File.openDialog("Select a File"); 
open(file);
filename = getInfo("image.filename");
filenameNoExtension = File.nameWithoutExtension;
	print("file: " + filename + " opened");
	
//Process block: convert to 8-bit, trim blank space at top and bottom of stack, remove background
//Convert to 8-bit
waitForUser("Select a ROI","scroll through stack and select an ROI (suggested polygon tool) \nthat surrounds all objects and minimized background");
'Crop along ROI
run("Crop");
'Convert to 8-bit
run("8-bit"); 

'Define range of slices of the stack you want to keep
waitForUser("Scroll through stack and note Start and End slice numbers");
Dialog.create("Slices of Stack");
Dialog.addNumber("Slice start:", 16);
Dialog.addNumber("Slice end:", 283);
Dialog.show();
startslice = Dialog.getNumber(); 
endslice = Dialog.getNumber(); 
run("Make Substack...", " slices=" + startslice + "-" + endslice);
getDimensions(width, height, channels, slices, frames);

/**********
* Function
**********/
//Function to obtain histogram results for a stack
function histogram_stack(){
	nBins = 256;
	row = 0;
	run("Clear Results");
      for (slice=1; slice<nSlices; slice++) {
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
}

//Get histogram results and save as .csv and .tif	
histogram_stack();
saveAs("Results",  newfolder_processed + filenameNoExtension + ".csv"); 
close();
run("Histogram","stack"); //save histogram stack image
saveAs("Tiff", newfolder_processed + "Histogram of " + filenameNoExtension);

//Subtrack background
type = getBoolean("Would you like to run Subtract Background?", "Yes", "No");
if (type==1) { //allow user to select if want to subtract background or not
	waitForUser("Draw a line","Draw a line that is about the length of the radius of the largest object \nthen click OK");
	run("Measure");
	length = getResult("Length", 0); //get length results from row 1 (index 0)
		print("Subtracking background using rolling ball radius= " + length);
	run("Subtract Background...", "rolling=&length stack");
	makeRectangle(0, 0, width, height); //select whole image for histogram
	saveAs("Tiff", newfolder_processed + filenameNoExtension + "_processed");

	//Get histogram results and save as .csv and .tif	
	histogram_stack();
	saveAs("Results",  newfolder_processed + filenameNoExtension + "_processed" + ".csv"); 
	run("Histogram","stack"); //save histogram stack image
	saveAs("Tiff", newfolder_processed + "Histogram of " + filenameNoExtension + "_processed");
}
else{
	saveAs("Tiff", newfolder_processed + filenameNoExtension + "_processed");
	
	//Get histogram results and save as .csv and .tif	
	histogram_stack();
	saveAs("Results",  newfolder_processed + filenameNoExtension + "_processed" + ".csv"); 
	run("Histogram","stack"); //save histogram stack image
	saveAs("Tiff", newfolder_processed + "Histogram of " + filenameNoExtension + "_processed"); //save outside of "if" statement (if user selects no)
}
	
//Set scale
'Set global scale to know distance per voxel
Dialog.create("Define scale (from Recon Repot)");
Dialog.addNumber("known scale:", 1.7473);
Dialog.addString("units", "µm");
Dialog.addNumber("per # of voxels:", 1);
Dialog.show();
scale = Dialog.getNumber(); 
units = Dialog.getString(); 
voxels = Dialog.getNumber(); 

//select scale xfactor to reduce file size for 3D Objects Counter
type = getBoolean("Is your file bigger than 500 MB?", "Yes", "No"); //allow user to select if file needs to be scaled by 0.25 (file > 1 GB) or 0.5 (file < 1 GB)
if (type==1) { 
scale_xfactor = 0.25; 	
}
else {
scale_xfactor = 0.5; 	
}
print("Scale xfactor: " + scale_xfactor);
scaled_xfactor = scale * scale_xfactor; //Because we rescale by xfactor to reduce the file size, need to multiply scale by xfactor here

run("Set Scale...", "distance=&voxels known=&scaled_xfactor unit=&units global"); //Units are set to be applied globally (to all open and subsequent files)
	print("Scale: " + scale + units + "/" + voxels + "voxels");

//Reduce file size for 3D Objects Counter
selectWindow(filenameNoExtension + "_processed.tif"); 
run("Scale...", "x=" + scale_xfactor + "y=" + scale_xfactor + "z=1.0 interpolation=Bilinear average process create title=" + filenameNoExtension + "_scaled.tif");

//Run 3D Objects Counter.
'Run 3D object counter to calculate stats
//Define settings for 3D object counter. Here volume, surface area, mean greyscale, std dev greyscale, min greyscale, max greyscale will all be calculated. Store results in table
run("3D OC Options", "volume surface mean_gray_value std_dev_gray_value minimum_gray_value maximum_gray_value close_original_images_while_processing_(saves_memory) dots_size=10 font_size=18 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none"); //Define settings for 3D object counter. Here volume, surface area, mean greyscale, std dev greyscale, min greyscale, max greyscale will all be calculated. Store results in table.

//set threshold, min, and max for 3D Objects Counter
'Set threshold for 3D object Counter. Define threshold so only shell is included (i.e., not infill/background).
selectWindow(filenameNoExtension + "_scaled.tif"); 
run("Threshold...");
waitForUser("Determine threshold","Within scaled image: \ndetermine desired threshold then close threshold window (WITHOUT APPLYING) and click OK");
Dialog.create("3D Objects Counter Parameters");
Dialog.addNumber("threshold:", 40); 
Dialog.show();
threshold = Dialog.getNumber(); 

	print("Set minimum for 3D Objects Counter. Define min (in " + units +  "^3) to be sufficiently large to exclude small particles that are not objects");
run("Clear Results");
waitForUser("Draw a circle","Within scaled image: \nDraw a circle that is smaller than the smallest object, then click OK");
run("Measure");
min = getResult("Area", 0); //get Area results from row 2 (index 1)
close("Results");

run("3D Objects Counter", "threshold=&threshold min.=&min objects surfaces statistics summary"); 

//save output and close windows
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

close(filename);
close(filenameNoExtension + "_processed.tif");

print("All done processing! Check " + path + "Processed for saved output"); 