// -------------------------------------------------------------------
// Written by: Theresa Fritz-Endres, OSU
// Date: 2022-03
// Contact: fritzent [at] oregonstate.edu
// -------------------------------------------------------------------

//Create 3D object (STL)

//This macro creates an STL file of an individual object using 3D Viewer tool.
//User specifies Brightness & Contrast, Threshold, and regions to clear (file must contain only one individual object)
//for 3D Viewer plugin.
//User must export STL by selecting File>Export Surfaces>STL (binary).

//Set paths
path = getDirectory("Choose a Directory"); 
	print("directory: " + path);
	
//Open file
file = File.openDialog("Select a File to Process"); 
open(file);
filename = getInfo("image.filename");
filenameNoExtension = File.nameWithoutExtension;
	print("file: " + filename + " opened");
	
//Remove scale
run("Set Scale...", "distance=0 known=0 unit=pixel");

//Subtrack background
run("8-bit"); 
type = getBoolean("Would you like to run Subtract Background?", "Yes", "No");
	if (type==1) { //allow user to select if want to subtract background or not
		waitForUser("Draw a line","Draw a line that is about the length of the radius of the largest object \nthen click OK");
		run("Measure");
		length = getResult("Length", 0); //get length results from row 1 (index 0)
			print("Subtracking background using rolling ball radius= " + length);
		run("Subtract Background...", "rolling=&length stack");
		}
	 
//Adjust Brightness and Contrast
run("In [+]"); //zoom in
run("Brightness/Contrast...");
waitForUser("Brightness & Contrast","Select Brightness & Contrast to enhance object and reduce background \nand click OK");
run("Apply LUT", "stack");
'Brightness and Contrast adjusted

//Determine threshold for 3D Viewer
run("Threshold...");
waitForUser("Determine threshold","Note optimal threshold so only the object is included (i.e., not background) \nthen close threshold window (WITHOUT APPLYING) and click OK");
close("Threshold");
Dialog.create("3D Viewer Threshold");
Dialog.addNumber("Threshold:", 42);
Dialog.show();
threshold = Dialog.getNumber(); 

//Clear unwanted regions
setTool("oval");
waitForUser("Clear Regions","Clear any unwanted regions using polygon or oval tool and the cut tool \nand then click OK");

//Create 3D Object and save .stl
run("3D Viewer");
call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
call("ij3d.ImageJ3DViewer.add", filename, "White", filename, threshold, "true", "true", "true", "1", "2"); //Define parameters of 3D object. Object is white, Threshold = user defined, display all channels (true), resampling factor is 1 (not compressed)
	print("3D Viewer used to generate 3D object with threshold = " + threshold + ", resampling factor = 1, and color = white");

setTool("hand");
waitForUser("Export the STL file by hand by selecting File>Export Surface> STL(binary)");
call("ij3d.ImageJ3DViewer.exportContent", "STL Binary", path + filename);  


//save adjusted file
selectWindow(filename);
saveAs("Tiff", path + filenameNoExtension + "_adjusted");