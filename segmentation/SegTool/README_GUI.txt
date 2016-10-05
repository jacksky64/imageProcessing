THIS FILE INCLUDES USAGE INSTRUCTIONS FOR 
SEGMENTATION TOOLBOX

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Authors - Mohit Gupta, Krishnan Ramnath
Affiliation - Robotics Institute, CMU, Pittsburgh
2006-05-15
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We provide a freely available Segmentation Toolbox that 
can readily be used for image segmentation tasks. 

Please acknowledge the authors if you are using this
ToolBox.


*************************************************************
*************************************************************
                      Important Notes:

1) The parameters file 'mksopt.m' contains declarations for all
the tunable parametes.

2) To segment a new image, please close the present working window 
and select a tool from the SegTool menu. Then proceed to select a 
new image from the file menu and perform operations on that image.

3) Modifications required to run the code in "Batch Mode" (for 
example, on PASCAL database): "Use the core segmentation code 
(Segment.m, (LZ) , SegmentGC (GC) ) for running the algorithm on 
huge data sets, without using the gui. You just needs to write a 
wrapper function that calls these functions repeatedly for each 
image in the dataset.

4) How are the outputs stored?: The outputs of each segmentation is 
stored in SegResult.mat file. This has the resulting segmentation 
mask (SegMask) and the segmented image (SegImage.)

***************************************************************
***************************************************************


Please follow the instructions below for using the toolbox.
Follow specific instructions for each part of the toolbox.

--------------
STEP 1:
--------------

The Segmentation ToolBox is invoked by typing "SegTool" at
the Matlab commandline.

--------------
STEP 2:
--------------

The Segmentation ToolBox has three parts:

1) SmartSelect (Lazy Snapping) Tool : This tool is used to perform
supervised segmentation by marking foreground and background seeds.

2) AutoCut (Grab CUt) Tool: This tool is used to perform semi-automatic
segmentation by just marking a bounding rectangle (two opposite corners) covering
the object to be segmented.

3) AutoCutRefine (Grab Cut + Lazy Snapping) Tool: This allows the user to 
perform a SmartSelect Refinement on the AutoCut result.

--------------
STEP 3:
--------------

There are separate instructions for each tool:

%%%%%%%%%%%%%%%%%%%%%%%%
1) SMARTSELECT:
%%%%%%%%%%%%%%%%%%%%%%%%

- Choose SegTool->SmartSelect

- This opens a file menu. From this choose the image you want to segment.

- The image is displayed, along with two menu options on the right:
	1) SmartRefine
	2) SmartRectangle
These indicate the two ways in which we can mark seeds on the image to
initiate the graph cut segmentation algorithm. We can toggle between the 
two ways by choosing the corresponding radio button

$$$$$$$$$$$$$$$$$$
1) SMARTRECTANGLE: 
$$$$$$$$$$$$$$$$$$
Using this we can mark seeds in the form of rectangular 
regions on the image.

Choose SmartRectangle - This gives you three options: 

1) Foreground - Click this to mark foreground seeds
2) Background - Click this to mark background seeds
3) GraphCuts - Click this to run the segmentation.

Once you click "foreground" or "background" the system waits for input.
The input in this case is two corners of the rectangle (usually top left
and bottom right) that the user selects. 

Clicking on foreground (or background) button and then choosing two points plots a 
rectangle which indicates the seeds. (Foreground rectangles are red, background 
rectangles are blue)

To click a new rectangle the user has to click the foreground or the
background button again.

$$$$$$$$$$$$$$$
2) SMARTREFINE: 
$$$$$$$$$$$$$$$
User can use this to specify seeds in the form of strokes.

Choose SmartRefine radio button - This gives you three options: 

1) Foreground - Click this to mark foreground seeds
2) Background - Click this to mark background seeds
3) GraphCuts - Click this to run the segmentation.


Once you click "foreground" or "background" the system waits for input.
The input is specified in the form of strokes. To start marking the stroke
the user clicks on a point on the image and then moves the mouse. (The user
should merely click, ^^^^^^NOT CLICK AND HOLD^^^^^ while moving.) The user marks 
the end of the stroke by a second click. 

The user can click as many strokes as 
he wants by again clicking once on an image point to initiate the stroke and then click 
once again  to stop marking the stroke. 

Sometimes the strokes take time to plot, so if the system is busy the user may not
see the strokes immediately.



Once the user has chosen enough seeds he can start the graph cuts algorithm by 
clicking on graphcuts.

This runs graphcuts and gives the result.

^^^THE USER CAN REFINE THIS RESULT^^^: by choosing the seeds by doing the same as 
described above on the same image. These seeds are added to the previous seeds when 
the user calls graphcuts again.

%%%%%%%%%%%%%%%%%%%%
2) AUTOCUT:
%%%%%%%%%%%%%%%%%%%%

- Choose SegTool->AutoCut

- This opens a file menu. From this choose the image you want to segment.

- Once the image is chosen it is displayed and the system waits for user
input.

- The input is two points, which indicate the corners of a rectangle ^^^^^COVERING
THE OBJECT TO BE SEGMENTED^^^^^^^.

- Usually the user chooses the two points as the top left and bottom right 
corners of the rectangle over the object to be segmented.

- The algorithm iterates and gives a final segmented result. 

%%%%%%%%%%%%%%%%%%%%%
3) AUTOCUTREFINE:
%%%%%%%%%%%%%%%%%%%%%

- Choose SegTool->AutoCutRefine

- This opens a file menu. From this choose the image you want to segment.

- Once the image is chosen it is displayed and the system waits for user
input.

- The input is two points, which indicate the corners of a rectangle ^^^^^COVERING
THE OBJECT TO BE SEGMENTED^^^^^^^.

- Usually the user chooses the two points as the top left and bottom right 
corners of the rectangle over the object to be segmented.

- The algorithm iterates and gives a segmented result. 

- The segmented result is displayed as a mask image and also as a green 
boundary on the input image.

- The user can now refine this segment by using the SegmentRefine tool (see SmartRefine
above.)

- The user accesses the refinement tool from the right menu. As before he can
choose Foreground or Background seeds in the form of strokes (A click to start stroke, 
a click to stop stroke.)

- As before he marks foreground and background strokes and then clicks on 
SegmentRefine to refine the segmentation.

Remember: AUTOCUTREFINE = AUTOCUT + SMARTSELECT (SMARTREFINE)

				-----END------

Please refer to README_COMPILE for compilation instructions.
Please refer to CODE_MAP for a list of functions and the call structure.
