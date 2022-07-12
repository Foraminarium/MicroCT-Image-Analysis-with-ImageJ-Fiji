// -------------------------------------------------------------------
// Written by: Theresa Fritz-Endres, OSU
// Date: 2022-06
// Contact: fritzent [at] oregonstate.edu
// -------------------------------------------------------------------

//Divide Block into Individuals and Batch Process

//This macro processes a block by converting to 8-bit and subtracting background 
//and saves output to a newfolder created along directory path called "Processed". 

//The macro then splits the block into user defined Regions of Interest (ROIs) that contains an individual object 
//and processes that individual by trimming blank space at the top and bottom.
//Loops through the block to select n number of individuals.
//Saves each individual as the user defined “filename.tif” and “filename.csv” 
//and the list of ROIs as “RoiSet.zip” to a newfolder created along directory 
//path called "Individuals". 

///Set paths
'Choose a directory
path = getDirectory("Choose a Directory"); 
//Create new folder to save into
newfolder_processed = path + "Processed" + File.separator;
	print("new folder created:" + newfolder_processed);
newfolder_individuals = path + "Individuals" + File.separator;
	print("new folder created:" + newfolder_individuals);

File.makeDirectory(newfolder_processed);
File.makeDirectory(newfolder_individuals);

//Open file
'Choose a file to divide into individual objects
file = File.openDialog("Select a File"); 
open(file);
filename = getInfo("image.filename");
filenameNoExtension = File.nameWithoutExtension;
	print("file opened: " + filename);

//Convert to 8-bit
run("8-bit"); 

//Subtrack background
type = getBoolean("Would you like to run Subtract Background?", "Yes", "No");
if (type==1) { //allow user to select if want to subtract background or not
	waitForUser("Draw a line","Draw a line that is about the length of the radius of the largest object \nthen click OK");
	run("Measure");
	length = getResult("Length", 0); //get length results from row 1 (index 0)
		print("Subtracking background using rolling ball radius= " + length + " pixels");
	run("Subtract Background...", "rolling=&length stack");
}

//Splits stack into individuals by selecting a ROI and name for each object
Dialog.create("Number of Objects");
Dialog.addNumber("Number:", 6);
Dialog.show();
n = Dialog.getNumber(); 
run("ROI Manager...");
run("Labels...", "color=white font=24 show draw bold");

//Loop through the block, selecting n ROIs
for (i = 0; i < n; i++) {
	waitForUser("Select a ROI","Return to processed file and Select a ROI");
	roiManager("Add");
  	roiManager("select", i); 
   	Dialog.create("Filename");
	Dialog.addString("Title:", "filename");
	Dialog.show();
	filename = Dialog.getString(); 
	run("Duplicate...", "title=[" + filename + "_duplicate] duplicate");	
	//create substack
	waitForUser("Determine Substack range","Scroll through stack and note Start and End slice numbers");
	Dialog.create("Slices of Stack");
	'Define range of slices of the stack you want to keep
	Dialog.addNumber("Slice start:", 40);
	Dialog.addNumber("Slice end:", 270);
	Dialog.show();
	startslice = Dialog.getNumber(); 
	endslice = Dialog.getNumber(); 
	run("Make Substack...", " slices=" + startslice + "-" + endslice);

	//Save
	saveAs("Tiff", newfolder_individuals + filename);
	close(filename + ".tif");
	close(filename + "_duplicate");
	roiManager("Show All with labels");
	roiManager("Select", i);
	Roi.setStrokeColor(255*random, 255*random, 255*random);
	roiManager("Set Line Width", 7);
}

//Save output
roiManager("save", newfolder_individuals + "RoiSet.zip"); //Save results of ROI Manager

selectWindow(filenameNoExtension + ".tif"); 
saveAs("Tiff", newfolder_processed + filenameNoExtension + "_processed"); //Save processed block with ROIs
	
print("All done processing! Check " + path + "Processed and " + path + "Individuals for saved output"); 