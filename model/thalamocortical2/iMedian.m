function i = iMedian(sample)
csSample = cumsum(sample,'reverse');
csSample_half = csSample-0.5*sum(sample);
csSample_half(csSample_half<0) = 0;
i = find(csSample_half,1,'last')+1;