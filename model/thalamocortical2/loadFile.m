function [A, structA, cellType] = loadFile(fileName, Area, cellType)

if strcmp('z', fileName(1))
    subtract = 1;
else
    subtract = 0;
end
if strcmp('TC', cellType)
    fullFile = 47-subtract;
elseif strcmp('NRT', cellType)
    fullFile = 38-subtract;
elseif strcmp('Cx3', cellType)
    fullFile = 45-subtract;
end
shortFile = 2-subtract;
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
if strcmp('10', fileName(2:3))
    n = length(A)/fullFile;
    A = reshape(A,n,fullFile)';
    structA.v = A(2-subtract,:);
    structA.IVC = A(3-subtract,:);
    if strcmp('TC', cellType) || strcmp('NRT', cellType)
        structA.I = A(4-subtract,:);
        structA.IKleak = A(5-subtract,:)*1e6*Area;
        structA.INaleak = A(6-subtract,:)*1e6*Area;
        structA.INa = A(7-subtract,:)*1e6*Area;
        structA.INam = A(8-subtract,:);
        structA.INah = A(9-subtract,:);
        structA.IK = A(10-subtract,:)*1e6*Area;
        structA.IKn = A(11-subtract,:);
        structA.Cai = A(12-subtract,:)*1e6;
        structA.Cahvai = A(13-subtract,:)*1e6;
        structA.ICa = A(14-subtract,:)*1e6*Area;
        structA.ICam = A(15-subtract,:);
        structA.ICah = A(16-subtract,:);
        structA.Ih = A(17-subtract,:)*1e6*Area;
        structA.Iho1 = A(18-subtract,:);
        structA.Iho2 = A(19-subtract,:);
        structA.Ihp1 = A(20-subtract,:);
        structA.IAHP = A(21-subtract,:)*1e6*Area;
        structA.IAHPm1 = A(22-subtract,:);
        structA.IAHPm2 = A(23-subtract,:);
        structA.ICAN = A(24-subtract,:)*1e6*Area;
        structA.ICANp1 = A(25-subtract,:);
        structA.ICANo = A(26-subtract,:);
        structA.INaPm = A(27-subtract,:);
        if strcmp('TC', cellType)
            structA.IAm1 = A(28-subtract,:);
            structA.IAm2 = A(29-subtract,:);
            structA.IAh1 = A(30-subtract,:);
            structA.IAh2 = A(31-subtract,:);
            structA.IK1m = A(32-subtract,:);
            structA.IK2m = A(33-subtract,:);
            structA.IK2h1 = A(34-subtract,:);
            structA.IK2h2 = A(35-subtract,:);
            structA.IHVA = A(36-subtract,:)*1e6*Area;
            structA.IHVAm = A(37-subtract,:);
            structA.IAMPA = A(38-subtract,:);
            structA.INMDA = A(39-subtract,:);
            structA.ImGluR1a = A(40-subtract,:);
            structA.ImGluR1aR = A(41-subtract,:);
            structA.ImGluR1aG = A(42-subtract,:);
            structA.IGABAa = A(43-subtract,:);
            structA.IGABAb = A(44-subtract,:);
            structA.IeGABAa = A(45-subtract,:);
            structA.IeGABAa_R = A(46-subtract,:);
            structA.IeGABAa_G = A(47-subtract,:);
        elseif strcmp('NRT', cellType)
            structA.Nai = A(28-subtract,:);
            structA.IKNap = A(29-subtract,:);
            structA.IHVA = A(30-subtract,:)*1e6*Area;
            structA.IHVAm = A(31-subtract,:);
            structA.IAMPA = A(32-subtract,:);
            structA.INMDA = A(33-subtract,:);
            structA.ImGluR1a = A(34-subtract,:);
            structA.ImGluR1aR = A(35-subtract,:);
            structA.ImGluR1aG = A(36-subtract,:);
            structA.IGABAa = A(37-subtract,:);
            structA.IGap = A(38-subtract,:);
        end
    else
        structA.IS = A(4-subtract,:)*1e6*Area(1);
        structA.IleakS = A(5-subtract,:)*1e6*Area(1);
        structA.INaleakS = A(6-subtract,:)*1e6*Area(1);
        structA.INaS = A(7-subtract,:)*1e6*Area(1);
        structA.NaiS = A(8-subtract,:);
        structA.INamS = A(9-subtract,:);
        structA.INahS = A(10-subtract,:);
        structA.INaPmS = A(11-subtract,:);
        structA.IKS = A(12-subtract,:)*1e6*Area(1);
        structA.IKnS = A(13-subtract,:);
        structA.IARnS = A(14-subtract,:);
        structA.vD = A(15-subtract,:);
        structA.ID = A(16-subtract,:)*1e6*Area(2);
        structA.IleakD = A(17-subtract,:)*1e6*Area(2);
        structA.INaleakD = A(18-subtract,:)*1e6*Area(2);
        structA.INaD = A(19-subtract,:)*1e6*Area(2);
        structA.NaiD = A(20-subtract,:);
        structA.INamD = A(21-subtract,:);
        structA.INahD = A(22-subtract,:);
        structA.INaPmD = A(23-subtract,:);
        structA.IKD = A(24-subtract,:)*1e6*Area(2);
        structA.IAaD = A(25-subtract,:);
        structA.IAbD = A(26-subtract,:);
        structA.IMnD = A(27-subtract,:);
        structA.IKCanD = A(28-subtract,:);
        structA.IAHPD = A(29-subtract,:);
        structA.IAHPm2D = A(30-subtract,:);
        structA.IARnD = A(31-subtract,:);
        structA.ICaD = A(32-subtract,:)*1e6*Area(2);
        structA.CaiD = A(33-subtract,:)*1e6;
        structA.IHVAmD = A(34-subtract,:);
        structA.IHVAhD = A(35-subtract,:);
        structA.ITmD = A(36-subtract,:);
        structA.IThD = A(37-subtract,:);
        structA.IhD = A(38-subtract,:)*1e6*Area(2);
        structA.IhmD = A(39-subtract,:);
        structA.IAMPAD = A(40-subtract,:);
        structA.INMDAD = A(41-subtract,:);
        structA.IGABAaS = A(42-subtract,:);
        structA.IGABAbS = A(43-subtract,:);
        structA.IGABAbS_R = A(44-subtract,:);
        structA.IGABAbS_G = A(45-subtract,:);
    end
elseif strcmp('11', fileName(2:3))
    n = length(A)/(15-subtract);
    A = reshape(A,n,15-subtract)';
    structA.ICaD = A(3-subtract,:)*1e6*Area(2);
    structA.CaiD = A(4-subtract,:)*1e6;
    structA.IHVAmD = A(5-subtract,:);
    structA.IHVAhD = A(6-subtract,:);
    structA.ITmD = A(7-subtract,:);
    structA.IThD = A(8-subtract,:);
    structA.IhD = A(9-subtract,:)*1e6*Area(2);
    structA.IhmD = A(10-subtract,:);
    structA.Ihp0D = A(11-subtract,:);
    structA.Ihp1D = A(12-subtract,:);
    structA.IhcD = A(13-subtract,:);
    structA.Iho1D = A(14-subtract,:);
    structA.Iho2D = A(15-subtract,:);
elseif strcmp('20', fileName(2:3))
    n = length(A)/shortFile;
    A = reshape(A,n,shortFile)';
    structA.v = A(shortFile,:);
elseif strcmp('30', fileName(2:3)) || strcmp('41', fileName(2:3)) || strcmp('42', fileName(2:3)) || strcmp('43', fileName(2:3)) || strcmp('44', fileName(2:3))
    n = length(A)/shortFile;
    A = reshape(A,n,shortFile)';
    structA.iSyn = A(shortFile,:);
elseif strcmp('40', fileName(2:3))
    n = length(A)/(3-subtract);
    A = reshape(A,n,3-subtract)';
    structA.iGlu = A(2-subtract,:);
    structA.iGABA = A(3-subtract,:);
elseif strcmp('50', fileName(2:3))
    if strcmp('TC', cellType)
        n = length(A)/shortFile;
        A = reshape(A,n,shortFile)';
        structA.v = A(shortFile,:);
    elseif strcmp('NRT', cellType)
        n = length(A)/shortFile;
        A = reshape(A,n,shortFile)';
        structA.v = A(shortFile,:);
    elseif strcmp('Cx3', cellType)
        n = length(A)/(4-subtract);
        A = reshape(A,n,4-subtract)';
        structA.v = A(2-subtract,:);
        structA.iGlu = A(3-subtract,:);
        structA.iGABA = A(4-subtract,:);
    end
end

if strcmp('z', fileName(1))
    %structA.t = (0:0.1:(size(A,2)-1)*0.1);
    structA.t = (0:0.25:(size(A,2)-1)*0.25);
else
    structA.t = A(1,:);
end

if strcmp('Cx3', cellType)
    cellType = fileName(20:22);
    cellType = strrep(cellType,'.','');
end
