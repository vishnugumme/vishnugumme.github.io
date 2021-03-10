#include<math.h>
#include<stdio.h>
#include"bm_ihc.h"
#include"CAR.h"

	
void bm_ihc(struct filter_coeff filter[NFILT],float w0[NFILT],float w1[NFILT],float BM[NFILT],float sample,float IHC_sum[NFILT],int totalFilters)
{
	float w0p;
	float IHC;
	float sample1;
	int i;
	//struct filter_coeff* filter= &filter_coeff[0];
	//printf("\nsample=%f\n",sample);
	for(i=0;i<totalFilters;i++)
	{
		sample1 = (i==0) ? sample : BM[i-1];
		
		w0p=w0[i];		
		w0[i] = sample1 + filter[i].rf * (filter[i].a0f*w0[i] - filter[i].c0f * w1[i]);
		w1[i] = filter[i].rf *(filter[i].a0f * w1[i] + filter[i].c0f*w0p);
		BM[i] = filter[i].gh * (sample1 + filter[i].hf * w1[i]);
		//printf("\nsample=%5f,w0[%d]= %6f,w1=%6f,BM=%6f",sample,i,w0[i],w1[i],BM[i]);	
		
		IHC = BM[i] > 0 ? BM[i] : 0;
		//printf("\nfilter=%d\tIHC=%f",i+1,IHC);

		IHC_sum[i] = IHC_sum[i] + IHC;
		//printf("\nfilter=%d\tIHC=%f",i+1,IHC_sum[i]);

	}			
}
