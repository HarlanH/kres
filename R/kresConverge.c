// kresConverge.c
// efficient C routine to perform the core matrix multiplication loop in
// kres::converge efficiently with few allocations

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

void converge(int *numNodes, double *Xin, double *w, double *gain, 
	double *alpha, double *bias, double *act, int *cycles)
{
	// define input vectors
	// all are double vectors of length *numNodes
	double *net_input;
	double *adj_input;
	double *total_input;
	// define harmony variables
	double harmony, dHarmony, newHarmony;
	// define a copy of act (only once!)
	double *actCopy;
	// loop variables
	int i, j;

	int debug = 0; // gdb of libraries in R is a bit of a pain

	// allocate
	net_input = malloc(sizeof(double) * *numNodes);
	adj_input = malloc(sizeof(double) * *numNodes);
	total_input = malloc(sizeof(double) * *numNodes);
	actCopy = malloc(sizeof(double) * *numNodes);
	for (i = 0; i < *numNodes; i++)
		adj_input[i] = 0; // can't recall if necessary...

	harmony = 1;

    if (debug) {
        printf("Xin = ");
        for (i = 0; i < *numNodes; i++)
            printf("%0.3f ", Xin[i]);
        printf("\n");
        printf("w = ");
        for (i = 0; i < *numNodes; i++)
        {
            printf("\n");
            for (j = 0; j < *numNodes; j++)
                printf("%0.3f ", w[i*(*numNodes) + j]);
        }
        printf("\n");
    }

	// do the loop
	for (*cycles = 1; *cycles < 1000; (*cycles)++)
	{
		if (debug) printf("cycle %d, dHarmony = %0.4f\n", *cycles, dHarmony);

		// calculate total input
		// total_input <- net_input + Xin + bias
		if (debug) printf("total_input = ");  
		for (i = 0; i < *numNodes; i++)
        {
			total_input[i] = net_input[i] + Xin[i] + bias[i];
			if (debug) printf("%0.3f ", total_input[i]);
        }
		if (debug) printf("\n");

		// do gain thing
		// adj_input <- adj_input + (total_input - adj_input) / gain
		if (debug) printf("adj_input = ");  
		for (i = 0; i < *numNodes; i++)
        {
			adj_input[i] = adj_input[i] + (total_input[i] - adj_input[i]) / *gain;
			if (debug) printf("%0.3f ", adj_input[i]);
        }
		if (debug) printf("\n");

		// calculate activation
		// act <- 1 / (1 + exp(-alpha * adj_input))
		if (debug) printf("act = ");  
		for (i = 0; i < *numNodes; i++)
		{
			act[i] = 1 / (1 + exp(-(*alpha) * adj_input[i]));
			if (debug) printf("%0.3f ", act[i]);
		}
		if (debug) printf("\n");

		// recalculate net_input
		// forach node in act, sweep across the corresponding column of
		// w, multiply each, and sum, putting the result in net_input
		for (i = 0; i < *numNodes; i++)
            net_input[i] = 0;
		for (i = 0; i < *numNodes; i++)
		{
			for (j = 0; j < *numNodes; j++)
				net_input[j] += act[i] * w[i*(*numNodes) + j];
		}
        if (debug) 
        {
            printf("net_input = ");
            for (i = 0; i < *numNodes; i++)
                printf("%0.3f ", net_input[i]);
            printf("\n");
        }

		// calculate harmony
		newHarmony = 0;
		for (i = 0; i < *numNodes; i++)
			newHarmony += act[i] * net_input[i];
		dHarmony = fabs(harmony - newHarmony);
        if (debug)
            printf("h = %0.4f, h' = %0.4f, d = %0.4f\n", harmony, newHarmony, dHarmony);
		harmony = newHarmony;

		// are we converged?
		if (dHarmony < 0.00001)
			break;
	}
	

	free(net_input);
	free(adj_input);
	free(total_input);
	free(actCopy);

	// no returns
}
