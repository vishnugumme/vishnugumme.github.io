#include<math.h>
#include<stdio.h>
#include"CAR.h"


void filterCoeff(struct filter_coeff coeffPtr[NFILT],float x_low, float x_high,unsigned int fs,unsigned int totalFilters)
{
	float x_diff =0;
	float x[totalFilters],frq[totalFilters];
	float damping_factor = 0.1;
	x_diff = ((float)(x_high - x_low))/((float)totalFilters-1);
	float rF1=0;
	for(int i = 0; i < totalFilters; i++)
	{	

		x[i] = x_high - i * x_diff;
		//printf("x[%d]=%f\n",i+1,x[i]);

		frq[i] = 165.4 * (pow(10,(2.1*x[i]))-1);
	       	//printf("frq[%d]=%f\n",i+1,frq[i]);
		coeffPtr[i].a0f = cos(2*M_PI*(frq[i]/fs)); 
		//printf("a0f[%d]=%f\n",i+1,coeffPtr[i].a0f);
		coeffPtr[i].c0f = sin(2*M_PI*(frq[i]/fs));
		//printf("c0f[%d]=%f\n",i+1,coeffPtr[i].c0f);
		coeffPtr[i].rf  = (1-damping_factor*2*M_PI*(frq[i]/fs));
		//printf("rf[%d]=%f\n",i+1,coeffPtr[i].rf);
	       	coeffPtr[i].hf  = coeffPtr[i].c0f;
		//printf("hf[%d]=%f\n",i+1,coeffPtr[i].hf);
		rF1 = coeffPtr[i].rf * coeffPtr[i].rf;
		coeffPtr[i].gh  = (1- 2*coeffPtr[i].a0f * coeffPtr[i].rf+ rF1) /(1-(2*coeffPtr[i].a0f-coeffPtr[i].hf * coeffPtr[i].c0f)*coeffPtr[i].rf+rF1);
		//printf("gh[%d]=%f\n",i+1,coeffPtr[i].gh);
		//printf("gh[%d] = %10f \n",i+1,coeffPtr[i].gh);
	}
}
