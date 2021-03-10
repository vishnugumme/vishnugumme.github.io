/*ULTRA_LIGHT AUDIO CLASSIFIER*/


#include<stdio.h>
#include<math.h>
#include<string.h>
#include"CAR.h"
#include"normalized.h"
#include"SVM_inference.h"
#include"bm_ihc.h"
#include"alpha.h"
#include"bias.h"
#include"mix2.h"
struct filter_coeff filter[NFILT];
float w0[NFILT],w1[NFILT],BM[NFILT],IHC_sum[NFILT];
float kernel[NEND-NSTART+1];
float ihcSum[NEND-NSTART+1];
int result;
int sample_cnt;
float sample;

int main()
{	
	int i,j,p;
	float x_l=X_LOW;
	float x_h=X_HIGH;
	unsigned int nfilt=NFILT;
	unsigned int fsampling=FS, n_kernels=NEND-NSTART+1;	
	filterCoeff(filter, x_l , x_h,fsampling, nfilt);
	sample_cnt=0;	
	int filt_n=0;
	for(int j=0;j<NSAMPLES;j++)
	{	
		if(sample_cnt != 0)
		{	
			sample=audioval[j];
			bm_ihc(filter,w0,w1,BM,sample,IHC_sum,nfilt);
			if (sample_cnt == FS-1)
			{       
				filt_n=0;	
				for(i=0;i<NFILT;i++)
				{
					if( i >= NSTART-1 && i < NEND)
					{	
						ihcSum[filt_n]=IHC_sum[i];

						filt_n++;		
					}
				}

				normalize(&ihcSum[0], n_kernels , 0 , 1);
				int result = SVM_Inference( n_kernels,&ihcSum[0],alpha,bias);
				int class = (result==0)?1:0;
				printf("\nDetected Class = %d \t with sample nu= %d\n",class,j);
				memset((void*)(&w0[0]),0,nfilt*sizeof(float));
				memset((void*)(&w1[0]),0,nfilt*sizeof(float));
				memset((void*)(&BM[0]),0,nfilt*sizeof(float));
				memset((void*)(&IHC_sum[0]),0,nfilt*sizeof(float));  //CHeck if it is required ?
				sample_cnt=0;

			}
			else
			{
				sample_cnt++;
			}
		}
		else
		{
			sample_cnt++;
		}

	}
	return 0;
}
