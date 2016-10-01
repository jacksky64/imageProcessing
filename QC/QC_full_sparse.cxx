#include "mex.h"

#ifndef MATLAB_MEX_FILE
#define MATLAB_MEX_FILE
#endif

#include "sparse_matlab_like_matrix.hpp"
#include "OP_mex_utils.hxx"
#include "QC_full_sparse.hpp"

void mexFunction(int nout, mxArray *out[],
                 int nin, const mxArray *in[]) {

    const double* P= static_cast<const double*>( mxGetData(in[0]) );
    const double* Q= static_cast<const double*>( mxGetData(in[1]) );
    sparse_matlab_like_matrix A(in[2]);
    const double m= *(static_cast<const double*>((mxGetData(in[3]))));
    size_t N= OP_mex_utils::getLength(in[0]);
    
    size_t dims[]= {1};
    out[0]= mxCreateNumericArray(1, dims, mxDOUBLE_CLASS, mxREAL);
    double& dist= *(static_cast<double*>(mxGetData(out[0])));
    dist= QC_full_sparse()(P, Q, A, m, N);

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
