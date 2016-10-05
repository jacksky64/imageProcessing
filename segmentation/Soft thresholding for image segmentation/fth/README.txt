FUZZY SEGMENTATION TOOLBOX

FUNCTIONS:

Main Function: 

FTH.m  Fuzzy thresholding segmentation of 2D or data

    Usage

       MG=fch(I);
       MG=fch(I,3,1,1.5);  
    
This function replaces old  SEG_FUZZY.m
 
------------------------------------       
Auxiliar functions:


FILTER2B.m: similar to filter2.m but assuming a specular periodic expansion of the image that avoids undesired border effects.

IM_EXPAND.m: Simetric expansion of image I

MAXIMA_SEARCH.m: Search of the maxima in the histogram of I

TRAPF_MAT.m: Construction and evaluation of trapezoid-shaped fuzzy membership functions
------------------------------------------


% Santiago Aja-Fernandez (V1.0), Ariel Hernan Curiale (V4.0)
% LPI V4.0
% www.lpi.tel.uva.es/~santi
% LPI Valladolid, Spain
% Original: 06/05/2012, 
% V4.0 06/02/2014


