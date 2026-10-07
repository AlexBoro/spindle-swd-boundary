function outputFilename = writeBinary(data, fileName, format)
% The function writes a short binary file.
%
% Input: data is the data vector to write (type double).
%        fileName is the name of the binary file when saved.
%        format is the type of format you want the data to be saved (i.e.,
%          'int16', 'double', etc).
%
% Output: outputFilename is the name of the binary file when saved.

chunkSize = 1000000;

fidOut = [];

w = whos('data');
nSampsTotal = w.bytes/8;
nChunksTotal = ceil(nSampsTotal/chunkSize);

try
  outputFilename  = fileName;
  fidOut = fopen(outputFilename, 'w');
  
  chunkInd = 1;
  while 1
    fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
    inds = (1:chunkSize) + (chunkInd-1)*chunkSize;
    if inds(1) > numel(data)
      break
    elseif inds(end) > numel(data)
      inds = inds(1):numel(data);
    end
    dat = data(inds);
    fwrite(fidOut, dat, format);
    chunkInd = chunkInd+1;
  end
  
  fclose(fidOut);
  
catch me
  if ~isempty(fidOut)
    fclose(fidOut);
  end
  
  rethrow(me)
  
end