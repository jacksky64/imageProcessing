#ifndef SPARSE_VECTOR_CONSTANT_TIME_ACCESS_ELEMENT_HPP_
#define SPARSE_VECTOR_CONSTANT_TIME_ACCESS_ELEMENT_HPP_

#include "ind_val_pair.hpp"
#include <cassert>
#include <vector>
#include <cstdlib>

///--------------------------------------------------------------------------
/// This class represent a sparse vector that its elements can be accessed
/// with O(1) (constant) time complexity.
/// The full vector size, that is the maximum possible index plus one, has
/// to be known in advance.
///--------------------------------------------------------------------------
class sparse_vector_constant_time_access_element {

    // a vector of pairs of indices and their corresponding values
    std::vector<ind_val_pair> _data;
    
    // where is the index in _data for the given ind (if initialized).
    int* _inds;

    // The maximum possible index plus one
    int _full_vector_size;


    
    // Checks if i is legal and if yes, verifies if it was initialized
    bool IsIndInitialized(int i) const {
        int indInData= _inds[i];
        return ((indInData<_data.size())&&
                (indInData>=0)&&
                (_data[indInData]._ind==i));
    } // IsIndInitialized
    
    // Currently I did not implement this two, so I made them private.
    sparse_vector_constant_time_access_element(const sparse_vector_constant_time_access_element& other) : _data(other._data) {assert(0);}
    sparse_vector_constant_time_access_element& operator=(const sparse_vector_constant_time_access_element& other) {assert(0); return *this;}
    
public:

    ///--------------------------------------------------------------------------------
    /// Constructs an empty sparse_vector_constant_time_access_element,
    /// full_vector_size: the maximum possible index plus one.
    /// Time complexity: O(1)
    /// Memory complexity: O(maximumIndsSize)
    //--------------------------------------------------------------------------------
    sparse_vector_constant_time_access_element(int full_vector_size) 
        : _data(),
          _inds((int*)malloc((full_vector_size)*sizeof(_inds[0]))),
          _full_vector_size(full_vector_size) {
    } 
    //--------------------------------------------------------------------------------

    
    ///--------------------------------------------------------------------------------
    /// Destructor
    ///--------------------------------------------------------------------------------
    ~sparse_vector_constant_time_access_element() {
        free(_inds);
    }
    //--------------------------------------------------------------------------------

    
    ///--------------------------------------------------------------------------------
    /// Clears the old data stored in this sparse_vector_constant_time_access_element
    /// and initialized its data to the given data
    /// Time complexity: O(data.size())
    /// Memory complexity: O(data.size())
    ///--------------------------------------------------------------------------------
    void clear_and_init_data(const std::vector<ind_val_pair>& data) {
        
        _data= data;
        for (int i=0; i<_data.size(); ++i) {
            assert( _data[i]._ind < full_vector_size() );
            assert( _data[i]._ind > 0 );
            _inds[ _data[i]._ind ]= i;
        }
    }
    //--------------------------------------------------------------------------------

        

    
    ///--------------------------------------------------------------------------------
    /// Access to the data.
    /// That is the vector of all possible non-zero indices and their value.
    /// Indices that are not stored in data are always zeros, but data values can also
    /// be zeros.
    /// 
    /// Note that a const reference is returned as writing into the original data
    /// will invalidate the sparse_vector_constant_time_access_element. Changing
    /// sparse_vector_constant_time_access_element is possible through the non-const
    /// operator[].
    ///--------------------------------------------------------------------------------
    const std::vector<ind_val_pair>& data() const {
        return _data;
    }
    //--------------------------------------------------------------------------------

    ///--------------------------------------------------------------------------------
    /// Returns a copy of the element at position i (even if it is zero)
    /// Time complexity: O(1)
    ///
    /// Note that I return by value as I use double. If copying is undesired, a proxy
    /// will have to be used.
    ///--------------------------------------------------------------------------------
    double operator[](int i) const {
        assert( i<full_vector_size() );
        if (!IsIndInitialized(i)) return 0.0;
        int indInData= _inds[i]; 
        return _data[indInData]._val;
    }
    //--------------------------------------------------------------------------------

    ///--------------------------------------------------------------------------------
    /// Returns a reference of the element at position i (even if it is zero)
    /// Time complexity: O(1)
    ///
    /// Note that this method might enlarge the data in it.
    ///--------------------------------------------------------------------------------
    double& operator[](int i) {
        assert( i<full_vector_size() );
        if (IsIndInitialized(i)) {
            int indInData= _inds[i];
            return _data[indInData]._val;
        }
        _inds[i]= _data.size(); // we are going now to add it
        _data.push_back( ind_val_pair(i,0.0) ); // adds 0.0, but usually it will be used v[i]= ...
        return (_data.back())._val;
    }
    //--------------------------------------------------------------------------------

    
    ///--------------------------------------------------------------------------------
    /// Returns the maximum possible index plus one which can be stored in data.
    ///--------------------------------------------------------------------------------
    int full_vector_size() {
        return _full_vector_size;
    }
    //--------------------------------------------------------------------------------
    
}; // end class
    

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
