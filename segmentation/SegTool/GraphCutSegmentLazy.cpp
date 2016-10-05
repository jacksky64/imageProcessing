/**************************************************************
GRAPHCUTSEGMENT.CPP - Main graph cuts segmentation C++ function
Authors - Mohit Gupta, Krishnan Ramnath
Affiliation - Robotics Institute, CMU, Pittsburgh
2006-05-15
***************************************************************/

#include <stdio.h>
#include "mex.h"
#include "graph.h"
#include "helper_functions.h"

#define LAMBDA 66 // Relative importance term in definition of energy

 void MakeAdjacencyList(double *L, int numLabels, int numCols, int numRows, vector< set<int> > &neighbors)
{
	int i,j;
	
	neighbors.clear();

	// Declaring the Adjacency list
	for(i=0;i<numLabels;i++)
	{
		set<int> tmp;
		tmp.clear();
		neighbors.push_back(tmp);
	}
	
	
	printf("Adjacency code starts... \n");

	// Filling up the adjacency list
	for(i=0;i<numRows;i++)
		for(j=0;j<numCols;j++)
		{
			int thisLabel = (int) L[j*numRows + i];	// Label of the current pixel
		
			if(thisLabel==-1)							// If this is A watershed Label --> A boundary Pixel
			{
				//printf("%d %d %d \n",i,j,thisLabel);

				// 4-neighborhood
				int UpLabel    = (i>0)            ? (int) L[j*numRows + (i-1)] : thisLabel;
				int DownLabel  = (i<(numRows-1))  ? (int) L[j*numRows + (i+1)] : thisLabel;
				int LeftLabel  = (j>0)            ? (int) L[(j-1)*numRows + i] : thisLabel;
				int RightLabel = (j<(numCols-1))  ? (int) L[(j+1)*numRows + i] : thisLabel;

				// 8-neighborhood
				int NWLabel    = (i>0 && j>0)						? (int) L[(j-1)*numRows + (i-1)] : thisLabel;
				int NELabel    = (i>0 && j<(numCols-1))				? (int) L[(j+1)*numRows + (i-1)] : thisLabel;
				int SELabel    = (i<(numRows-1) && j<(numCols-1))	? (int) L[(j+1)*numRows + (i+1)] : thisLabel;
				int SWLabel    = (i<(numRows-1) && j>0)				? (int) L[(j-1)*numRows + (i+1)] : thisLabel;

				set<int> surround;						// Surrounding Labels of this boundary Label
				
				surround.insert(UpLabel);
				surround.insert(DownLabel);
				surround.insert(LeftLabel);
				surround.insert(RightLabel);
				surround.insert(NWLabel);
				surround.insert(NELabel);
				surround.insert(SELabel);
				surround.insert(SWLabel);

				surround.erase(-1);						// Removing other boundary Labels
				set<int>::iterator pIter, qIter;
				for (pIter = surround.begin(); pIter != surround.end(); pIter++)
					for (qIter = surround.begin(); qIter != surround.end(); qIter++)
					{
						neighbors[*pIter].insert(*qIter);
					}

			}
		}

    for(i=0;i<numLabels;i++)
	{
		(neighbors[i]).erase(i);				// Removing Self Edges from the adjacency list
		
	}
}

Graph* MakeGraph( vector< set<int> > neighbors, vector< vector<double> > MeanColors, vector<int> FLabels, vector<int> BLabels, vector< vector<double> >FCClusters, vector< vector<double> > BCClusters, int numLabels, Graph::node_id *nodes)
{
	//Graph::node_id *nodes = new Graph::node_id[numLabels];
	Graph *G = new Graph();
	int i;
	set<int>::iterator pIter;
	const int K = 10000;					// Edge weight for infinity -- All other edge weights less than 1 -- so it suffices to have this weight as more than sum of all other edges, i.e. >8
	
	vector<double> ForeEdges, BackEdges;
	ForeEdges.clear();
	BackEdges.clear();
	
	printf("graph Making code starts... \n");

	/****** Making Terminal Edge Weights ******/
	for(i=0;i<numLabels;i++)
	{
		if(findValVec(FLabels,i))
		{
			ForeEdges.push_back(K);
			BackEdges.push_back(0);
		}

		else if(findValVec(BLabels,i))
		{
			ForeEdges.push_back(0);
			BackEdges.push_back(K);
		}
			
		else
		{
			double minFD = minVecD(FCClusters, MeanColors[i]);
			double minBD = minVecD(BCClusters, MeanColors[i]);

			ForeEdges.push_back((minBD/(minFD+minBD)));
			BackEdges.push_back((minFD/(minFD+minBD)));
		}
	}

	printf("Terminal Edge Weights Made... \n");

	/******* Start making the graph **************/
	
	// Add Nodes
	for(i=0;i<numLabels;i++)
		nodes[i] = G -> add_node();

	printf("Nodes Added to Graph... \n");

	// Setting Terminal Edge Weights
	for(i=0;i<numLabels;i++)
		G -> set_tweights(nodes[i], ForeEdges[i], BackEdges[i]);

	printf("Terminal Edge Weights Set... \n");

	// Setting Neighboring Edge Weights
	for(i=0;i<numLabels;i++)
		for (pIter = neighbors[i].begin(); pIter != neighbors[i].end(); pIter++)
		{
			int tmpN = *pIter;
			//printf("%d %d \n",i,tmpN);
			double Energ = 1/(1 + diffVec(MeanColors[i],MeanColors[tmpN]));
			G -> add_edge(nodes[i], nodes[tmpN], LAMBDA*Energ, LAMBDA*Energ);
		}

	printf("Graph Made... \n");
	return G;
}

void SegmentImage(double *L, Graph *G, int numRows, int numCols, double *SegImage, Graph::node_id *nodes)
{
	int i,j;
	Graph::flowtype flow = G -> maxflow();

	for(i=0;i<numRows;i++)
		for(j=0;j<numCols;j++)
		{
			int thisLabel = (int) L[j*numRows + i];
			if(thisLabel>=0)								// If not Boundary pixel
			{
				if (G->what_segment(nodes[thisLabel]) == Graph::SOURCE)		// Do the classification...
					SegImage[j*numRows + i] = 1.0;
				else
					SegImage[j*numRows + i] = 0.0;
			}
			else
				SegImage[j*numRows + i] = 0.0;								// Label the boundary pixels as background for now...
		}

	// Correctly label the boundary pixels ... Label as foreground if any of the neighbors is foreground
	for(i=0;i<numRows;i++)													
		for(j=0;j<numCols;j++)
		{
			int thisLabel = (int) L[j*numRows + i];
			if (thisLabel==-1)
			{
				int UpLabel    = (i>0)            ? (int) L[j*numRows + (i-1)] : thisLabel;
				int DownLabel  = (i<(numRows-1))  ? (int) L[j*numRows + (i+1)] : thisLabel;
				int LeftLabel  = (j>0)            ? (int) L[(j-1)*numRows + i] : thisLabel;
				int RightLabel = (j<(numCols-1))  ? (int) L[(j+1)*numRows + i] : thisLabel;

				// 8-neighborhood
				int NWLabel    = (i>0 && j>0)						? (int) L[(j-1)*numRows + (i-1)] : thisLabel;
				int NELabel    = (i>0 && j<(numCols-1))				? (int) L[(j+1)*numRows + (i-1)] : thisLabel;
				int SELabel    = (i<(numRows-1) && j<(numCols-1))	? (int) L[(j+1)*numRows + (i+1)] : thisLabel;
				int SWLabel    = (i<(numRows-1) && j>0)				? (int) L[(j-1)*numRows + (i+1)] : thisLabel;

				set<int> surround;						// Surrounding Labels of this boundary Label
				
				surround.insert(UpLabel);
				surround.insert(DownLabel);
				surround.insert(LeftLabel);
				surround.insert(RightLabel);
				surround.insert(NWLabel);
				surround.insert(NELabel);
				surround.insert(SELabel);
				surround.insert(SWLabel);

				surround.erase(-1);						// Removing other boundary Labels
				set<int>::iterator pIter;
                float total = 0;
                float lab = 0;
                for (pIter = surround.begin(); pIter != surround.end(); pIter++)
                {
                    total = total+1;;
                    if(G->what_segment(nodes[*pIter]) == Graph::SOURCE)
                        lab = lab+1;
                }
                SegImage[j*numRows + i] = (lab/total)>0.5? 1.0 : 0.0;
			}
		}
}



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	double *L, *MeanColors, *FLabels, *BLabels, *FCClusters, *BCClusters; // Input Arguments
	double *SegImage;														// Output Argument
	int numRows, numCols, numLabels, numFLabels, numBLabels, numFCClusters, numBCClusters;	
	int i;
	  
	if(nrhs!=6) {
		mexErrMsgTxt("Incorrect No. of inputs");
	} else if(nlhs>1) {
		mexErrMsgTxt("Too many output arguments");
	}
	  
	L          = mxGetPr(prhs[0]);
	MeanColors = mxGetPr(prhs[1]);
	FLabels    = mxGetPr(prhs[2]);
	BLabels    = mxGetPr(prhs[3]);	
	FCClusters = mxGetPr(prhs[4]);
	BCClusters = mxGetPr(prhs[5]);	
	  
	numCols = mxGetN(prhs[0]);		// Image Size
	numRows = mxGetM(prhs[0]);
	numLabels = mxGetM(prhs[1]);	// Number of labels
	numFLabels = mxGetM(prhs[2]);	// Number of ForeGround Labels
	numBLabels = mxGetM(prhs[3]);	// Number of BackGround Labels
	numFCClusters = mxGetM(prhs[4]);// Number of ForeGround Color Clusters
	numBCClusters = mxGetM(prhs[5]);// Number of BackGround Color Clusters
	  
	plhs[0] = mxCreateDoubleMatrix(numRows,numCols, mxREAL);	// Memory Allocated for output array

	SegImage = mxGetPr(plhs[0]);								// variable assigned to the output memory location
	 
	printf("Starting MEX Code \n");

	/**** Cast these data structures into correct types 
	and convert into STL Data Structures ****/
	vector< vector<double> > MeanColorsVec;
	MeanColorsVec.clear();
    for(i=0;i<numLabels;i++)
	{
		vector<double> tmp;
		tmp.clear();
		tmp.push_back(MeanColors[0*numLabels + i]);
		tmp.push_back(MeanColors[1*numLabels + i]);
		tmp.push_back(MeanColors[2*numLabels + i]);

		MeanColorsVec.push_back(tmp);
	}
	
	printf("Vectorization 1 \n");

	vector< vector<double> > FCClustersVec;
	FCClustersVec.clear();
    for(i=0;i<numFCClusters;i++)
	{
		vector<double> tmp;
		tmp.clear();
		tmp.push_back(FCClusters[0*numFCClusters + i]);
		tmp.push_back(FCClusters[1*numFCClusters + i]);
		tmp.push_back(FCClusters[2*numFCClusters + i]);

		FCClustersVec.push_back(tmp);
	}

	
	printf("Vectorization 2 \n");

	vector< vector<double> > BCClustersVec;
	BCClustersVec.clear();
    for(i=0;i<numBCClusters;i++)
	{
		vector<double> tmp;
		tmp.clear();
		tmp.push_back(FCClusters[0*numBCClusters + i]);
		tmp.push_back(FCClusters[1*numBCClusters + i]);
		tmp.push_back(FCClusters[2*numBCClusters + i]);

		BCClustersVec.push_back(tmp);
	}

	
	printf("Vectorization 3 \n");

	vector<int> FLabelsVec;
	FLabelsVec.clear();
	for(i=0;i<numFLabels;i++)
		FLabelsVec.push_back((int) FLabels[i]);

	
	printf("Vectorization 4 \n");

	vector<int> BLabelsVec;
	BLabelsVec.clear();
	for(i=0;i<numBLabels;i++)
		BLabelsVec.push_back((int) BLabels[i]);

	
	printf("Vectorization 5 \n");

	/********** Data Structures Converted into Vector Form**/
	/*******************************************************/

	/**** Actual Image Segmentation Code *********/
	vector< set<int> > neighbors;					// Adjacency list declaration
	Graph::node_id *nodes = new Graph::node_id[numLabels];

	MakeAdjacencyList(L, numLabels, numCols, numRows, neighbors);	// Adjacency list made
	printf("Adjacency lists made \n");
	
	Graph* G = MakeGraph(neighbors, MeanColorsVec, FLabelsVec, BLabelsVec, FCClustersVec, BCClustersVec, numLabels, nodes);
	printf("Graph constructed \n");
	
	SegmentImage(L, G, numRows, numCols, SegImage, nodes);
	printf("Image Segmented \n");
}