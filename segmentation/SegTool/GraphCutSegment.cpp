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

using namespace std;

 void MakeAdjacencyList(double *L, int numLabels, int numCols, int numRows, set<int, less<int> > BGLabels, vector< set<int, less<int> > > &neighbors)
{
	int i,j;
	neighbors.clear();

	// Declaring the Adjacency list
	for(i=0;i<numLabels;i++)
	{
		set<int, less<int> > tmp;
		tmp.clear();
		neighbors.push_back(tmp);
	}
	
	//printf("Adjacency code starts... \n");

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

				set<int, less<int> > surround, filt_surround;						// Surrounding Labels of this boundary Label
				
				surround.insert(UpLabel);
				surround.insert(DownLabel);
				surround.insert(LeftLabel);
				surround.insert(RightLabel);
				surround.insert(NWLabel);
				surround.insert(NELabel);
				surround.insert(SELabel);
				surround.insert(SWLabel);

				surround.erase(-1);						// Removing other boundary Labels

				// Now set difference -- removing the background labels from reckoning -- we need only U Labels
				set_difference(surround.begin(), surround.end(), BGLabels.begin(), BGLabels.end(), insert_iterator<set<int, less<int> > >(filt_surround,filt_surround.begin()) );
				
				set<int, less<int> >::iterator pIter, qIter;
				for (pIter = filt_surround.begin(); pIter != filt_surround.end(); pIter++)
					for (qIter = filt_surround.begin(); qIter != filt_surround.end(); qIter++)
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

Graph* MakeGraph( vector< set<int, less<int> > > neighbors, vector< vector<double> > MeanColors, vector<int> UNLabels, vector<double> FDists, vector<double> BDists, int numLabels, Graph::node_id *nodes, vector<int> &labelNodeIndices, double LAMBDA)
{
	Graph *G = new Graph();
	set<int, less<int> >::iterator pIter;
	double beta;
	int i;

	//printf("graph Making code starts... \n");

	int numULabels = UNLabels.size();			// Number of U Labels -- will have a node each for U Labels
	/********* Calculating the value of beta ****************/
	double countCand = 0;
	double SumColors = 0;
	for(i=0;i<numULabels;i++)
	{
		int currLabel = UNLabels[i];
		for (pIter = neighbors[currLabel].begin(); pIter != neighbors[currLabel].end(); pIter++)
		{
			SumColors += pow(diffVec(MeanColors[currLabel],MeanColors[*pIter]),2);
			countCand++;
		}
	}
	
	beta = countCand/(2*SumColors);


	/**************** Beta Value Made *********************/

	/******* Start making the graph **************/
	
	//vector<int> labelNodeIndices;				// for each label, what is the corresponding node index?
	labelNodeIndices.clear();
	for(i=0;i<numLabels;i++)
		labelNodeIndices.push_back(-1);

	// Add Nodes
	
	for(i=0;i<numULabels;i++)
	{
		nodes[i] = G -> add_node();
		labelNodeIndices[UNLabels[i]] = i;		// index of label no. UNLabels[i] is i
	}


	// Setting Terminal Edge Weights
	for(i=0;i<numULabels;i++)
		G -> set_tweights(nodes[i], BDists[i], FDists[i]);


	// Setting Neighboring Edge Weights
    float MeanNbEdgeW = 0;
    float MNECount = 0;
    
	for(i=0;i<numULabels;i++)
		for (pIter = neighbors[UNLabels[i]].begin(); pIter != neighbors[UNLabels[i]].end(); pIter++)
		{
			int tmpN = *pIter;
			//printf("%d %d \n",i,tmpN);
			double Energ = exp(-beta*pow(diffVec(MeanColors[UNLabels[i]],MeanColors[tmpN]),2));
			G -> add_edge(nodes[i], nodes[labelNodeIndices[tmpN]], LAMBDA*Energ, LAMBDA*Energ);
            MeanNbEdgeW += LAMBDA*Energ;
            MNECount++;
            //G -> add_edge(nodes[i], nodes[labelNodeIndices[tmpN]], 0, 0);
		}
    
	return G;
}

void SegmentImage(double *L, Graph *G, Graph::node_id *nodes, vector<int> labelNodeIndices, int numRows, int numCols, int numULabels, double *SegImage, double *LLabels)
{
	int i,j;
	Graph::flowtype flow = G -> maxflow();
    printf("Energy = %f\n", flow);
    
	/**** Giving Binary (obj/background) labels to all U Labels *****/
	for(i=0;i<numULabels;i++)
	{
		if(G->what_segment(nodes[i]) == Graph::SOURCE)
			LLabels[i] = 1.0;
		else
			LLabels[i] = 0.0;
	}

	for(i=0;i<numRows;i++)
		for(j=0;j<numCols;j++)
		{
			int thisLabel = (int) L[j*numRows + i];
			if(thisLabel>=0)								// If not Boundary pixel
			{
				int nodInd = labelNodeIndices[thisLabel];	// Node Index -- different from Label No. 
				
				if(nodInd>=0)								// if thisLabel is not a fixed back-ground label, then do the classification 
				{
                    if (G->what_segment(nodes[nodInd]) == Graph::SOURCE)		// Do the classification...
						SegImage[j*numRows + i] = 1.0;
					else
						SegImage[j*numRows + i] = 0.0;
				}
				else										// ... ELSE let it be background
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
                    total = total+1;
					int nodInd = labelNodeIndices[*pIter];	// Node Index
                    if(nodInd>=0)				// Non - Fixed-BackGround Label
						if(G->what_segment(nodes[nodInd]) == Graph::SOURCE)
							lab = lab+1;
                }
                SegImage[j*numRows + i] = (lab/total)>0.5? 1.0 : 0.0;
			}
		}
}



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	double *L, *MeanColors, *ULabels, *BLabels, *FDist, *BDist, *RelateParam;						// Input Arguments
	double *SegImage, *LLabels;														// Output Arguments
	int numRows, numCols, numLabels, numULabels, numBLabels;	
	int i;
	  
	if(nrhs!=7) {
		mexErrMsgTxt("Incorrect No. of inputs");
	} else if(nlhs!=2) {
		mexErrMsgTxt("Incorrect No. of outputs");
	}
	  
	L          = mxGetPr(prhs[0]);
	MeanColors = mxGetPr(prhs[1]);
	ULabels    = mxGetPr(prhs[2]);
	BLabels    = mxGetPr(prhs[3]);	
	FDist      = mxGetPr(prhs[4]);
	BDist	   = mxGetPr(prhs[5]);	
	RelateParam = mxGetPr(prhs[6]);  
    
    double LAMBDA = (*RelateParam);
    
	numCols = mxGetN(prhs[0]);		// Image Size
	numRows = mxGetM(prhs[0]);
	numLabels = mxGetM(prhs[1]);	// Number of labels
	numULabels = mxGetM(prhs[2]);	// Number of ForeGround Labels
	numBLabels = mxGetM(prhs[3]);	// Number of BackGround Labels
	  
	plhs[0] = mxCreateDoubleMatrix(numRows,numCols, mxREAL);	// Memory Allocated for output SegImage
	plhs[1] = mxCreateDoubleMatrix(numULabels,1, mxREAL);		// Memory Allocated for output LLabels

	SegImage = mxGetPr(plhs[0]);								// variable assigned to the output SegImage
	LLabels = mxGetPr(plhs[1]);									// variable assigned to the output SegImage
	 
	//printf("Starting MEX Code \n");

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
	
	//printf("Vectorization 1 \n");

	vector<double> FDistVec;
	FDistVec.clear();
    for(i=0;i<numULabels;i++)
		FDistVec.push_back(FDist[i]);
		
	//printf("Vectorization 2 \n");

	vector<double> BDistVec;
	BDistVec.clear();
    for(i=0;i<numULabels;i++)
		BDistVec.push_back(BDist[i]);
	
	//printf("Vectorization 3 \n");

	vector<int> UNLabelsVec;
	UNLabelsVec.clear();
	for(i=0;i<numULabels;i++)
		UNLabelsVec.push_back((int) ULabels[i]);

	
	//printf("Vectorization 4 \n");

	set<int, less<int> > BGLabelsVec;
	BGLabelsVec.clear();
	for(i=0;i<numBLabels;i++)
		BGLabelsVec.insert((int) BLabels[i]);

	
	//printf("Vectorization 5 \n");

	/********** Data Structures Converted into Vector Form**/
	/*******************************************************/

	/**** Actual Image Segmentation Code *********/
	vector< set<int, less<int> > > neighbors;					// Adjacency list declaration
	Graph::node_id *nodes = new Graph::node_id[numULabels];
	vector<int> labelNodeIndices;
	labelNodeIndices.clear();

	MakeAdjacencyList(L, numLabels, numCols, numRows, BGLabelsVec, neighbors);
	//printf("Adjacency lists made \n");
	
	Graph* G = MakeGraph(neighbors, MeanColorsVec, UNLabelsVec, FDistVec, BDistVec, numLabels, nodes, labelNodeIndices, LAMBDA);
	//printf("Graph constructed \n");
	
	SegmentImage(L, G, nodes, labelNodeIndices, numRows, numCols, numULabels, SegImage, LLabels);
	//printf("Image Segmented \n");
}