
#include<stdio.h>
#include"SVM_inference.h"

int SVM_Inference(int kernel_n, float* kernel_ptr, float alpha[kernel_n][2], float bias[1][2])
	{
		float Neuron[2];
		Neuron[0] = 0;
		Neuron[1] = 1;
		int result;
		int i,j;
		for(j =0 ; j<2; j++)
		{
			Neuron[j] = *(*(bias)+j);
			for(i = 0; i< kernel_n ;i++)
			{

				Neuron[j] = Neuron[j] + *(*(alpha+i)+j) * (*(kernel_ptr+i));
			}

			if(Neuron[j]>=0)
			{
				result = j;
			}
			printf("\nNeuron[%d] = %f ",j,Neuron[j]);
		}

			return result;

	}

