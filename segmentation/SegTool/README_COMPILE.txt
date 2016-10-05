THIS FILE INCLUDES COMPILATION INSTRUCTIONS FOR 
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


Please follow these simple instructions to get the 
ToolBox working:


1) Download and unzip SegToolBox.zip from the website.

****** PRECAUTION: Please make sure that the path-name to the directory where files are unzipped **does NOT** contain any spaces. ******

2) Open Matlab. Cd to the unzipped directory whcih has all the files.

3) Make sure you have mex C++ compiler installed (Ex: Visual C++.) 
   - To choose the compiler type "mex -setup" at the matlab commandline.
   - Follow the instructions therein until you have chosen a C++ 
     compiler.
    	
4) Build the library files required by the toolbox by executing 
   the following at the matlab commandline:
   
>>  mex GraphCutSegment.cpp graph.cpp maxflow.cpp  
AND
>> mex GraphCutSegmentLazy.cpp graph.cpp maxflow.cpp

This should create the library files (ex: FileName.dll in Windows or
FileName.mexmac in MacOS)

5) Thats it! You are ready to use the toolbox now.

6) Please refer to README_GUI for tool usage instructions.

7) Please refer to CODE_MAP for a list of functions and the call structure.
