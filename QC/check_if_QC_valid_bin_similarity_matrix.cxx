#include "mex.h"

#ifndef MATLAB_MEX_FILE
#define MATLAB_MEX_FILE
#endif

#include "sparse_matlab_like_matrix.hpp"

void mexFunction(int nout, mxArray *out[],
                 int nin, const mxArray *in[]) {

    size_t N= mxGetN(in[0]);
    if (N!=mxGetM(in[0])) {
        mexErrMsgTxt("A number of rows and columns should be equal");
    }
       
    if (mxIsSparse(in[0])) {
        //--------------------------------------------------------------------------
        // is sparse
        //--------------------------------------------------------------------------
        sparse_matlab_like_matrix A(in[0]);
        
        size_t sparseInd= 0;
        for (size_t c= 0; c<N; ++c) {

            size_t rb= A.jcs()[c];
            size_t re= A.jcs()[c+1];

            // find Acc
            double Acc= 0.0;
            size_t r= rb;
            size_t old_sparseInd= sparseInd;
            while (r<re) {
                if (A.irs()[r]==c) {
                    Acc= A.sr()[sparseInd];
                    break;
                }
                ++sparseInd;
                ++r;
            }

            // check Acc>=Arc>=0 for all r
            sparseInd= old_sparseInd;
            for (size_t r= rb; r<re; ++r) {
                if ( A.sr()[sparseInd] < 0.0 ) {
                    goto errMsgLabel1;
                }
                if ( Acc < A.sr()[sparseInd] ) {
                    goto errMsgLabel2;
                }
                ++sparseInd;
            } // r
        } // c
    } else { 
        //--------------------------------------------------------------------------
        // is full
        //-------------------------------------------------------------------------
        const double* A= static_cast<const double*>( mxGetData(in[0]) );
        for (size_t i= 0; i<N; ++i) {
            double Aii= A[i*N+i];
            for (size_t j= 0; j<N; ++j) {
                if (A[i*N+j]<0.0) {
                    goto errMsgLabel1;
                }
                if (Aii<A[i*N+j]) {
                    goto errMsgLabel2;
                }
            } // j
        } // i
    } // is full
    return;
    
errMsgLabel1:
    mexErrMsgTxt("For all i,j it should be A(i,i)>=0");
errMsgLabel2:
    mexErrMsgTxt("For all i,j it should be A(i,i)>=A(i,j) (an element is most similar to itself), but it is not.");
        
}


// Copyright (c) 2010, Ofir Pele
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//    * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//    * Neither the name of the The Hebrew University of Jerusalem nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
