% coreldrawFigGuidelines

guidelineV1 = 18;
guidelineV2 = 18+174;
guidelineH1 = 18;
guidelineH2 = 297-18;

nStripes = 18;

vLabel = 0;
hLabel = 3;


nhLabels = nStripes - 1;
hWhiteSpace = guidelineH2 - guidelineH1;
hUsefulSpace = hWhiteSpace - nhLabels*hLabel;
hStripeSize = hUsefulSpace/nStripes;
subFigDim = [hStripeSize guidelineV2-guidelineV1];


% Calculate horizontal guideline positions
hGuidelines = zeros(1,2*nStripes);
stripeCount = 0;
for iLine = 1:2*nStripes
  if round(iLine/2) > iLine/2
    stripeCount = stripeCount + 1;
    hGuidelines(iLine) = guidelineH1 + hStripeSize*(stripeCount-1) + hLabel*(stripeCount-1);
  else
    hGuidelines(iLine) = guidelineH1 + hStripeSize*stripeCount + hLabel*(stripeCount-1);
  end
end

round(subFigDim,3)
round(hGuidelines,3)