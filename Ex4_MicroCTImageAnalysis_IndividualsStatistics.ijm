// -------------------------------------------------------------------
// Written by: Theresa Fritz-Endres, OSU
// Date: 2022-03
// Contact: fritzent [at] oregonstate.edu
// -------------------------------------------------------------------

//Get Histogram of Greyscale Values - Batch Process 

//This macro processes a batch of individual object files. 
//All files in the user defined input directory are imported, 
//converted to 8-bit, the background subtracted (user selects Yes/No), and 
//saves to “Processed” folder in output path as "filename.tif”. 
//Histograms are calculated and greyscale values and counts are written to 
//the “Results” window and exported to “Histograms” folder in output path as “filename.csv”. 

//Set paths
path = getDirectory("Choose a Directory"); 
	print("directory: " + path);
pathname = File.getName(path);
//Create new folder to save into
newfolder = path + "/..//" + pathname + "_Processed/";
File.makeDirectory(newfolder);
	print("new folder created: " + path + pathname + "_Processed");
	
processed = newfolder + "Processed" + File.separator;
File.makeDirectory(processed);
	print("new folder created: " + path + pathname + "_Processed" + File.separator + "Processed");
//Create new folder to save .csvs into
histograms = newfolder + "Histograms" + File.separator;
File.makeDirectory(histograms);
	print("new folder created: " + path + pathname + "_Processed" + File.separator + "Histograms");
	
//read in all files in folder
setBatchMode(true); 
list = getFileList(path);
for (i = 0; i < list.length; i++){
        action(path, list[i]);
}

function action(path,filename) {
//Convert file to 8-bit and subtract background using user defined “window” and save as .tif
	print("processing: " + filename); 
    open(filename);
	run("8-bit"); 
	filename = getInfo("image.filename");
	filenameNoExtension = File.nameWithoutExtension;
//Subtrack background
	type = getBoolean("Would you like to run Subtract Background?", "Yes", "No");
	if (type==1) { //allow user to select if want to subtract background or not
		waitForUser("Draw a line","Draw a line that is about the length of the radius of the largest object \nthen click OK");
		run("Measure");
		length = getResult("Length", 0); //get length results from row 1 (index 0)
			print("Subtracking background using rolling ball radius= " + length);
		run("Subtract Background...", "rolling=&length stack");
		saveAs("Tiff", processed + filename);
		}

	saveAs("Tiff", processed + filename); //save outside of if statement (if user selects no)
	 
//Get histogram results and save as .csv	
    print("calculating histogram for: " + filename); 
    nBins = 256;
	row = 0;
run("Clear Results");
      for (slice=1; slice<nSlices; slice++) {
          //selectWindow(filename);
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
	saveAs("Results",  histograms + filenameNoExtension + ".csv"); 
	close();
}

print("All done processing! Check " + path + pathname + "_Processed" + " for saved output"); 