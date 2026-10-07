function [h, phase, envelope] = hilbertTransform(data)
% [h, phase, envelope] = hilbertTransform(data)
%
% Function performs hilbert tranform on a data vector.
% Input: data - a data vector.
% Output: h - output of Matlab's own hilbert function.
%         phase - phase values for the data vector.
%         envelope - envelope of the signal fluctuations.

h = hilbert(data');
h = h';
phase = angle(h);
envelope = abs(h);