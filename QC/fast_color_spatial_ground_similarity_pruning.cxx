#include "mex.h"
#include "deltaE2000.hpp"
#include <algorithm>
#include <vector>


class fast_color_spatial_ground_similarity_pruning_utils {

public:
     
    static void update_output
    (int x1, int y1, // for spatial dist
     int x2b, int x2e, int y2b, int y2e, // coordinates limits
     int r_add, // how much to add to get the right r (row) index
     int im_X, int im_Y, 
     double L1, double a1, double b1,
     double alpha_color, double alpha_spatial,
     double threshold, double spatial_threshold,
     const double* imb,
     double* sr, mwIndex* irs, int& sparseInd) {

        for (int x2=x2b; x2<=x2e; ++x2) {
            for (int y2=y2b; y2<=y2e; ++y2) {

                int r= r_add + (x2*im_Y + y2);
                
                mxAssert(x2<im_X,"index out of bound");
                mxAssert(y2<im_Y,"index out of bound");
                
                double L2= imb[(y2)+((x2)+(0)*im_X)*im_Y];
                double a2= imb[(y2)+((x2)+(1)*im_X)*im_Y];
                double b2= imb[(y2)+((x2)+(2)*im_X)*im_Y];
                
                double x_diff= x1-x2;
                double y_diff= y1-y2;
                double spatial_dist= (sqrt( (x_diff*x_diff) + (y_diff*y_diff) ));
                
                if (spatial_dist<=spatial_threshold) {
                    double color_dist= deltaE2000()(L1,a1,b1, L2,a2,b2);
                    
                    double dist= alpha_color*color_dist + alpha_spatial*spatial_dist;
                    
                    if (dist<threshold) {
                        mxAssert(sparseInd<nzmax,"computation of nzmax or sparseInd is wrong");
                        sr[sparseInd]= 1.0-(dist/threshold);
                        irs[sparseInd]= r;
                        ++sparseInd;
                    }
                }
                
            } // y2
        } // x2

    } // update_output
};

void mexFunction(int nout, mxArray *out[],
                 int nin, const mxArray *in[]) {

    //----------------------------------------------------------------------
    // extract input
    //----------------------------------------------------------------------
    const double* im1= static_cast<double*>( mxGetData(in[0]) );
    const mwSize* im1_dims= mxGetDimensions(in[0]);
    mwSize im1_ndims= mxGetNumberOfDimensions(in[0]);
    const double* im2= static_cast<double*>( mxGetData(in[1]) );
    const mwSize* im2_dims= mxGetDimensions(in[1]);
    mwSize im2_ndims= mxGetNumberOfDimensions(in[1]);

    if (im1_ndims!=3||im2_ndims!=3||im1_dims[2]!=3||im2_dims[2]!=3) {
        mexErrMsgTxt("im1_lab and im2_lab should be 3d L*a*b* images");
    }
        
    int im_X= im1_dims[1];
    int im_Y= im1_dims[0];
    int im_N= im_Y*im_X;
    int N= 2*im_N;
    if (im_X!=im2_dims[1]||im_Y!=im2_dims[0]) {
        mexErrMsgTxt("im1_lab and im2_lab should be of the same size");
    }
    
    double alpha_color= *( static_cast<double*>( mxGetData(in[2]) ));
    double alpha_spatial= 1-alpha_color;

    double threshold=  *( static_cast<double*>( mxGetData(in[3]) ));
    
    // if spatial_dist>spatial_threshold -> similarity=0
    double spatial_threshold=  *( static_cast<double*>( mxGetData(in[4]) ));
    //----------------------------------------------------------------------

    
    //----------------------------------------------------------------------
    // create and fill output
    //----------------------------------------------------------------------
    int win_length= 2*spatial_threshold+1;
    int win_area= win_length*win_length;
    // It's (N*2)*win_area as we need:
    // (im1_N*win_area) + (im1_N*win_area) + (im2_N*win_area) + (im2_N*win_area)
    // For each of the 1/4 in the ground distance matrix. Which equals to:
    // (2*(im1_N+im2_N))*win_area= 2*N
    // Can compute something more tighter (circle instead of square...)
    int nzmax= N*2*win_area;
    out[0] = mxCreateSparse(N,N,nzmax,mxREAL);
    double* sr= mxGetPr(out[0]);
    mwIndex* irs= mxGetIr(out[0]);
    mwIndex* jcs= mxGetJc(out[0]);

    // ground distance matrix
    // 0 ... im1_N             | im1_N+1 ... im1_N+im2_N-1 (N-1)
    // .                       |
    // .                       |
    // .                       |
    // im1_N                   |
    // ----------------------------------------------------------
    // im1_N+1                 |
    // .                       |
    // .                       |
    // .                       |
    // im1_N+im2_N-1 (N-1)     |
    int sparseInd= 0;
    for (int c=0; c<N; ++c) {

        jcs[c]= sparseInd;

        int x1,y1;
        const double* ima= NULL;
        // extract x1,y1 and ima
        if (c<im_N) {
            ima= im1;
            x1= c/im_Y;
            y1= c%im_Y;
        } else {
            ima= im2;
            x1= (c-im_N)/im_Y;
            y1= (c-im_N)%im_Y;
        }
        
        mxAssert(x1<ima_X,"1");
        mxAssert(y1<ima_Y,"2");

        double L1= ima[(y1)+((x1)+(0)*im_X)*im_Y];
        double a1= ima[(y1)+((x1)+(1)*im_X)*im_Y];
        double b1= ima[(y1)+((x1)+(2)*im_X)*im_Y];

        // limits
        double d_x2b= x1-spatial_threshold;
        double d_y2b= y1-spatial_threshold;
        int x2b= std::max(0,static_cast<int>(floor(d_x2b)));
        int y2b= std::max(0,static_cast<int>(floor(d_y2b)));
        double d_x2e= x1+spatial_threshold;
        double d_y2e= y1+spatial_threshold;
        int x2e= std::min(im_X-1,static_cast<int>(ceil(d_x2e)));
        int y2e= std::min(im_Y-1,static_cast<int>(ceil(d_y2e)));

        //---------------------------------------------------
        // for im1
        //---------------------------------------------------
        const double* imb= im1;
        int r_add= 0;
        fast_color_spatial_ground_similarity_pruning_utils::update_output
            (x1,y1,
             x2b,x2e,y2b,y2e,
             r_add,
             im_X, im_Y,
             L1,a1,b1,
             alpha_color, alpha_spatial,
             threshold, spatial_threshold,
             imb,
             sr, irs, sparseInd);
        //---------------------------------------------------

        //---------------------------------------------------
        // for im2
        //--------------------------------------------------
        imb= im2;
        r_add= im_N;
        fast_color_spatial_ground_similarity_pruning_utils::update_output
            (x1,y1,
             x2b,x2e,y2b,y2e,
             r_add,
             im_X, im_Y,
             L1,a1,b1,
             alpha_color, alpha_spatial,
             threshold, spatial_threshold,
             imb,
             sr, irs, sparseInd);
        //---------------------------------------------------
                
    } // for c
    jcs[N]= sparseInd;
    
} // mexFunction





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
