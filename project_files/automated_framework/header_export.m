%%
%--------  Header file generation -----
function header_export(file_name,variable_c,variable)
%%input_vector = fi(variable,1,32,15); % Input vector is the variable you want to convert into header file.
input_vector = variable;
[m,n]=size(input_vector);
 k=fopen(file_name,'w');
 fprintf(k,'//#include "%s" \n',file_name);
 fprintf(k,'float const %s[%d][%d]={',variable_c,m,n);
%   
%    for i=1:m
%       for j =1:n
%           if i==m
%               fprintf(k,'%f',input_vector(i,j));
%           else
%               fprintf(k,'%f, ',input_vector(i,j));
%           end
%       end
%   end
%   fprintf(k,'};');
%  
 for i=1:m
      fprintf(k,'{');
      for j =1:n
          
          fprintf(k,'%f',input_vector(i,j));
          
         if(j~= n)
             fprintf(k,',');
         end
      end
     fprintf(k,'}');
      if i ~= m
         fprintf(k,',');
      end
  end
  fprintf(k,'};');
  fclose(k);
