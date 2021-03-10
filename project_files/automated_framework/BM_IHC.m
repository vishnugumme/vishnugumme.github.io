function [norm_Q] = BM_IHC(audio_data,fs,xlow,xhigh,Ntem,Nstart,Nend)
    %BM parameters
    npoints = floor(fs);
    x = linspace(xhigh,xlow,Ntem); %position along the cochlea 1 = base, 0 = apex
    f = 165.4.*(10.^(2.1*x)-1)   ;  % Greenwood for humans
    a0f=cos(2*pi*f./fs);
    c0f=sin(2*pi*f./fs);
    damping = 0.1         ;       % damping factor
    rf=(1 - damping*2*pi*f./fs);
    hf = c0f ;
    gf = (1-2*a0f.*rf+rf.*rf)./(1-(2*a0f-hf.*c0f).*rf+rf.*rf);
    
    stimulusin = audio_data;
    stimulusin = stimulusin';
    stimulus = zeros(1,fs);
    
    for i=1:length(stimulusin)
        stimulus(1,i) = stimulusin(i);
    end
    
    W0 = zeros(Ntem,npoints);                          %BM filter internal state
    W1 = zeros(Ntem,npoints);                          %BM filter internal state
    BM = zeros(Ntem,npoints);                          %BM displacement
    
    for t=2:(npoints)                               
        for s=1:(Ntem)
            if (s==1)
                stim = stimulus(t);
            else
                stim = BM(s-1,t);
            end
            W0(s,t) = stim + rf(s)*(a0f(s)*W0(s,t-1) - c0f(s)*W1(s,t-1));
            W1(s,t) = rf(s)*(a0f(s)*W1(s,t-1) + c0f(s)*W0(s,t-1));
            BM(s,t) = gf(s)*(stim + hf(s)*W1(s,t));

        end        
    end
%    delete('bm1.h');
%    header_export("bm1.h",'bm1',BM(1,:));

    IHC = max(0,BM);   
    IHC_o = IHC(Nstart:Nend,:);
    Q_int = sum(IHC_o,2); % Summation on 16Khz samples
%     header_export("q_int.h",'input',Q_int');
    norm_Q = normalize_var(Q_int,0,1); % Normalization
end
