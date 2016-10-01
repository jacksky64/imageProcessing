// has:
#include <vector>
#include "ind_val_pair.hpp"
#include "tictoc.hpp"
#include "ind_sim_pair.hpp"
// use:
#include "sparse_similarity_matrix_utils.hpp"
#include "QC_sparse_sparse.hpp"
#include <iostream>
#include <cmath>
// for comparison with QC_full_sparse:
#include "sparse_matlab_like_matrix.hpp"
#include "QC_full_sparse.hpp"

/// This demo efficiently computes the QC histogram distance between two sparse histograms,
/// with a sparse bin-similarity matrix. This can be useful for bag-of-words/bag-of-features models.
/// The demo also compares sparse_sparse computation to full_sparse computation
/// (in regards to results and run-time).
/// For more details on this distance see the paper:
///  The Quadratic-Chi Histogram Distance Family
///  Ofir Pele, Michael Werman
///  ECCV 2010
/// See also the Matlab code documentation - QC.m.
int main( int argc, char* argv[]) {

    // sparse-sparse computation is very fast, so I repeat it several times
    // to get a reasonable time measurement.
    const int SPARSE_SPARSE_COMPUTATIONS_NUM= 100000;
    
    // This is the size of the histograms if they were full.
    // If this is used for a bag-of-words experiments,
    // full_histograms_size is the number of words
    // (which should probably be much higher).
    const int full_histograms_size= 1000000;

    // P,Q: sparse histograms
    std::vector<ind_val_pair> P;
    std::vector<ind_val_pair> Q;
    P.push_back( ind_val_pair(0,9.0) );
    Q.push_back( ind_val_pair(0,10.0) );
    P.push_back( ind_val_pair(2,3.0) );
    Q.push_back( ind_val_pair(2,2.2) );

    // A: sparse similarity matrix
    tictoc timer;
    timer.tic();

    std::vector< std::vector<ind_sim_pair> > A(full_histograms_size);

    for (int i=0; i<full_histograms_size; ++i) A[i].push_back( ind_sim_pair(i,1.0) );
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 0,1, 0.2); // A(0,1)= 0.2 and A(1,0)= 0.2
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 0,2, 0.1);
    sparse_similarity_matrix_utils::insert_into_A_symmetric_sim(A, 3,4, 0.2);

    QC_sparse_sparse qc_sparse_sparse(A);

    timer.toc();
    std::cout << "Sparse bin-similarity matrix initialization and copying into QC_sparse_sparse object running time == " << timer.totalTimeMilliSec() << "ms" <<std::endl;
    std::cout << "Note that the above step can be done once for comparison of many histograms." << std::endl;
    std::cout << std::endl;
    
    // The normalization factor
    double m= 0.9;

    timer.clear();
    timer.tic();
    double dist_sparse_sparse;
    for (int ci=0; ci<SPARSE_SPARSE_COMPUTATIONS_NUM; ++ci) {
        dist_sparse_sparse= qc_sparse_sparse(P, Q, m);
    }
    timer.toc();
    std::cout << "QC_sparse_sparse histogram distance computation time == " << timer.totalTimeMilliSec()/SPARSE_SPARSE_COMPUTATIONS_NUM << "ms" << std::endl;
    std::cout << std::endl;
    
    
    //==============================================================================
    // Comparison with QC_full_sparse
    //==============================================================================
    std::vector<double> Pfull(full_histograms_size);
    std::vector<double> Qfull(full_histograms_size);
    for (int i=0; i<P.size(); ++i) {
        Pfull[ P[i]._ind ]= P[i]._val;
    }
    for (int i=0; i<Q.size(); ++i) {
        Qfull[ Q[i]._ind ]= Q[i]._val;
    }

    // Conversion to Matlab-like format
    sparse_matlab_like_matrix Amat(A);

    QC_full_sparse qc_full_sparse;
    timer.clear();
    timer.tic();
    double dist_full_sparse= qc_full_sparse(&(Pfull[0]), &(Qfull[0]), Amat, m, Pfull.size());
    timer.toc();
    std::cout << "C_full_sparse histogram distance computation time == " << timer.totalTimeMilliSec() << "ms" << std::endl;
    //==============================================================================

    std::cout << std::endl << "The QC distance is " << dist_full_sparse << "==" << dist_sparse_sparse << std::endl;
        
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
