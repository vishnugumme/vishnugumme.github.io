#ifndef SVM_INFERENCE_H_
#define SVM_INFERENCE_H_

int SVM_Inference( int kernel_n, float* kernel_ptr,float alpha[kernel_n][2], float bias[1][2]);


/*
 * Inputs : 1. kernal_ptr : Pointer to the array of the kernal
 * 	    2. alpha : Pointer to 2 D weights (alpha) trained on network
 * 	    3. bias : pointer to the bias values for the outputs.
 * Output : Output will be given 1 when the class predicted as positive, 0 when itb is for negative class
 * */

#endif

