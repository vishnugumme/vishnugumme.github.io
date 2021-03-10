%%
%--------  Header file generation -----
function car_export(file_name,nfilt,nstart,nend,xlow,xhigh,fs)
%%input_vector = fi(variable,1,32,15); % Input vector is the variable you want to convert into header file.
%input_vector = variable;
%[m,n]=size(input_vector);
 k=fopen(file_name,'w');
 fprintf(k,'#ifndef _CAR_H_\n#define _CAR_H_\n\n#define NFILT %d\n',nfilt);
 fprintf(k,'#define NSTART %d\n#define NEND %d\n#define X_LOW %f\n#define X_HIGH %f\n#define FS %d\n\n#endif',nstart,nend,xlow,xhigh,fs);
 fclose(k);
