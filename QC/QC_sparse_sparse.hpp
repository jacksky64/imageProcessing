#ifndef QC_SPARSE_SPARSE_HPP_
#define QC_SPARSE_SPARSE_HPP_

#include "ind_val_pair.hpp"
#include "ind_sim_pair.hpp"
#include "sparse_vector_constant_time_access_element.hpp"

#include <cmath>    // used for pow
#include <vector>   // fields

///===================================================================================================
/// This class efficiently computes the QC histogram distance between two sparse histograms,
/// with a sparse bin-similarity matrix. This can be useful for bag-of-words/bag-of-features models.
/// For more details on this distance see the paper:
///  The Quadratic-Chi Histogram Distance Family
///  Ofir Pele, Michael Werman
///  ECCV 2010
/// See also the Matlab code documentation - QC.m.
///===================================================================================================
class QC_sparse_sparse {

    // The bin-similarity matrix (A in ECCV paper)
    std::vector< std::vector<ind_sim_pair> > _A;

    // Helper arrays
    mutable sparse_vector_constant_time_access_element D;
    mutable sparse_vector_constant_time_access_element Ps;
    mutable sparse_vector_constant_time_access_element Qs;
    
public:

    ///--------------------------------------------------------------------------------
    /// Constructor. Gets as an input a sparse bin-similarity matrix.
    /// Note: the constructor and computation of A can be time consuming.
    /// However, they can be done once for the comparison of many histograms.
    ///--------------------------------------------------------------------------------
    QC_sparse_sparse(const std::vector< std::vector<ind_sim_pair> >& A) :
        _A(A),
        D(A.size()),
        Ps(A.size()),
        Qs(A.size())
        {}
    //--------------------------------------------------------------------------------
    
    
    ///--------------------------------------------------------------------------------
    /// Computes the QC distance. See also QC.m documentation.
    /// P,Q: Two sparse histograms.
    /// m: the normalization factor (large m correspond to a large reduction of
    ///    large bins effect).
    ///    In paper used 0.5 (QCS) or 0.9 (QCN).
    ///    Pre-condition: 0 <= m < 1, otherwise not continuous.
    ///--------------------------------------------------------------------------------
    double operator()(const std::vector< ind_val_pair >& P,
                      const std::vector< ind_val_pair >& Q,
                      double m) const {
        
        // P-Q
        D.clear_and_init_data(P);
        for (int i=0; i<Q.size(); ++i) {
            D[ Q[i]._ind ]-= Q[i]._val;
        }
        
        Ps.clear_and_init_data(P);
        Qs.clear_and_init_data(Q);
                
        // The normalization factor should be computed
        // only where D[i] is not zero.
        // D= (P-Q)./((P+Q)*A)
        for (int di=0; di<D.data().size(); ++di) {
            int i= ((D.data())[di])._ind;
            double Di= ((D.data())[di])._val;
            if (Di==0.0) continue;
            double normalizationFactor= 0.0;
            for (int ci=0; ci<_A[i].size(); ++ci) {
                int c= _A[i][ci]._ind;
                normalizationFactor+= (Ps[c]+Qs[c])*_A[i][ci]._sim;
            }
            D[i]/= pow(normalizationFactor,m);
        }
        
        // Final computation of dist:
        // sum_i D_i sum_j A_ij D_j
        double dist= 0.0;
        for (int di=0; di<D.data().size(); ++di) {
            int i= ((D.data())[di])._ind;
            double Di= ((D.data())[di])._val;
            for (int ji=0; ji<_A[i].size(); ++ji) {
                int j= _A[i][ji]._ind;
                double Aij= _A[i][ji]._sim;
                double Dj= D[j];
                dist+= Di*Dj*Aij;
            }
        }
        
        if (dist<0.0) {
            return 0.0;
        }
        
        return sqrt(dist);
        
    } // end operator()
    //--------------------------------------------------------------------------------


    
};
//============================================================
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
