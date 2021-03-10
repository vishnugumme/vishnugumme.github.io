function [alpha,bias,inpB] = SVMTrain(trainx,Ytrain,crossx,Ycross,Ntem,Q_train, Q_test)

%-------------------------------------------------------------------------
% This is a function to train a potential function based GiniSVM using a 
% fixed-point algorithm 
% Usage: [sv,alpha,bias,kscale] = GiniSVMTrain(trainx,Ytrain,inpB,Ntem,kscale,svin)
%
% INPUT DATA FORMAT (Required)
%-------------------------------------------------------------------------
% trainx -> input data matrix (number of data x Dimension)
% Ytrain -> input label (number of data x total classes)
% The training and cross-validation labels should prior probabilities.
% An example for a three class label is [0 0 1] to indicate
% that the training label belongs to class 3. Or it could
% be [0.1 0.3 0.6] to indicate prior confidence.
%
% INPUT PARAMETERS (Optional)
%-------------------------------------------------------------------------
% inpB = 0.5;                        % Generalization parameter
% Ntem = min(50,25 percent of data);  % Maximum support vectors allowed
% kscale = 1;                        % potential function parameter
% svin ->                            % a-priori basis vectors
%
% OUTPUT PARAMETERS
% ------------------------------------------------------------------------
% sv -> template or basis vectors
% alpha -> layer 1 weights
% bias -> layer 1 bias
%-------------------------------------------------------------------------
% Copyright (C) Shantanu Chakrabartty 2002,2012,2013,2014,2015
% Version: GiniSVMMicrov1.0
%-------------------------------------------------------------------------
% Licensing Terms: This program is granted free of charge for research and 
% education purposes. However you must obtain a license from the author to 
% use it for commercial purposes. The software must not be modified and 
% distributed without prior permission of the author. By using this 
% software you agree to the licensing terms:
%
% NO WARRANTY: BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO 
% WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. 
% EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR 
% OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, 
% EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
% ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.
% SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY 
% SERVICING, REPAIR OR CORRECTION. IN NO EVENT UNLESS REQUIRED BY 
% APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY 
% OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE PROGRAM, BE LIABLE TO 
% YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR 
% CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE 
% PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING 
% RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A 
% FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH 
% HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
% DAMAGES. 
%-------------------------------------------------------------------------

[N,D] = size(trainx);
[Ny,M] = size(Ytrain);
[Ncross,Dcross] = size(crossx);
if Ny ~= N,
   error('Training Data size neq labels');
end;

autopick = 0;
pickkernel = 0;
inpC = 1;
inplag = 100;
inneriter = 100000;
Ninc = ceil(0.5*Ntem);

% Now parse the input arguments
% if (nargin <5 | nargin > 6) % check correct number of arguments
%     help GiniTrain
% else
%     if (nargin < 6) autopick = 1;, end
% end;


for i = 1:N,
   [val,yindex(i)] = max(Ytrain(i,:) + 1e-6*rand(1,M));
end;

for i = 1:Ncross,
   [val,ycrossindex(i)] = max(Ycross(i,:) + 1e-6*rand(1,M));
end;
% Outerloop
Nouter = 1 ;
besterrorp = 1;
outerflag = 0;
outeriter = 0;
outeralpha = [];
outerbias = [];
outerinpB = 0;
Pin = 1/M*ones(N,M);
inpB = 1;
tol = 0.1;
Facin = 0;

errordist = zeros(1,M);

while ((outerflag == 0) & (outeriter < Nouter)),

   outeriter = outeriter + 1;


   % Now implement the growth transform GiniSVM training and
   % search for inpB
   %fprintf('Start GiniSVM training ... outer loop = %d\n',outeriter);

   
   cvflag = 0;
   errorp = 1;
   maxiter = 8;
   curriter = 0;
   %Pin = 1/M*ones(N,M);
    
   while (cvflag == 0) & (curriter < maxiter),

      curriter = curriter + 1;
      errorflag = zeros(N,1);
   
      %[alpha,bias,Pout] = GrowthSPG(trainx,Ytrain,trainx,inpB,inneriter,ktype,kscale,inplag,Pin);
      %[alpha,bias,Pout,Fac] = GrowthSPG(trainx,Ytrain,inpC,inneriter,inpB,inplag,tol,Pin,Facin,Ntem);
      [alpha,bias,Pout,Fac] = GrowthTrans(trainx,Ytrain,inpC,inneriter,inpB,inplag,tol,Pin,Facin,Q_train);
      %[alpha,bias,Pout,Fac] = GrowthSPG(trainx,Ytrain,svout,inpC,inneriter,inpB,kscale,inplag,tol,Pin,0);
      errort = 0;
      thr = 0;
      %[result] = GiniSVMRunRaw(trainx,alpha,bias,Ntem);
      result = Q_train*alpha + ones(N,1)*bias;
      for k = 1:N,
         [maxval,ind] = max(result(k,:));
         if ind ~= yindex(k),
            errort = errort + 1;
            errorflag(k) = 1;
         end;
      end;
      %fprintf('\n Iter: %d, Current inpB = %d, ',curriter, inpB);
      %fprintf('Train Error = %d percent, ',ceil((errort/N)*100));

      errorc = 0;
      %[result] = GiniSVMRunRaw(crossx,alpha,bias,Ntem);
      result = Q_test*alpha + ones(Ncross,1)*bias;
      for k = 1:Ncross,
         [maxval,ind] = max(result(k,:));
         if ind ~= ycrossindex(k),
            errorc = errorc + 1;
         end;
      end;
      %fprintf('Validation Error = %d percent \n',ceil((errorc/Ncross)*100));

      % If the cross-validation error has increased then stop
      if (errorc/Ncross <= 0.999*errorp),
         inpBprev = inpB;
         inpB = 0.5*inpB;
         %tolprev = tol;
         %tol = 0.5*tol;
         alphap = alpha;
         biasp = bias;
         Facin = Fac;
         %Pin = 1/M*ones(N,M);
         Pin = Pout;
         errorp = errorc/Ncross;
      else
         cvflag = 1;
         alpha = alphap;
         bias = biasp;
         inpB = inpBprev;
         %tol = tolprev;
      end;
      besterror = errorp;
   end;    

   % Now increase the number of templates to include the vectors which
   % have errors and see if the cross-validation error further reduces.

   % If the cross-validation error has increased then stop
   if (besterror <= 0.999*besterrorp),
       % Pick the new templates from the error vectors     
       clear outeralpha outerbias;
       outeralpha = alpha;
       outerbias = bias;
       outerinpB = inpB;
       clear alpha bias;
       besterrorp = besterror;
   else
      outerflag = 1;
      clear alpha bias;
      alpha = outeralpha;
      bias = outerbias;
      inpB = outerinpB;
      besterror = besterrorp;
   end;
end;

alpha = outeralpha;
bias = outerbias;
inpB = outerinpB;

%fprintf('...done\n');


% Now implement the growth transform GiniSVM training
%fprintf('Start GiniSVM training ...');
%[alpha,bias] = GrowthSPG(trainx,Ytrain,svout,inpC,inneriter,inpB,kscale,inplag);
%fprintf('...done\n');


   
