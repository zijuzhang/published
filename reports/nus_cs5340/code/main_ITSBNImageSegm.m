
% #########################################################################
% ############ Tree Structure Image Segmentation ########################
% ========================================================================
% Mohammad Akbari, NGS,
% Shahab Ensafi, Soc,
% Fu Jie, NGS,
% National University of Singapore
% {Akbari, shahab.ensafi, jie.fu} @nus.edu.sg
% Thanks from Li Cheng, Kittipat Kampa and Matthew Zeiler
% ########################################################################



clear all
clc
close all

%set(0,'defaultFigureVisible','off');
set(0,'defaultFigureVisible','on');

% #########################################################################
% ############ point to the corresponding folders ########################
% ========================================================================
% Here, we can determine the path to:
% 1) superpixel algorithms: Mori's quickshift
% 2) BNT: Bayes Net Toolbox
% 3) image dataset: folder containing images need to be segmented
% ########################################################################

% ------- Determining the path ---------------
% vlfeat_dir = 'Z:\research\vlfeat-0.9.9\toolbox/vl_setup';
superpixe_mori_dir = 'E:\Courses\UncertaintyModelling\Project\CodesDatassets\superpixels_mori';
BNT_dir = 'C:\Matlab_Toolboxes\FullBNT-1.0.7\bnt';
% image_dataset_dir = '/home/student1/MATLABcodes/BSR/BSDS500/data/images/test';
% image_dataset_dir = '/home/student1/MATLABcodes/BSR/BSDS500/data/images/train';
% image_dataset_dir = '/home/student1/MATLABcodes/BSR/bench/data/img_bot';
image_dataset_dir = 'E:\Courses\UncertaintyModelling\Project\CodesDatassets\ImageSet';

% ------ Install necessary toolbox ------------------
% This code will install the VLFEAT toolbox for image segmentation
% run(vlfeat_dir) % put the VLFeat dir

% ------ Install BNT -------

original_folder = pwd;
eval(['cd ',BNT_dir]);
addpath(genpathKPM(pwd));
%original_folder = ['"', original_folder, '"']
eval(['cd ',original_folder]);



%% ########################################################################
% ################### retrieve the image filename ######################
% ========================================================================
% This section retrieves all the file name in the image dataset folder
% ########################################################################

% -------- list all the files in the image dataset directory -------
fileList = fn_getAllFiles(image_dataset_dir);
image_list = cell(length(fileList),2); % first column: imageID, second column: img extenstion
image_cnt = 1;
for i = 1:length(fileList)
    [pathstr, name, ext] = fileparts(fileList{i});
    % User can add the list of valid image extension below:
    if strcmp(ext,'.jpg') || strcmp(ext,'.bmp')
        image_list{image_cnt,1} = name;
        image_list{image_cnt,2} = ext;
        image_cnt = image_cnt + 1;
    end
end
image_list = image_list(1:image_cnt-1,:);
ImageNum = length(fileList)


%% ========================================================================
% ########################################################################
% ######################### MAIN PROGRAM #################################
% #########################################################################
% =========================================================================
% The main section contains the core process of ITSBN listing from
% 1) making superpixels, 2) make a tree, 3) extract feature, 4) GMM
% segmentation and 4) ITSBN segmentation
% The code apply those processes to all images in the dataset folder.
% #########################################################################


addpath(genpath(superpixe_mori_dir)); % superpixel code folder and subfolders


%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%DEBUG STUFF
%ImageNum = 1

for i = ImageNum %157:length(fileList)
    close all;
    disp(['processing #',num2str(i),' image ',image_list{i,1},image_list{i,2}]);
    imagename = image_list{i,1};
    imageext = image_list{i,2};
    
    % make a directory
    [s,mess,messid] = mkdir(['./',imagename]);
    disp(mess);

    % ==== copy the original image to the folder ======
    copyfile([image_dataset_dir,'/',imagename,image_list{i,2}],['./',imagename]);
    
    % #####################################################################
    % ======================== SUPERPIXEL ==========================
    % In this section, we can choose superpixel algorithm to process the
    % input image. Now we support 2 algorithms: 1) Quickshift and 2) Mori's
    % Greg.
    % =====================================================================
    % #####################################################################
    
    % ====================== QuickShift ===================================
    % There are 2 parameters for quickshift: 1) Thesize of the blur kernel
    % and 2) The maximum distance list
    % =====================================================================
    %blursize = 2;
    %MaxDist_list = [5 20 50 80]; %[5 10 20 35 50 80];
    
    %fn_QuickShiftSingleImage(imagename,imageext, blursize, MaxDist_list);
    
    % ====================== Mori's NCUT ==================================
    % Since we have L = 6 levels for an image, there will be 4 intermediate
    % levels, 4 to 1. There are several settings the user can pick from.
    % =====================================================================
%     N_ev = 5; N_sp3 = 20; N_sp2 = 75; N_sp1 = 300; % setting#1 takes 230 sec/itt
     N_ev = 5; N_sp3 = 20; N_sp2 = 50; N_sp1 = 200; % setting#2 46 sec/itt
%     N_ev = 5; N_sp3 = 20; N_sp2 = 50; N_sp1 = 150; % setting#3 15 sec/itt
%    N_ev = 5; N_sp3 = 20; N_sp2 = 50; N_sp1 = 100; % setting#4 5 sec/itt
%     N_ev = 5; N_sp3 = 20; N_sp2 = 30; N_sp1 = 50; % setting#5 2 sec/itt

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    fn_SuperpixelMori1(imagename, imageext, N_ev, N_sp3, N_sp2, N_sp1);
 
    % #################### CONSTRUCT AN ITSBN #############################
    % This code construct an ITSBN tree out of the hierarchical
    % segmentation from the previous process (superpixel). The level of the
    % tree depends on how many levels we have from the previous process,
    % and there is no limitation on how many levels this code can
    % construct. Essentially, this code takes hierarchical segments as an
    % input, and output all necessary information about ITSBN including the
    % structure matrix Z. 
    % #####################################################################
    fn_makeTreeFromLabel(imagename);
    
    % ######################## FEATURE EXTRACTION #########################
    % Extract features from an image =====
    % #####################################################################
    fn_imageFeatureExtraction(imagename, imageext);
    
    % ######################## IMAGE SEGMENTATION #########################
    % There are 2 unsupervised image segmentation in the section: 1) GMM
    % and 2) ITSBN. GMM will be exploited as the initial value for ITSBN.
    % The user can pick the number of cluster and the maximum iteration
    % number a priori. 
    % #####################################################################
    
    % =============== segmentation parameters =============================
    filename_input = [imagename,'_package']; % tiger
    exp_number = imagename; %107;
    C = 4; % number of classes/mixtures in GMM
    iteration_max = 2;
    % =====================================================================
    
    close all;
    % ================== GMM segmentation on the image ====================
    W = [1 1 1 0 0]; % The weights for each feature
    [I_label, I_post] = fn_imgSegmentationGMM(imagename, imageext, C, W);
    
    % =====================================================================
    % ================== ITSBN segmentation on the image ==================
    % =====================================================================
    
    % Determine the number of image-class label for each level here:
    C = cell(6,2);
    for l = 0:5
        C{l+1,1} = l; % level Hl
    end
    C{0+1,2} = 0; % number of classes in level H0
    C{1+1,2} = 7; % number of classes in level H1 has the same number of label as in H0
    C{2+1,2} = 6; % number of classes in level H2
    C{3+1,2} = 5; % number of classes in level H3
    C{4+1,2} = 4; % number of classes in level H4
    C{5+1,2} = 3; % number of classes in level H5 (root)

    fn_ITSBNImageSegm2(filename_input,...
        imagename, imageext,...
        C,...
        iteration_max,...
        exp_number);
    % =====================================================================
    
    %movefile(['./',imagename,'.mat'], ['/home/student1/MATLABcodes/BSR/bench/data/segs_bot']);
 
end

% ----- remove all the paths -------
% rmpath(image_dataset_dir); % dir of images
% rmpath('./QuickShift_ImageSegmentation'); % image segmentation code dir
% rmpath('/home/student1/MATLABcodes/superpixels');



set(0,'defaultFigureVisible','on');

