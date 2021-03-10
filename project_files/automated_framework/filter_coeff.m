
function filter_coeff(fs,xlow,xhigh,Ntem,Nstart,Nend)
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
    arf=a0f.*rf;
    crf=c0f.*rf;
    ghf=gf.*hf;
    header_export('arf.h','arf',arf);
    header_export('crf.h','crf',crf);
    header_export('ghf.h','ghf',ghf);
    header_export('gf.h','gf',gf);


    
