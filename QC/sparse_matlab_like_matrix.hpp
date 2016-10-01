#ifndef SPARSE_MATLAB_LIKE_ARR_HPP_
#define SPARSE_MATLAB_LIKE_ARR_HPP_

#ifdef MATLAB_MEX_FILE
#include <mex.h>
#else
#include <vector>
#include "ind_sim_pair.hpp"
#endif

///================================================================================================
/// A Matlab-like sparse matrix representation.
/// The representation is called "compressed column sparse format".
/// That is, it stores:
/// 1. sr: an array of non-zero data (top-to-bottom, then left-to-right-bottom) 
/// 2. irs: an array of the row indices corresponding to the data entries.
/// 3. jcs: an array of val indexes where each column starts.
/// There are two implementations, one for C++ usage and one for Matlab mex file usage
/// (if MATLAB_MEX_FILE is defined)
///================================================================================================
class sparse_matlab_like_matrix {

#ifdef MATLAB_MEX_FILE
private:
    double* _sr;
    size_t* _irs;
    size_t* _jcs;
public:
    ///------------------------------------------------------------------
    /// Constructor from Matlab format which just wrap it.
    /// Data is not copied into sparse_matlab_like_matrix
    ///------------------------------------------------------------------
    sparse_matlab_like_matrix(const mxArray* arr) :
        _sr(mxGetPr(arr)), _irs(mxGetIr(arr)), _jcs(mxGetJc(arr)) {}
    ///------------------------------------------------------------------
#else
private:
    std::vector<double> _srv;
    std::vector<size_t> _irsv;
    std::vector<size_t> _jcsv;
public:
    ///------------------------------------------------------------------
    /// Constructor from one dimensional array which is actually an NxN
    /// matrix. The constructor copies only the non-zero data.
    ///------------------------------------------------------------------
    sparse_matlab_like_matrix(const double* data, size_t N) {
        size_t nzmax= 0;
        for (size_t i= 0; i<N*N; ++i) {
            if (data[i]!=0.0) ++nzmax;
        }
        _srv.resize(nzmax);
        _irsv.resize(nzmax);
        _jcsv.resize(N+1);
        size_t sparseInd= 0;
        size_t data_i= 0;
        for (size_t c=0; c<N; ++c) {
            _jcsv[c]= sparseInd;
            for (size_t r=0; r<N; ++r) {
                if (data[data_i]!=0.0) {
                    _srv[sparseInd]= data[data_i];
                    _irsv[sparseInd]= r;
                    ++sparseInd;
                }
                ++data_i;
            } // r
        } // c
        _jcsv[N]= sparseInd;
    } // ctor
    ///------------------------------------------------------------------

    ///------------------------------------------------------------------
    /// Constructor from a vector of vectors format, where each vector A[c]
    /// contains pairs of _ind and _sim, which means that index c is similar
    /// with degree of _sim to index _ind.
    ///
    /// Note that A is treated as if it is transposed from the regular format,
    /// if A is symmetric this has no meaning.
    ///------------------------------------------------------------------
    sparse_matlab_like_matrix(std::vector< std::vector<ind_sim_pair> >& A) {
        size_t nzmax= 0;
        for (size_t i= 0; i<A.size(); ++i) {
            nzmax+=A[i].size();
        }
        _srv.resize(nzmax);
        _irsv.resize(nzmax);
        _jcsv.resize(A.size()+1);
        size_t sparseInd= 0;
        for (size_t c=0; c<A.size(); ++c) {
            _jcsv[c]= sparseInd;
            for (size_t r_i=0; r_i<A[c].size(); ++r_i) {
                if (A[c][r_i]._sim!=0.0) {
                    _srv[sparseInd]= A[c][r_i]._sim;
                    _irsv[sparseInd]= A[c][r_i]._ind;
                    ++sparseInd;
                }
            } // r_i
        } // c
        _jcsv[A.size()]= sparseInd;
    } // ctor
    ///------------------------------------------------------------------
    
#endif

    
public:

    ///------------------------------------------------------------------
    /// Returns a pointer to the first element in the sr array.
    /// sr array contains all the non-zero data in the sparse matrix.
    /// See mxGetPr
    ///------------------------------------------------------------------
    const double* sr() const {
#ifdef MATLAB_MEX_FILE
        return _sr;
#else
        return &(_srv[0]);
#endif
    }

    ///------------------------------------------------------------------
    /// Returns a pointer to the first element in the irs array.
    /// irs array contains row indices corresponding to the
    /// non-zeros element in the sr array.
    /// See mxGetIr
    ///------------------------------------------------------------------
    const size_t* irs() const {
#ifdef MATLAB_MEX_FILE
        return _irs;
#else
        return &(_irsv[0]);
#endif
    }
    
    ///------------------------------------------------------------------
    /// Returns a pointer to the first element in the jc array.
    /// jc array contains as c element the index to irs array where row indices for c column begin,
    /// and in c+1 element the index to irs array where row indices for c column one-after-the-end.
    /// See mxGetJc
    ///------------------------------------------------------------------
    const size_t* jcs() const {
#ifdef MATLAB_MEX_FILE
        return _jcs;
#else
        return &(_jcsv[0]);
#endif
    }
    
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
