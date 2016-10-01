#ifndef QC_FULL_SPARSE_HPP
#define QC_FULL_SPARSE_HPP

#include <vector>
#include <cmath>
#include "sparse_matlab_like_matrix.hpp"
#include "QC_utils.hpp"

///===================================================================================================
/// This class efficiently computes the QC histogram distance between two full histograms,
/// with a sparse bin-similarity matrix. 
/// For more details on this distance see the paper:
///  The Quadratic-Chi Histogram Distance Family
///  Ofir Pele, Michael Werman
///  ECCV 2010
/// See also the Matlab code documentation - QC.m.
///===================================================================================================
struct QC_full_sparse {

    ///--------------------------------------------------------------------------------
    /// See QC.m for full documentation and demo_QC_full_sparse for an example of usage.
    ///
    /// P,Q: Two full histograms of size N.
    /// A: The bin-similarity matrix. Can also be
    ///    const std::vector< std::vector<ind_sim_pair> >& (should be symmetric in this case)
    ///    or const double* as they are convertible to sparse_matlab_like_matrix
    /// m: the normalization factor (large m correspond to a large reduction of
    ///    large bins effect).
    ///    In paper used 0.5 (QCS) or 0.9 (QCN).
    ///    Pre-condition: 0 <= m < 1, otherwise not continuous.
    ///--------------------------------------------------------------------------------
    double operator()(const double* P, const double* Q, const sparse_matlab_like_matrix& A, double m, size_t N) {

        std::vector<double> D(N, 0.0);
        size_t sparseInd= 0;
        for (size_t i=0; i<N; ++i) {
            double zi= 0.0;
            size_t cb= A.jcs()[i];
            size_t ce= A.jcs()[i+1];
            for (size_t c= cb; c<ce; ++c) {
                zi+= (P[A.irs()[c]]+Q[A.irs()[c]])*A.sr()[sparseInd];
                ++sparseInd;
            } // c
            if (zi!=0.0) D[i]= (P[i]-Q[i])/(pow(zi,m));
        } // i
        
        double dist= 0.0;
        sparseInd= 0;
        for (size_t i=0; i<N; ++i) {
            size_t jb= A.jcs()[i];
            size_t je= A.jcs()[i+1];
            for (size_t j=jb; j<je; ++j) {
                mc_assert((A.irs()[j]<N)&&(A.irs()[j]>=0));
                dist+= D[i]*D[A.irs()[j]]*A.sr()[sparseInd];
                ++sparseInd;
            }
        }

        if (dist<0) {
            return 0.0;
        } else {
            return sqrt(dist);
        }
    } // operator()
    
};

#endif
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
