load('RouletteTimes.mat')



for iVid = 1:10
    %(40)
    
    tk = ballTimes{iVid};
    k = 1:length(tk);
    c0fun = @(a,b) -acoth((exp(a*2*pi) - cosh(a*b*tk(1)))/sinh(a*b*tk(1)));    
    fun40 = @(p,k) (1/(p(1)*p(2)))*(c0fun(p(1),p(2)) - asinh(sinh(c0fun(p(1),p(2)))*exp(p(1)*k*2*pi)));    
    
    p0 = [0.01 -3];
    %p0 = [0.5 -7];
    
    par = lsqcurvefit(fun40,p0,k,tk);
    
    %hold on;
    %plot(k,tk,'ko',k,fun40(par,k),'b-');
    
    a40Arr(iVid) = par(1);
    b40Arr(iVid) = par(2);
    
    
end

for iVid = 1:10
    
    %(41)
    tk = ballTimes{iVid};
    k = 1:length(tk);
    
    a40 = mean(a40Arr);
    b40 = mean(b40Arr);
    beta = a40*(b40^2);
    
    c0fun = @(a) -acoth((exp(a*2*pi) - cosh(a*b40*tk(1)))/sinh(a*b40*tk(1)));    
    fun41 = @(a,k) -(1/(sqrt(a)*sqrt(beta)))*(c0fun(a) - asinh(sinh(c0fun(a))*exp(a*k*2*pi)));
    
    a0 = a40;
    
    a41 = lsqcurvefit(fun41,a0,k,tk,0.000,0.02);
    
    a41Arr(iVid) = a41;
    
%     hold on;
%     plot(k,tk,'ko',k,fun41(a41,k),'b-');


end

%(42)

a = mean(a41Arr);
b = mean(b40Arr);
dTf = 2*pi*[0,0,5/8,0,4/8,4/8,0,1/8,3/8,0];
n = 0.5906 ;
omega2 = 19.6210;

for iVid = 1:10

tk = ballTimes{iVid};

Tf(iVid) = 2*pi*(length(tk)) + dTf(iVid);

x(iVid) = (exp(a*2*pi) - cosh(a*b*tk(1)))/sinh(a*b*tk(1));  
c1(iVid) = (b^2)*(x(iVid)^2-1);

end

fun42 = @(phi) sum(abs(c1.*exp(-2*a*Tf) + n*( ( 1+0.5*(4*a^2+1))*cos(Tf+phi) - 2*a*sin(Tf+phi) ) + b^2 - omega2)); 


%options = optimset('PlotFcns',@optimplotfval);
phi = fminbnd(fun42,0,2*pi);

%(43)

yk = c1.*exp(-2*a*Tf);
xk = ( 1+0.5*(4*a^2+1))*cos(Tf+phi) - 2*a*sin(Tf+phi);

fun43 = @(par) sum(abs(yk + par(1)*xk + (b^2 - par(2))));

par0 = [0.6 19];
Afact = -[1 1];
blimit = 0;

par = fmincon(fun43,par0,Afact,blimit);


% comprobacion de parametros

for iVid = 1:10
    
  f = @(T) c1(iVid)*exp(-2*a*T) + n*( ( 1+0.5*(4*a^2+1))*cos(T+phi) - 2*a*sin(T+phi) ) + b^2 - omega2;
  
  T0 = 0;
  
%   hold on
%   plot(50:0.2:100,f(50:0.2:100));
%   grid on
  
 firstRoot = fzero(f,T0); 
 j = 1;
 for i = (firstRoot-10):0.1:(firstRoot+10);
    [root,fval,exitflag,output] = fzero(f,i);
    if(exitflag == 1)
        roots(j) = root; 
        j = j+1; 
    end 
    
 end
 
 TfPred(iVid) = min(roots);
    
end

 plot(1:10,Tf,'ko',1:10,TfPred,'b-');




