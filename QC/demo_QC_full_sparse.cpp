#include "sparse_matlab_like_matrix.hpp"
#include "QC_full_sparse.hpp"
#include <iostream>
#include "ind_sim_pair.hpp"
#include "sparse_similarity_matrix_utils.hpp"

/// This demo efficiently computes the QC histogram distance between two full histograms,
/// with a sparse bin-similarity matrix.
/// For more details on this distance see the paper:
///  The Quadratic-Chi Histogram Distance Family
///  Ofir Pele, Michael Werman
///  ECCV 2010
/// See also the Matlab code documentation - QC.m.
int main( int argc, char* argv[]) {

    // The two histograms
    double P[]= {9.0,  0.0, 3.0, 0.0, 0.0};
    double Q[]= {10.0, 0.0, 2.2, 0.0, 0.0};
    size_t N= sizeof(P)/sizeof(P[0]);
    
    // Similarity matrix
    std::vector< std::vector<ind_sim_pair> > A(N);
    for (int i=0; i<N; ++i) A[i].push_back( ind_sim_pair(i,1.0) );
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 0,1, 0.2); // A(0,1)= 0.2 and A(1,0)= 0.2
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 0,2, 0.1);
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 3,4, 0.2);
    //    1.0, 0.2, 0.1, 0.0, 0.0,
    //    0.2, 1.0, 0.0, 0.0, 0.0,
    //    0.1, 0.0, 1.0, 0.0, 0.0,
    //    0.0, 0.0, 0.0, 1.0, 0.2,
    //    0.0, 0.0, 0.0, 0.2, 1.0
    
    // The normalization factor
    double m= 0.9;

    QC_full_sparse qc_full_sparse;
    std::cout << "The QC histogram distance between P and Q is: " <<
        qc_full_sparse(P, Q, A, m, N) << std::endl;

    return 0;
} // end main
    
    
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

