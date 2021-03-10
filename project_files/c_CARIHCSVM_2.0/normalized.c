#include<stdio.h>
#include<math.h>
#include"normalized.h"

void normalize(float* input_array,int dimension_array,int low_value, int high_value)
{
	float tmp_max = *(input_array);
	float tmp_min = *(input_array);
	int i,j;
	for(i=1; i < dimension_array;i++)
	{
		if(tmp_max < *(input_array+i))
		{
			tmp_max = *(input_array+i);
		}
		
		if(tmp_min > *(input_array+i))
		{
			tmp_min = *(input_array+i);
		}
	}
	
	if(tmp_max != tmp_min)
	{
		int range_norm = high_value -low_value;
		
		for(j = 0;j < dimension_array ;j++)
		{
			float array_norm = (*(input_array+j) - tmp_min)/(tmp_max-tmp_min);
			*(input_array+j) = (float)range_norm * array_norm +(float)low_value;
		//	printf("Normaloized[%d]  = %6f\n",j+1,*(input_array+j));
		}
	}
	
	return;

}


