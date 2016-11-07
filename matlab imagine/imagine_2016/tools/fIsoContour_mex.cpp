// ========================================================================
// ***
// *** Isocontour_mex.cpp
// ***
// ***
// *** Copyright 2014 Christian Wuerslin, University of Tuebingen and
// *** University of Stuttgart, Germany.
// *** Contact: christian.wuerslin@med.uni-tuebingen.de
// ***
// ========================================================================

#include "mex.h"
#include <queue>
#include <cmath>

#define NQUEUES             100	// number of FIFO queues

using namespace std;

long             lNZ, lNX, lNY;     // The image dimensions;
double          dRegMax, dPercentage;
double          *pdImg;             // pointer to the image
queue<long>     *aqQueue;			// vector of FIFO queues

// ========================================================================
// Inline function to determin minimum of two numbers
inline double ifMin(double a, double b)
{
    return a < b ? a : b;
}
// ========================================================================



// ========================================================================
// Inline function to determin maximum of two numbers
inline double ifMax(double a, double b)
{
    return a > b ? a : b;
}
// ========================================================================



// ========================================================================
// ***
// *** FUNCTION fPop
// ***
// *** Function that pops a voxel location from the highest priority
// *** non-empty queue which fulfills the region growing criterion.
// ***
// ========================================================================
long fPop() {
	long lInd; // Index of the voxel
    
    // --------------------------------------------------------------------
    // Loop over the queues, start with highest priority (0)
    for (int iQueueInd = 0; iQueueInd < NQUEUES; iQueueInd++) {
        
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        // While there are still entries in the queue, pop and determine
        // whether it fullfills the region growing criterion.
        while (!aqQueue[iQueueInd].empty()) {
            lInd = aqQueue[iQueueInd].front();aqQueue[iQueueInd].pop();
            dRegMax = ifMax(pdImg[lInd], dRegMax);
            if (pdImg[lInd] >= dRegMax*dPercentage) return lInd;// Return if valid entry found
        }
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    }
    // --------------------------------------------------------------------
    
	return -1; // if all queues are empty
}
// ========================================================================
// *** END OF FUNCTION fPop
// ========================================================================



// ========================================================================
// ***
// *** FUNCTION fGetNHood
// ***
// *** Get the 6-neighbourhood of voxel lLinInd
// ***
// ========================================================================
void fGetNHood(const long lLinInd, long& lNHoodSize, long* lNHood) {
	long lX, lY, lZ, lTemp;
    
    lNHoodSize = 0;
    
    lY = lLinInd % lNY; // get y coordinate, add +/-1 if in image range
	if (lY >       0) lNHood[lNHoodSize++] = lLinInd - 1;
	if (lY < lNY - 1) lNHood[lNHoodSize++] = lLinInd + 1;
    
	lTemp = lLinInd/lNY; // That is a floor() operation in c
	lX = lTemp % lNX; // get x coordinate, add +/-1 if in image range. X increment is lNY
	if (lX >       0) lNHood[lNHoodSize++] = lLinInd - lNY;
	if (lX < lNX - 1) lNHood[lNHoodSize++] = lLinInd + lNY;
    
    if (lNZ > 1) { // 3D case
        lZ = lTemp/lNX; // z coordinate, add +/-1 if in image range. Z increment is lNX*lNY
        if (lZ >       0) lNHood[lNHoodSize++] = lLinInd - lNX*lNY;
        if (lZ < lNZ - 1) lNHood[lNHoodSize++] = lLinInd + lNX*lNY;
    }
}
// ========================================================================
// *** END OF FUNCTION fGetNHood
// ========================================================================



// ========================================================================
// ***
// *** FUNCTION fGetMinMax
// ***
// *** Get the minimum and maximum value of an array
// ***
// ========================================================================
void fGetMinMax(double *pdArray, long lLength, double &dMin, double &dMax)
{
    dMax   = 0.0;
    dMin   = double(1e15);

    for (long lI = 0; lI < lLength; lI++) {
        dMin = ifMin(dMin, pdArray[lI]);
        dMax = ifMax(dMax, pdArray[lI]);
    }
}
// ========================================================================
// *** END OF FUNCTION fFindMinDist
// ========================================================================



// ========================================================================
// ***
// *** MAIN MEX FUNCTION RegionGrowing_mex
// ***
// *** See m-file for description
// ***
// ========================================================================
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    // --------------------------------------------------------------------
    // Check the number of the input and output arguments.
    if(nrhs < 2) mexErrMsgTxt("At least two input arguments required.");
    if(nlhs < 1) mexErrMsgTxt("At least one ouput argument required.");
    // --------------------------------------------------------------------
    
    // --------------------------------------------------------------------
    // Get pointer/values to/of the input and outputs objects
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 1st input: Image (get dimensions as well)
    if (!mxIsDouble(prhs[0])) mexErrMsgTxt("First input argument must be of type double.");
    mxArray* pArray = mxDuplicateArray(prhs[0]);
    pdImg = (double*) mxGetData(pArray);
    const int* pSize = mxGetDimensions(prhs[0]);
    long lNDims = mxGetNumberOfDimensions(prhs[0]);
    lNY = long(pSize[0]);
	lNX = long(pSize[1]);
    if (lNDims == 3) {
        lNZ = long(pSize[2]);
    } else {
        lNZ = 1;
    }
    long    lImSize = lNX*lNY*lNZ;
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 2nd input: Seed point coordinates.
    short *pSeed = (short*) mxGetPr(prhs[1]);
    long lLinInd;
    if (lNZ > 1)
        lLinInd = long(pSeed[0]) - 1 + (long(pSeed[1]) - 1)*lNY + (long(pSeed[2]) - 1)*lNX*lNY;
    else
        lLinInd = long(pSeed[0]) - 1 + (long(pSeed[1]) - 1)*lNY;
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 3rd input: The isocontour percentage
    dPercentage = 0.5; // 50 % is the default
    if (nrhs > 2) dPercentage = double(*mxGetPr(prhs[2]));
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 4rd input: The Min-Max mode (>0 is max, <0 is min). If mode is min,
    // invert the image data
    int iI;
    if (nrhs > 3) {
        if (double(*mxGetPr(prhs[3])) < 0) {
            for (iI = 0; iI < lImSize; iI++) pdImg[iI] *= -1.0;
        }
    }    
    double  dMax, dMin;
    fGetMinMax(pdImg, lImSize, dMin, dMax);
    for (iI = 0; iI < lImSize; iI++) pdImg[iI] = (pdImg[iI] - dMin)/dMax; // Normalize
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // Get pointer to output arguments and allocate memory for the corresponding objects
    plhs[0] = mxCreateNumericArray(lNDims, pSize, mxLOGICAL_CLASS, mxREAL);	// create output array
    bool *pbMask = (bool*) mxGetData(plhs[0]);						// get data pointer to mask
    bool *pbCandidate = (bool*) mxGetData(mxCreateNumericArray(lNDims, pSize, mxLOGICAL_CLASS, mxREAL));	// create output array
    
    // --------------------------------------------------------------------
    // Start of the real functionality
    
    aqQueue = new queue<long>[NQUEUES];
    
    long    lNHoodSize;
    long    alNHood[6];
    long    lRegSize = 1;
    long    lQueueInd;
    
    dRegMax = pdImg[lLinInd];
    pbMask[lLinInd] = true;
    pbCandidate[lLinInd] = true;
    
    // --------------------------------------------------------------------
    while (lRegSize < lImSize) {

        fGetNHood(lLinInd, lNHoodSize, alNHood);
        for (int iI = 0; iI < lNHoodSize; iI++) {
            lLinInd = alNHood[iI];
            if (pbCandidate[lLinInd]) continue;
            
            pbCandidate[lLinInd] = true;
            lQueueInd = long((1.0 - pdImg[lLinInd])*(NQUEUES - 1));
            if (lQueueInd > NQUEUES - 1) lQueueInd = NQUEUES - 1;
            aqQueue[lQueueInd].push(lLinInd);
        }
        
        lLinInd = fPop();
        if (lLinInd < 0) return; // Return if no suiting candidates
        
        pbMask[lLinInd] = true;
        lRegSize++;
    }
    // End of while loop
    // --------------------------------------------------------------------
}
// ========================================================================
// *** END OF MAIN MEX FUNCTION RegionGrowing_mex
// ========================================================================