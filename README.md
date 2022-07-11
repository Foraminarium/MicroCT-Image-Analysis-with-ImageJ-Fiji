# MicroCT-Image-Analysis-with-ImageJ-Fiji
Micro X-ray Computed Tomography (microCT) image analysis provides information about micro-scale structures and properties critical to the biological and geoscientific fields. Recent advances in microCT have in part been driven by the availability of new 3D image processing techniques. These techniques, while developed for the biological/life sciences, have the potential to support other scientific fields given an appropriate application. For example, microCT analysis can provide information about the density and structure of the microfossil shells of foraminifera, which are commonly used in paleoceanography to reconstruct aspects of the ocean and climate. Information about the density and structure of foraminiferal shells is useful for characterizing changes in ocean acidification and in foraminiferal species classification and assemblage-based sea surface temperature studies. The macros presented here provide a user-friendly semi-automated workflow for applying imageJ/Fiji tools to extract microCT-derived information on many individuals scanned together in a batch. The example datasets provided are of a batch of individual foraminiferal shells. The batch is small (six individuals) for simplicity of the example, but the workflow is applicable for rapidly processing large batches (dozens to hundreds) of individuals.

**Usage**

This repository contains five ImageJ macros that automate a common workflow in microCT derived image analysis:
-	Import a microCT-derived 3D image block 
-	Reduce file size (crop, substack, convert to 8-bit greyscale)
-	Allow user to subtract background and adjust image brightness/contrast
-	Count the number of individual objects and calculate a statistical summary of all individual objects
-	Divide the block into individual objects along user-defined ROIs
-	Generate 3D surfaces of individual objects
-	Save processed images and save summarized statistics 

The macro tools are written in IJ1 macro language and designed to be used with Fiji ImageJ software. Macros are simple scripts that execute a series of ImageJ commands/functions sequentially and feature a graphical interface to enter parameters. To execute a macro in ImageJ/Fiji, select *Plugins > Macros > Run...* and choose the macro file you wish to execute. To edit the default parameters or troubleshoot an issue with custom editing, select *Plugins > Macros > Edit...*

New users should start with the first tool, which is a workflow for all processing steps. Tools two through five divide the entire workflow into steps and are intended for users that have a specific task to perform.

**Tools**

**1. All Processing Workflow - Process and calculate statistics for microCT derived images**

Download the source code: [MicroCTImageAnalysis_All.txt](https://github.com/Foraminarium/MicroCT-Image-Analysis-with-ImageJ-Fiji/files/9087956/MicroCTImageAnalysis_All.txt)

Download an example dataset:

![Ex1_All](https://user-images.githubusercontent.com/74202885/178371606-397c1383-d174-4d01-b875-5da17dfd80d3.png)
*Figure 1 – Stack of images as a block and the compiled histogram all slices within the stack A. before any processing, B. after block processing and calculating block statistics using 3D Object Counter, C. after splitting up block along user-defined ROIs.*

Overview: 

This macro processes a block of microCT-derived images and calculates statistics for n individual objects (volume, surface area, mean greyscale value, etc.). Output is saved to a new folder created along the directory path called "Processed". 
The macro then takes the processed block and splits it into individual object stacks along user-defined ROIs processes that individual. The macro loops through the block to select n number of individuals. Processed files of individual objects and their histogram of greyscale values are saved to an “Individuals” folder created along the directory path.
3D objects are generated from the individual object files and manually saved to the “Individuals” folder. 

Data input: 

This macro is designed to process microCT-derived images as an image file (TIF, JPEG, etc.) stacks of any number of channels, bit type, or size. At this time the tool cannot handle netCDF files and these file types must be manually imported using the ImageJ/Fiji netCDF plugin and then concatenated using the concatenate image stack tool and saved as a TIF file.

Data output: 

Processed block images and statistical outputs are saved to a new folder created along the directory path called "Processed". Data of individuals are saved as the user-defined “filename.tif” and "filename.csv" and the list of ROIs as “RoiSet.zip” to a new folder created along the directory path called "Individuals". STL files generated with the 3D Viewer tool must be manually exported by selecting File>Export Surface>STL(binary). 

Workflow: 

This workflow streamlines the data reduction process by combining all processing steps. It is designed to stand alone from the preceding tools presented here and repetitive processing between procedures is removed. The explanation of the workflow is simplified below. For expanded explanations see tools 2 - 5.  
The user defines the input directory and the file to import and process. The file is the original block of microCT-derived images. The image stack is simplified by converting to 8-bit greyscale TIF files and by cropping out the background. The user is then prompted to decide to subtract background based on user-defined parameters of a rolling-ball radius for background subtract. If the user selects to run 3D object counter, n 3D individual objects are identified and individual object statistics are calculated (volume, surface area, mean greyscale value, etc.). The user must have knowledge of the scanning resolution to define the scale for calculating statistics. 
The processed block is then split into individual object stacks along user-defined ROIs and that individual object stack is processed by trimming blank space at the top and bottom and calculating a histogram of greyscale values for the stack. The macro loops through the block to select n number of individuals. 
If the user chooses to generate 3D objects, the 3D object surfaces are reconstructed from individual object stacks with the 3D Viewer tool. 

 
**2. Object Statistics and Counting for Block**

Download the source code: [MicroCTImageAnalysis_BlockStatistics.txt](https://github.com/Foraminarium/MicroCT-Image-Analysis-with-ImageJ-Fiji/files/9088022/MicroCTImageAnalysis_BlockStatistics.txt)

Download an example dataset: 

![Calculate_Stats_for_Block_image1](https://user-images.githubusercontent.com/74202885/178371835-f27f8378-5bb7-41db-938c-178eb0ff0a0b.png)
*Figure 2.1 – Stack of images as a block and the compiled histogram of all slices within the stack A. before background is subtracted, B. after background is subtracted, C. with threshold set to separate objects from the background.*

![Calculate_Stats_for_Block_image2](https://user-images.githubusercontent.com/74202885/178371859-1073072d-ee65-4b33-9e06-02ec828cdb1e.png)
*Figure 2.2. The A. object and B. surface map and the C. statistical results that are generated by the 3D Object Counter plugin.*

Overview: 

This tool processes a block of microCT-derived images by converting to greyscale 8-bit, subtracting background, and setting the scale. The tool then identifies 3D individual objects and calculates statistics (volume, surface area, mean greyscale value, etc.). The processed block and output are saved to a new folder created along the directory path named "Processed".

Data input: 

This tool is designed to handle microCT-derived images as an image file (TIF, JPEG, etc.) stacks of any number of channels, bit type, or size. The images need not be pre-processed. At this time the tool cannot handle netCDF files. 

Data output: 

Processed block images and statistical outputs are saved to a new folder created along the directory path called "Processed".

Workflow: 

The user defines the input directory, and the file to import and process. The file is the original block of microCT-derived images. The original block is simplified by converting the file type to 8-bit greyscale. Background is cropping out along a user-defined ROI and at the top and bottom of the stack using the substack tool. A histogram of the stack is generated, and the histogram and processed stack output are saved to a new folder created along the directory path named “Processed”. The user is then asked if they would like to run Subtract Background. If they select yes, the background is subtracted along a rolling ball radius that the user selects as the length of the radius of the largest individual object. A histogram of the stack is generated, and the histogram and processed stack output are saved to the “Processed” folder. 
The 3D Objects Counter is then run to calculate statistics for the processed block. The user defines a global scale to convert pixels/voxels to known units. Information about the scale should be obtained from the microCT reconstruction report. The file size is then reduced because this plugin uses a lot of system memory. 3D Objects Counter is then run based on a user-defined threshold and minimum object size. 3D Objects Counter is used to calculate volume, surface area, mean greyscale, std dev greyscale, min greyscale, and max greyscale for each object. The object volume and surface maps are saved as TIF files and the statistical results are saved as a CSV to the “Processed” folder. 
 
 
**3. Divide Blocks into Individuals**

Download the source code: [MicroCTImageAnalysis_DivideBlock.txt](https://github.com/Foraminarium/MicroCT-Image-Analysis-with-ImageJ-Fiji/files/9088030/MicroCTImageAnalysis_DivideBlock.txt)

Download an example dataset:

![Picture1](https://user-images.githubusercontent.com/74202885/178372484-60686f6a-8865-47b3-9622-5b79965e5f4f.png)
*Figure 2.1 – A. Block divided into individual objects along the user selected ROIs indicated in colored ellipses, B. An example individual object, C. the output of the ROI Manager indicating the coordinates for the defined individual objects for reproducibility.*

Overview: 

This tool processes a block by converting to greyscale 8-bit and subtracting background and saves the output to a new folder created along the directory path called "Processed". The tool then splits the block into user-defined ROIs that contain an individual object and processes that individual by trimming blank space at the top and bottom. The tool loops through the block to select n number of individuals. Saves individuals as the user-defined “filename.tif” and “filename.csv” and the list of ROIs as “RoiSet.zip” to a new folder created along the directory path called "Individuals".

Data input: 

This tool is designed to handle microCT-derived images as an image file (TIF, JPEG, etc.) stacks of any number of channels, bit type, or size. The images need not be pre-processed. At this time the tool cannot handle netCDF files. 

Data output: 

Individual objects are saved as the user-defined “filename.tif” to a new folder created along the path called “Individuals”. The output of the ROI Manager is saved as RoiSet.zip to the “Individuals” folder. The processed block file is saved as “file_processed.tif” to the “Processed” folder created along the directory path.

Workflow: 

The user defines the input directory and the file to import and process. The file can be the original block of microCT-derived images or can be a processed block. The block is converted to 8-bit and the user can either choose to subtrack the background or skip this step. If they select to, the background is subtracted along a rolling ball radius that the user selects as the length of the radius of the largest individual object. 
The block is then split into n individual objects along a user-defined ROI. Knowledge is required of the number of individual objects within the block to assign to n. The individual object stack is then trimmed to a user-defined substack to remove slices at the beginning and end of the stack that does not contain the object. Coordinates of the n ROI selections are saved to the ROI Manager and ROIs and labels are embedded within the processed block file.
 
 
**4. Individuals Statistics - Batch Process**

Download the source code: [MicroCTImageAnalysis_IndividualsStatistics.txt](https://github.com/Foraminarium/MicroCT-Image-Analysis-with-ImageJ-Fiji/files/9088035/MicroCTImageAnalysis_IndividualsStatistics.txt)

Download an example dataset: 

![Picture2](https://user-images.githubusercontent.com/74202885/178372275-92b0094c-7f91-4837-b811-2b9609915e65.png)
*Figure 4 – Individual object stack of images and the compiled histogram all slices within the stack A. before any processing, B. after subtracting background and processing. All individuals within the batch are processed as shown in this example.*

Overview: 

This tool processes a batch of individual object stacks. All files in the user-defined input directory are imported, converted to greyscale 8-bit, the background subtracted (user selects Yes/No), and saves to “Processed” folder in output path as "filename.tif”. Histograms are calculated and greyscale values and counts are written to the “Results” window and exported to “Histograms” folder in output path as “filename.csv”. 

Data input:

This tool is designed to handle a batch of image files (TIF, JPEG, etc.) of any number of channels, bit type, or size. The images need not be pre-processed. 

Data output:

The processed individual object files are saved as “filename.tif” to a new folder alone the directory path named “Processed”. The histogram output is saved as “filename.csv” to a new folder along the directory path named “Histograms”.

Workflow:

The user defines the input directory that contains a batch of individual object files. All files in the input directory are imported and converted to 8-bit, and the user can either choose to subtract background or to skip this step. If the user selects to, the background is subtracted along a rolling ball radius that the user selects as the length of the radius of the largest individual object. Histogram greyscale value and pixel count are calculated for each slice of the stack file. 
 
 
**5. Generate Individual 3D Surfaces – Batch Process**

Download the source code: [MicroCTImageAnalysis_3DSurfaces.txt](https://github.com/Foraminarium/MicroCT-Image-Analysis-with-ImageJ-Fiji/files/9088059/MicroCTImageAnalysis_3DSurfaces.txt)

Download an example dataset: 

![3D Object Individuals image3](https://user-images.githubusercontent.com/74202885/178372313-94d7934e-8f58-4031-94a2-9a058b8d8185.png)
*Figure 5 - Stack of images as a block and the compiled histogram all slices within the stack A. before any processing, B. after block processing and calculating block statistics using 3D Object Counter, C. after splitting up block along user-defined ROIs.*

Overview: 

This tool creates an STL file of an individual object using the 3D Viewer tool. The user specifies Brightness & Contrast, Threshold, and regions to clear (file must contain only one individual object) for 3D Viewer plugin. 

Data input:

This tool is designed to handle an image file (TIF, JPEG, etc.) that contains one individual object. The file may be any number of channels, bit type, or size. The images need not be pre-processed.

Data output:

The user must export the generated 3D object surface as a binary STL file by selecting File>Export Surface>STL(binary). The adjusted file is saved as “filename_adjusted.tif” to the directory path.

Workflow:

The user defines the input directory and the individual object file for processing. The file is converted to greyscale 8-bit and the user can either choose to subtract the background or skip this step. If they select to, the background is subtracted along a rolling ball radius that the user selects as the length of the radius of the largest individual object. 
The user defines adjustments to the file brightness and contrast to enhance the contrast between the object and the background. The user then determines the optimal threshold so that mostly the object is included within the threshold, not the background. The user manually uses the ROI and the cut tools to remove unwanted regions, such as background or the presence of other objects than the individual object of interest. The 3D viewer is then run on the adjusted file to generate a 3D object surface with the following parameters: surface reconstruction, white object, user-defined threshold, all channels displayed, and resampling factor of 1 i.e., no compression). 

**Terminology:**

***Block*** – An image stack that contains multiple individual objects.

***Concatenate*** – Link together two or more images or image stacks that have the same x and y dimensions and are the same data type. 

***Slice*** – One image of a ‘stack’, typically distinct along the z-axis. 

***Stack*** – Multiple spatially related ‘slices’ in a single multi-dimensional image set. Typically arranged along the z-axis. In stacks, a pixel (which represents 2D image) becomes a voxel (volumetric pixel).

***Substack*** – A new set of images created by extracting selected images from a stack 

***Intensity*** – Value assigned to a pixel/voxel. The range of intensities for an 8-bit grayscale image is from 0, meaning no intensity or white, to 255, indicating the highest level of the color is evidence in the pixel or black.

***ROI*** – “Regional of Interest”. A selection made with the organizational tool built into imageJ and other image processing programs

***Rolling ball radius*** – The radius generated by a ‘rolling ball’ algorithm that creates a ball around each pixel of an image. The rolling ball radius is used with subtract background by averaging over the ball and subtracting the value from the original image to remove large spatial variations in intensity of the background. The radius is set to be at least the size of the largest object of interest to account for the topography of the object without over-correcting.

***Threshold*** – A division that separates an image into two (or more) classes of pixels. The division is typically made using a pixel intensity value cutoff so that each pixel less than that value is assigned to one class and each pixel greater than that value is assigned to a second class.

***Tomographic images or tomograms*** - A 2D slice image acquired by an X-ray generating scan and reconstructed from a set of projection images of a specimen.  

**ImageJ plugin Requirements:**

***Subtract background*** - https://imagej.net/imagej-wiki-static/Rolling_Ball_Background_Subtraction

***NetCDF*** - https://lmb.informatik.uni-freiburg.de/resources/opensource/imagej_plugins/netcdf.html

***3D viewer*** - https://github.com/fiji/3D_Viewer 
Schmid, B., Schindelin, J., Cardona, A., Longair, M., & Heisenberg, M. (2010). A high-level 3D visualization API for Java and ImageJ. BMC Bioinformatics, 11(1). doi.10.1186/1471-2105-11-274

***Threshold Adjuster*** -https://imagej.nih.gov/ij/developer/source/ij/plugin/frame/ThresholdAdjuster.java.html
