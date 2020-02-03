dist_th = 0.1;

slice_idx = 70;
Tp = final_journal(slice_idx-1);     % previous slice
Tc = final_journal(slice_idx);       % current slice
Tn = final_journal(slice_idx+1);     % next slice

Ap = logical(Tp);
s = regionprops(Ap,'centroid');
centp = cat(1, s.Centroid);
centpx = centp(:,1);
centpy = centp(:,2);

Ac = logical(Tc);
s = regionprops(Ac,'centroid');
centc = cat(1, s.Centroid);
centcx = centc(:,1);
centcy = centc(:,2);

An = logical(Tn);
s = regionprops(An,'centroid');
centn = cat(1, s.Centroid);
centnx = centn(:,1);
centny = centn(:,2);

A = false(size(Ac));

A(sub2ind(size(A), round(centpy), round(centpx))) = true;
A(sub2ind(size(A), round(centny), round(centnx))) = true;

D = norm01(bwdist(A)) < dist_th;
T = Ac & D;

ACTUAL_V = imread(strcat('combined\\DICOM_GT\\Ground_DCM_',int2str(slice_idx),'.png')); ACTUAL_V = (ACTUAL_V(:,:,1) ~= ACTUAL_V(:,:,2));
EVAL_V = Evaluate(ACTUAL_V(:), T(:))

slice_loc = 'combined\\';
slice_grey = imread(strcat(slice_loc, 'Input_DCM_', int2str(slice_idx), '.png'));       % original low-res DICOM slices

slice_grey(T > 0) = 255;
imshow(slice_grey);