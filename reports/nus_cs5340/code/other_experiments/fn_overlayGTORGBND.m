function Iorg_gt_boundary = fn_overlayGTORGBND(Iorg, Igt, Ibnd)
% #####################################################################
    % overlay the original image, the groundtruth and the boundary on the
    % same image
    % The original image can be either rgb or gray scale. 
    % #####################################################################

    if size(Iorg,3) == 1
        Itmp = Iorg;
        Iorg = repmat(Itmp,[1,1,3]);
    end
    
    
    % #########################################################################
    %          overlay the groundtruth on the original image
    % #########################################################################
    
    Iorg_gt = Igt;
    Iorg_gt(:,:,1) = Iorg_gt(:,:,1).*Iorg(:,:,1);
    Iorg_gt(:,:,2) = Iorg_gt(:,:,2).*Iorg(:,:,2);
    Iorg_gt(:,:,3) = Iorg_gt(:,:,3).*Iorg(:,:,3);
    % figure; imshow(Iorg_gt);
    
    % #########################################################################
    % overlay the boundary on top of the previous image
    % #########################################################################
    
    boundary_index = Ibnd == 1;
    
    Iorg_gt_boundary_R = Iorg_gt(:,:,1);
    Iorg_gt_boundary_G = Iorg_gt(:,:,2);
    Iorg_gt_boundary_B = Iorg_gt(:,:,3);
    
    Iorg_gt_boundary_R(boundary_index) = 1;
    Iorg_gt_boundary_G(boundary_index) = 1;
    Iorg_gt_boundary_B(boundary_index) = 1;
    
    Iorg_gt_boundary = Iorg_gt;
    Iorg_gt_boundary(:,:,1) = Iorg_gt_boundary_R;
    Iorg_gt_boundary(:,:,2) = Iorg_gt_boundary_G;
    Iorg_gt_boundary(:,:,3) = Iorg_gt_boundary_B;