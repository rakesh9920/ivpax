% Converted to a routine more appropriate for use with Matlab and Octave by
% Robert J. McGough
% Michigan State University
% 18 Dec 2005

%This program is a direct conversion of the corresponding Fortran program in
%S. Zhang & J. Jin "Computation of Special Functions" (Wiley, 1996).
%online: http://iris-lee3.ece.uiuc.edu/~jjin/routines/routines.html
%
%Converted by f2matlab open source project:
%online: https://sourceforge.net/projects/f2matlab/
% written by Ben Barrowes (barrowes@alum.mit.edu)
%

%       =====================================================
%       Purpose: This program computes Struve function
%                H1(x)using subroutine STVH1
%       Input :  x   --- Argument of H1(x,x ò 0)
%       Output:  SH1 --- H1(x)
%       Example:
%                   x          H1(x)
%                -----------------------
%                  0.0       .00000000
%                  5.0       .80781195
%                 10.0       .89183249
%                 15.0       .66048730
%                 20.0       .47268818
%                 25.0       .53880362
%       =====================================================

function [sh1]=struveh1(x);
%       =============================================
%       Purpose: Compute Struve function H1(x)
%       Input :  x   --- Argument of H1(x,x ò 0)
%       Output:  SH1 --- H1(x)
%       =============================================
pi=3.141592653589793e0;
r=1.0e0;
% if(x <= 20.0e0), 
ile20 = find(x <= 20.0e0);
    s=0.0e0;
    a0=-2.0e0./pi;
    for  k=1:60;
        r=-r.*x(ile20).*x(ile20)./(4.0e0.*k.*k-1.0e0);
        s=s+r;
        if(abs(r)< abs(s).*1.0e-12)break; end;
    end;
    sh1(ile20)=a0.*s;
% else;
    igt20 = find(x > 20.0e0);
    r=1.0e0;
    s=1.0e0;
        km=min(25, min(fix(.5.*x(igt20))));
%    km=min(25, max(fix(.5.*x(igt20))));
%    if(x(igt20) > 50.e0)km=25; end;
    for  k=1:km;
        r=-r.*(4.0e0.*k.*k-1.0e0)./(x(igt20).*x(igt20));
        s=s+r;
        if(abs(r)< abs(s).*1.0e-12)break; end;
    end;
    t=4.0e0./x(igt20);
    t2=t.*t;
    p1=((((.42414e-5.*t2-.20092e-4).*t2+.580759e-4).*t2-.223203e-3).*t2+.29218256e-2).*t2+.3989422819e0;
    q1=t.*(((((-.36594e-5.*t2+.1622e-4).*t2-.398708e-4).*t2+.1064741e-3).*t2-.63904e-3).*t2+.0374008364e0);
    ta1=x(igt20)-.75e0.*pi;
    by1=2.0e0./sqrt(x(igt20)).*(p1.*sin(ta1)+q1.*cos(ta1));
    sh1(igt20)=2.0./pi.*(1.0e0+s./(x(igt20).*x(igt20)))+by1;
    
% end;
% return;
% end
