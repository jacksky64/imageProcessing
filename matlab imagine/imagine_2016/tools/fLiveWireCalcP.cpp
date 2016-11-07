//FLIVEWIRECALCP Calculates the path maps in a live-wire implementation [1].
//
//   [IPX, IPY] = FLIVEWIRECALCP(DFG, IXS, IYS) Calculates the path map (a
//   vector field) showing the cheapest path through DFG to the seed pixel
//   (IXS, IYS)^T. The vector field's x- and y components (quantized to [-1,
//   0, 1]) are returned in IPX and IPY, respectively.
//
//   [IPX, IPY] = FLIVEWIRECALCP(DFG, IXS, IYS, DRADIUS) This syntax is
//   recomended for larger images and lets the user specify the approximate
//   radius from the seed piont in which IPX and IPY are calculated. Since
//   the calculation of IPX and IPY is O(N^2) heavy for the number of
//   pixels, a reduction of DRADIUS can lead to a significant performance
//   boost.
//
//   NOTE: Compile this file using the command:
//   >> mex fLiveWireCalcP.cpp
//
//   See also LIVEWIRE, FLIVEWIREGETCOSTFCN, FLIVEWIREGETPATH.
//
//
//   Copyright 2013 Christian W�rslin, University of T�bingen and University
//   of Stuttgart, Germany. Contact: christian.wuerslin@med.uni-tuebingen.de
//
//
//   References:
//
//   [1] MORTENSEN, E. N.; BARRETT, W. A. Intelligent scissors for image
//   composition. In: SIGGRAPH '95: Proceedings of the 22nd annual
//   conference on Computer graphics and interactive techniques.
//   New York, NY, USA: ACM Press, 1995. p. 191:198.

#include "mex.h"
#include <stdlib.h>

#define LISTMAXLENGTH   10000

// ------------------------------------------------------------------------
// Structure definitin of the active list entries
struct SEntry {
    short    sX;         // X-coordinate
    short    sY;         // Y-coordinate
    long     lLinInd;    // Linear index from x and y for 1D-array
    float    flG;        // The current cost from seed to (X,Y)^T
};
// ------------------------------------------------------------------------



// ========================================================================
// Inline function to determin minimum of two numbers
inline long ifMin(long a, long b)
{
    return a < b ? a : b;
}
// ========================================================================



// ========================================================================
// Inline function to determin maximum of two numbers
inline long ifMax(long a, long b)
{
    return a > b ? a : b;
}
// ========================================================================



// ========================================================================
// Inline function to calculate linear index from subscript indices.
inline long ifLinInd(short sX, short sY, short sNY)
{
    return long(sX)*long(sNY) + long(sY);
}
// ========================================================================



// ========================================================================
// ***
// *** FUNCTION fFindMinG
// ***
// *** Get the Index of the vector entry with the smallest dQ in pV
// ***
// ========================================================================
long fFindMinG(SEntry *pSList, long lLength)
{
    long    lMinPos = 0;
    float   flMin   = 1e15;
    SEntry  SE;

    for (long lI = 0; lI < lLength; lI++) {
        SE = *pSList++;
        if (SE.flG < flMin) {
            lMinPos = lI;
            flMin = SE.flG;
        }
    }
    return lMinPos;
}
// ========================================================================
// *** END OF FUNCTION fFindMinG
// ========================================================================



// ========================================================================
// ***
// *** FUNCTION fFindLinInd
// ***
// *** Get the Index of the list entry in *pSList lLinInd == lInd
// ***
// ========================================================================
long fFindLinInd(SEntry *pSList, long lLength, long lInd)
{
    SEntry SE;
    
    for (long lI = 0; lI < lLength; lI++) {
        SE = *pSList++;
        if (SE.lLinInd == lInd) return lI;
    }
    return -1; // If not found, return -1
}
// ========================================================================
// *** END OF FUNCTION fFindLinInd
// ========================================================================



// ========================================================================
// ***
// *** MAIN MEX FUNCTION fLiveWireCalcP
// ***
// *** See above for description
// ***
// ========================================================================
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    // --------------------------------------------------------------------
    // Check the number of the input and output arguments.
    if(nrhs < 3)  mexErrMsgTxt("At least 3 input arguments required.");
    if(nlhs != 2) mexErrMsgTxt("Exactly two ouput arguments required.");
    // --------------------------------------------------------------------
    
    // --------------------------------------------------------------------
    // Get pointer/values to/of the input and outputs objects
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 1st input: Force-image (get dimensions as well)
    double *pdF	= (double*) mxGetData(prhs[0]);
    short   sNX = short(mxGetN(prhs[0]));
	short   sNY = short(mxGetM(prhs[0]));
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // 2nd and 3rd input: Seed point coordinates.
    short   sXSeed = short(*mxGetPr(prhs[1])) - 1L;
    short   sYSeed = short(*mxGetPr(prhs[2])) - 1L;
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    //4th input (optional): Radius of pixels from the seep point to process.
    double dRadius;
    if (nrhs < 4) dRadius = 10000; else dRadius = *mxGetPr(prhs[3]);
    // Done handling inputs
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // Get pointer to output arguments and allocate memory for the corresponding objects
    const int* pSize = mxGetDimensions(prhs[0]);                    // get force-image size
    plhs[0] = mxCreateNumericArray(2, pSize, mxINT8_CLASS, mxREAL);	// create output X-array
    plhs[1] = mxCreateNumericArray(2, pSize, mxINT8_CLASS, mxREAL);	// create output Y-array
    char *plPX    = (char*) mxGetData(plhs[0]);						// get data pointer to X-output
    char *plPY    = (char*) mxGetData(plhs[1]);						// get data pointer to Y-output
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    // --------------------------------------------------------------------

    // --------------------------------------------------------------------
    // Start of the real functionality
    long    lInd;
    long    lLinInd;
    long    lListInd = 0; // = length of list
    short   sXLowerLim;
    short   sXUpperLim;
    short   sYLowerLim;
    short   sYUpperLim;
    long    lNPixelsToProcess;
    long    lNPixelsProcessed = 0;

    float   flThisG;
    float   flWeight;
    
    SEntry  SQ, SR;
    
    char   *plE    = (char*)   mxCalloc(long(sNX)*long(sNY) , sizeof(char));
    SEntry *pSList = (SEntry*) mxCalloc(LISTMAXLENGTH       , sizeof(SEntry));
    
    lNPixelsToProcess = ifMin(long(3.14*dRadius*dRadius + 0.5), long(sNX)*long(sNY));
	
    #ifdef DEBUG
    mexPrintf("Pixels to process: %u\n", lNPixelsToProcess);
    #endif

    // --------------------------------------------------------------------
    // Initialize active list with zero cost seed pixel.
    SQ.sX       = sXSeed;
    SQ.sY       = sYSeed;
    SQ.lLinInd  = ifLinInd(sXSeed, sYSeed, sNY);
    SQ.flG      = 0.0;
    pSList[lListInd++] = SQ;
	// --------------------------------------------------------------------
    
    // --------------------------------------------------------------------
    // While there are still objects in the active list and pixel limit not reached
    while ((lListInd) && (lNPixelsProcessed < lNPixelsToProcess)) {
        // ----------------------------------------------------------------
        // Determine pixel q in list with minimal cost and remove from
        // active list. Mark q as processed.
        lInd = fFindMinG(pSList, lListInd);
        SQ   = pSList[lInd];
        
        lListInd--;
        pSList[lInd] = pSList[lListInd];
                
        plE[SQ.lLinInd]  = 1;
        
        #ifdef DEBUG
        mexPrintf("Popped Entry: Ind = %u, x = %u, y = %u, g = %f\n", lInd, SQ.sX, SQ.sY, SQ.flG);
        #endif
        // ----------------------------------------------------------------
        
        // ----------------------------------------------------------------
        // Determine neighbourhood of q and loop over it
        sXLowerLim = ifMax(      0, SQ.sX - 1);
        sXUpperLim = ifMin(sNX - 1, SQ.sX + 1);
        sYLowerLim = ifMax(      0, SQ.sY - 1);
        sYUpperLim = ifMin(sNY - 1, SQ.sY + 1);
        for (short sX = sXLowerLim; sX <= sXUpperLim; sX++) {
            for (short sY = sYLowerLim; sY <= sYUpperLim; sY++) {
                // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                // Skip if pixel was already processed
                lLinInd = ifLinInd(sX, sY, sNY);
                if (plE[lLinInd]) continue;
                // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                
                // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                // Compute the new accumulated cost to the neighbour pixel
                if ((abs(sX - SQ.sX) + abs(sY - SQ.sY)) == 1) flWeight = 0.71; else flWeight = 1;
                flThisG = SQ.flG + float(pdF[lLinInd])*flWeight;
                // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                
                #ifdef DEBUG
                mexPrintf("R element N: x = %u, y = %u, lin = %u, g = %f\n", sX, sY, lLinInd, flThisG);
                #endif
                
                // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                // Check whether r is already in active list and if the
                // current cost is lower than the previous
                lInd = fFindLinInd(pSList, lListInd, lLinInd);
                if (lInd >= 0) {
                    SR = pSList[lInd];
                    if (flThisG < SR.flG) {
                        SR.flG = flThisG;
                        pSList[lInd] = SR;
                        plPX[lLinInd] = char(SQ.sX - sX);
                        plPY[lLinInd] = char(SQ.sY - sY);
                    }
                } else {
                    // - - - - - - - - - - - - - - - - - - - - - - - - - -
                    // If r is not in the active list, add it!
                    SR.sX = sX;
                    SR.sY = sY;
                    SR.lLinInd = lLinInd;
                    SR.flG = flThisG;
                    pSList[lListInd++] = SR;
                    plPX[lLinInd] = char(SQ.sX - sX);
                    plPY[lLinInd] = char(SQ.sY - sY);
                    // - - - - - - - - - - - - - - - - - - - - - - - - - -
                }
            }
            // End of the neighbourhood loop.
            // ----------------------------------------------------------------
        }
        lNPixelsProcessed++;
    }
    // End of while loop
    // --------------------------------------------------------------------
    
    #ifdef DEBUG
    mexPrintf("%u pixels processed.\n", lNPixelsProcessed);
    #endif
    
    mxFree(plE);
    mxFree(pSList);
}
// ========================================================================
// *** END OF MAIN MEX FUNCTION fLiveWireCalcP
// ========================================================================