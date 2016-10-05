#ifndef __HELPER_FUNCTIONS_H__
#define __HELPER_FUNCTIONS_H__

#include <math.h>
#include <vector>
#include <algorithm>
#include <set>
#include <iterator>


using namespace std;

bool findValVec(vector<int> Labels, int i)				// Whether a given integer is present in a vector of integers
{
	unsigned int n;
	bool found = false;
	for(n=0;n < Labels.size();n++)
		if(Labels[n] == i)
			found = true;

	return found;
}

double diffVec(vector<double> V1, vector<double> V2)	// returns L2-distance between two 3-vectors
{
	return pow((V1[1]-V2[1])*(V1[1]-V2[1]) + (V1[2]-V2[2])*(V1[2]-V2[2]) + (V1[3]-V2[3])*(V1[3]-V2[3]), 0.5);	

}

double minVecD(vector< vector<double> > CClusters, vector<double> MeanColors)	// Given a 3-vector, this function finds its closest 3-vector from among a vector of 3-vectors in the L2-distance norm
{
	double minVal = diffVec(CClusters[0],MeanColors);
	unsigned int i;
	double tmpVal;
	for(i=0;i<CClusters.size();i++)
	{
		tmpVal = diffVec(CClusters[i],MeanColors);
		minVal = (minVal<tmpVal)? minVal : tmpVal;
	}
	return minVal;
}


#endif