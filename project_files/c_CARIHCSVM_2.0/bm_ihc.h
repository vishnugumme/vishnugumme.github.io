#ifndef _BM_IHC_H_
#define _BM_IHC_H_

#include"CAR.h"
void bm_ihc(struct filter_coeff filter[NFILT],float w0[NFILT],float w1[NFILT],float BM[NFILT],float sample,float IHC_sum[NFILT],int totalFilters);

#endif
