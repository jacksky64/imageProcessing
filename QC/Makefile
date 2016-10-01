#########################################################
# compiler stuff 
#########################################################
CXX= g++
CC= gcc
CXXFLAGS = -Wall -O -DNDEBUG
# extra flags that do not work with mex
CPPFLAGS = -Wno-sign-compare
# extra flags that do not work with c++
MEXFLAGS= -largeArrayDims
MEXEXT = $(shell mexext)
# These two are my personnal conventions
MEXSRCEXT = cxx
CPPSRCEXT = cpp
#########################################################


##########################################################
# sources files - c++
##########################################################
CPPEXE1 = demo_QC_full_sparse
CPPEXE2 = demo_QC_sparse_sparse

CPPSRCS1 = $(CPPEXE1).$(CPPSRCEXT)
CPPSRCS2 = $(CPPEXE2).$(CPPSRCEXT)

CPPSRCS = $(CPPSRCS1) $(CPPSRCS2)
##########################################################



##########################################################
# sources files - mex, matlab 
##########################################################
MEXNAME1= QC_full_sparse
MEXNAME2= fast_color_spatial_ground_similarity_pruning
MEXNAME3= fast_sift_bin_similarity_matrix
MEXNAME4= check_if_QC_valid_bin_similarity_matrix

MEXEXE1= $(MEXNAME1).$(MEXEXT)
MEXEXE2= $(MEXNAME2).$(MEXEXT)
MEXEXE3= $(MEXNAME3).$(MEXEXT)
MEXEXE4= $(MEXNAME4).$(MEXEXT)

MEXSRCS= $(MEXNAME1).$(MEXSRCEXT) $(MEXNAME2).$(MEXSRCEXT) $(MEXNAME3).$(MEXSRCEXT) $(MEXNAME4).$(MEXSRCEXT) 
##########################################################


#########################################################
# actions
#########################################################

ALLEXE = $(MEXEXE1) $(MEXEXE2) $(MEXEXE3) $(MEXEXE4) $(CPPEXE1) $(CPPEXE2)

all: $(ALLEXE)

$(CPPEXE1): $(subst .cpp,.o,$(CPPSRCS1))
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $^ -o $@

$(CPPEXE2): $(subst .cpp,.o,$(CPPSRCS2))
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $^ -o $@

# Automatic conversion from cxx to mex executables
%.$(MEXEXT): %.$(MEXSRCEXT)
	mex CXX=$(CXX) CC=$(CXX) LD=$(CXX) COMPFLAGS='$(CXXFLAGS)' $(MEXFLAGS) $<

clean:
	rm *.o $(ALLEXE)  -f


depend: $(CPPSRCS) $(MEXSRCS) 
	makedepend  -- -Y $(CXXFLAGS) -- $^

.PHONY: all clean depend

# DO NOT DELETE THIS LINE -- make depend depends on it.

demo_QC_full_sparse.o: sparse_matlab_like_matrix.hpp ind_sim_pair.hpp
demo_QC_full_sparse.o: QC_full_sparse.hpp QC_utils.hpp
demo_QC_sparse_sparse.o: ind_val_pair.hpp tictoc.hpp ind_sim_pair.hpp
demo_QC_sparse_sparse.o: sparse_similarity_matrix_utils.hpp
demo_QC_sparse_sparse.o: QC_sparse_sparse.hpp
demo_QC_sparse_sparse.o: sparse_vector_constant_time_access_element.hpp
demo_QC_sparse_sparse.o: sparse_matlab_like_matrix.hpp QC_full_sparse.hpp
demo_QC_sparse_sparse.o: QC_utils.hpp
QC_full_sparse.o: sparse_matlab_like_matrix.hpp ind_sim_pair.hpp
QC_full_sparse.o: OP_mex_utils.hxx QC_full_sparse.hpp QC_utils.hpp
fast_color_spatial_ground_similarity_pruning.o: deltaE2000.hpp
check_if_QC_valid_bin_similarity_matrix.o: sparse_matlab_like_matrix.hpp
check_if_QC_valid_bin_similarity_matrix.o: ind_sim_pair.hpp
