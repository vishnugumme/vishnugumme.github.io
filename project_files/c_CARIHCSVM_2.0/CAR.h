#ifndef _CAR_H_
#define _CAR_H_

#define NFILT 25//30
#define NSTART 3//3
#define NEND 25//30
#define X_LOW 0.163920 //0.163920//6k-200-3000//0.163920//8K-200-4000
#define X_HIGH 0.667201// 0.610425//6k-200-3000//0.667201//8K-200-4000
#define FS 8000


struct filter_coeff
{
	float rf;
	float a0f;
	float c0f;
	float gh;
	float hf;
};
void filterCoeff(struct filter_coeff coeffPtr[NFILT],float x_low, float x_high,unsigned int fs,unsigned int totalFilters);

#endif
