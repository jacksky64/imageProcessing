#include "mex.h"
#include <algorithm>
#include <cmath>

#ifndef MATLAB_MEX_FILE
#define MATLAB_MEX_FILE
#endif

struct fast_sift_bin_similarity_matrix_utils {
    
     static void update_A_if_needed(double* sr, mwIndex* irs, int& sparseInd,
                             double d_spatial, int o1, int o2b, int o2e, int NBO,
                             double thresh, int y2, int x2, int XNBP) {
         for (int o2= o2b; o2<=o2e; ++o2) {
             double d_orient_abs= fabs(static_cast<double>(o1-o2));
             double d_orient= std::min(NBO-d_orient_abs, d_orient_abs);
             double d= d_orient+d_spatial;
             double a= 1.0-d/thresh;
             if (a>0) {
                 mxAssert(a<=1.0,"a<=1.0");
                 mwIndex r= (y2*XNBP + x2)*NBO + o2;
                 sr[sparseInd]= a;
                 irs[sparseInd]= r;
                 ++sparseInd;
             }
         }
     } // update_A_if_needed
    
};

void mexFunction(int nout, mxArray *out[],
                 int nin, const mxArray *in[]) {

    const int YNBP= static_cast<int>(*(static_cast<const double*>((mxGetData(in[0])))));
    const int XNBP= static_cast<int>(*(static_cast<const double*>((mxGetData(in[1])))));
    const int NBO= static_cast<int>(*(static_cast<const double*>((mxGetData(in[2])))));
    const int N= YNBP*XNBP*NBO;
    const double givenThresh= *(static_cast<const double*>((mxGetData(in[3]))));
    // Takes care of thresh like inf which will cause overflow problems later.
    const double greaterThanMaximumPossibleDistance= sqrt(static_cast<double>(YNBP*YNBP + XNBP*XNBP)) + NBO+1;
    const double thresh= std::min(greaterThanMaximumPossibleDistance,givenThresh);
    
    int win_length= static_cast<int>(ceil(2.0*(thresh)+1.0));
    int nzmax= std::min(N*N,N*(win_length*win_length*win_length));
    out[0] = mxCreateSparse(N,N,nzmax,mxREAL);
    double* sr= mxGetPr(out[0]);
    mwIndex* irs= mxGetIr(out[0]);
    mwIndex* jcs= mxGetJc(out[0]);

    int c= 0;
    int sparseInd= 0;
    for (int y1= 0; y1<YNBP; ++y1) {
        for (int x1= 0; x1<XNBP; ++x1) {
            for (int o1= 0; o1<NBO; ++o1) {

                jcs[c]= sparseInd;
                
                int y2b= static_cast<int>(floor(std::max(0.0,      y1-thresh)));
                int y2e= static_cast<int>(ceil(std::min(YNBP-1.0, y1+thresh))); 
                for (int y2= y2b; y2<=y2e; ++y2) {
                    
                    int x2b= static_cast<int>(floor(std::max(0.0,      x1-thresh)));
                    int x2e= static_cast<int>(ceil(std::min(XNBP-1.0, x1+thresh)));
                    for (int x2= x2b; x2<=x2e; ++x2) {

                        double y_diff= y1-y2;
                        double x_diff= x1-x2;
                        double d_spatial= sqrt( x_diff*x_diff + y_diff*y_diff );

                        // left
                        int o2b= 0;
                        int o2e= static_cast<int>(ceil(std::min(NBO-1.0, ((o1+thresh) - NBO))));
                        fast_sift_bin_similarity_matrix_utils::update_A_if_needed
                            (sr, irs, sparseInd,
                             d_spatial, o1, o2b, o2e, NBO, thresh, y2, x2, XNBP);
                        // middle
                        o2b= std::max((o2e+1), 0);
                        o2b= static_cast<int>(floor(std::max(static_cast<double>(o2b), (o1-thresh))));
                        o2e= static_cast<int>(ceil(std::min(NBO-1.0, (o1+thresh))));
                        fast_sift_bin_similarity_matrix_utils::update_A_if_needed
                            (sr, irs, sparseInd,
                             d_spatial, o1, o2b, o2e, NBO, thresh, y2, x2, XNBP);
                        // right
                        o2b= std::max((o2e+1), 0);
                        o2b= static_cast<int>(floor(std::max(static_cast<double>(o2b), ((o1-thresh) + NBO))));
                        o2e= NBO-1;
                        fast_sift_bin_similarity_matrix_utils::update_A_if_needed
                            (sr, irs, sparseInd,
                             d_spatial, o1, o2b, o2e, NBO, thresh, y2, x2, XNBP);
                        
                    } // x2
                } // y2

                ++c;
                
            } // o1
        } // x1
    } // y1
    jcs[N]= sparseInd;

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
