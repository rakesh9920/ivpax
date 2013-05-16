function [VelEst] = instdoppler(BfSigMat, varargin)
%

[nSample nFieldPos nFrame] = size(BfSigMat);
VelEst = zeros(nFieldPos, nFrame - 1);

%t = ((0:nFrame-1)./(500)).';
for pos = 1:nFieldPos
    
    for frame = 1:(nFrame - 1)
        
        AnalyticSig1 = hilbert(squeeze(BfSigMat(:,pos,frame)));
        AnalyticSig2 = hilbert(squeeze(BfSigMat(:,pos,frame + 1)));
        
        I1 = real(AnalyticSig1);
        Q1 = imag(AnalyticSig1);
        I2 = real(AnalyticSig2);
        Q2 = imag(AnalyticSig2);
        
%         VelEst(pos,frame) = atan((Q2(100)*I1(100) - I2(100)*Q1(100))/...
%             (I2(100)*I1(100) + Q2(100)*Q1(100)));

         VelEst(pos,frame) = angle(AnalyticSig2(100)) - angle(AnalyticSig1(100));
%         SampledSig = squeeze(BfSigMat(line,sample,:));    
%         AnalyticSig = hilbert(SampledSig);
%         AnalyticSig = SampledSig.*exp(-1i*2*pi*6.6e6.*t);
        
%         RealPart = real(AnalyticSig);
%         ComplexPart = imag(AnalyticSig);   
%         RealPart = SampledSig.*cos(2*pi*6.6e6.*t);
%         ComplexPart = -SampledSig.*sin(2*pi*6.6e6.*t);

%         n1 = ComplexPart(2:nFrame).*RealPart(1:(nFrame-1));
%         n2 = RealPart(2:nFrame).*ComplexPart(1:(nFrame-1));
%         d1 = RealPart(2:nFrame).*RealPart(1:(nFrame-1));
%         d2 = ComplexPart(2:nFrame).*ComplexPart(1:(nFrame-1));
%         
%         VelEst(line,sample) = atan(sum(n1 - n2)/sum(d1 + d2));
        %VelEst(line, sample) = mean(diff(angle(AnalyticSig)));
    end
end

end

