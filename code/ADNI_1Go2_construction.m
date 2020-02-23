%% 2018-Summer_Work_Gavin_Gao
clear all; close all; clc;

%% Summarize all Dx information from ADNI 1, Go, and 2

dirName = pwd;
% fileName = string('ADNI1_Go_2_Dx_Summary');
% fileDirt = strcat(dirName, string('/'), fileName);
% 
% [Dx_num, Dx_txt, ~ ]=xlsread(fileDirt);
% Dx_txt(1,:)=[ ];
%% Summarize all T1 MRI information from ADNI 1, Go, and 2
fileName = string ('ADNI_MRI_123_cross_sectional');
fileDirt = strcat(dirName, string('/'), fileName);

[Im_num, Im_txt, Im_raw ]=xlsread(fileDirt);
Im_txt(1,:)=[ ];

%% Summarize all MMSE information from ADNI 1, Go, and 2
fileName = string('ADNI1_Go_2_MMSE');
fileDirt = strcat(dirName, string('/'), fileName);

[MMSE_num, MMSE_txt, MMSE_raw ]=xlsread(fileDirt);
MMSE_txt(1,:)=[ ];

%% Summarize all merged information from ADNI 1, Go, and 2
fileName = string('ADNI_1_Go_2_Merge');
fileDirt = strcat(dirName, string('/'), fileName);

[Merge_num, Merge_txt, ~ ]=xlsread(fileDirt);
Merge_txt(1,:)=[ ];

Dx_num = Merge_num(:, [1 5 29 4]);% PTID date_num Dx ADNI_phase
Dx_txt = Merge_txt(:, 30);% date_txt
delete = isnan(Dx_num(:,3));
Dx_num(delete, :)=[];
Dx_txt(delete, :)=[];

%% Summarize all AV45 information from ADNI 1, Go, and 2
fileName = string('ADNI_1_Go_2_AV45');
fileDirt = strcat(dirName, string('/'), fileName);

[AV45_num, AV45_txt, AV45_raw] = xlsread(fileDirt);
AV45_txt(1,:) = [ ];

%% Summarize all ASL information from ADNI 1, Go, and 2
fileName = string('ADNI_1_Go_2_ASL');
fileDirt = strcat(dirName, string('/'), fileName);

[ASL_num, ASL_txt, ASL_raw] = xlsread(fileDirt);
ASL_txt(1,:) = [ ];

%% Create structure ADNI_1_Go_2

ADNI_1Go2 = struct;

% find the number of patients with MR images
im_RID = unique(Im_num(:,2));
Dx_RID = unique(Dx_num(:,1));
Merge_RID = unique(Merge_num(:,1));
Im_without_Dx = setdiff(im_RID, Dx_RID);
Dx_without_Merge = setdiff(Dx_RID,Merge_RID);
 orphan_case = unique([Im_without_Dx; Dx_without_Merge]);

for i=1:length(orphan_case) 
    ID_delete = find(Im_num(:,2)==orphan_case(i));
    Im_num(ID_delete,:)=[ ];% delete images without Dx or Dx without merge information
    Im_txt(ID_delete,:)=[ ];
end
num_pt_im = length(unique(Im_num(:,2)));
im_RID = unique(Im_num(:,2));
%% construct merged list for patinets with images (unknown=0 ,never married=1, married=2, divorced=3, widowed=4)
for i=1:num_pt_im
    ID_Im = im_RID(i);
    
    mat_Dx = Dx_num(Dx_num(:,1)==ID_Im, [1 2 3 4]);
    mat_Dx_date = Dx_txt(Dx_num(:,1)==ID_Im, 1);
    if length(find(mat_Dx(:,1)==0))==2 % delete 'sc' with the existence of 'bl' 
        mat_Dx(1,:) = [ ];
        mat_Dx_date(1,:) = [ ];
    end
    first_date = mat_Dx(1,2);
    month_Dx = round((mat_Dx(:,2)-ones(size(mat_Dx,1),1).*first_date) ./ 180) .* 6;
    
    mat_Im = Im_num(Im_num(:,2)==ID_Im, [3 1 6:125 4]);
    num_im = size(mat_Im,1);
    month_Im = round((mat_Im(:,end)-ones(size(mat_Im,1),1).*first_date) ./ 180) .* 6;
    mat_Im(:,1) = month_Im;
    
    [uniq_im, i_uniq] = unique(month_Im);
    i_copy = setdiff( transpose(1:num_im) , i_uniq);  
      if size(i_copy,1)>0
       month_copy = mat_Im(i_copy, 1);
       month_copy = unique(month_copy);   
         for j=1: length(month_copy)
            temp_mat = mat_Im(mat_Im(:,1)==month_copy(j), :);
            length_temp = size(temp_mat,1);
            temp_phase = temp_mat(:, 2);
            max_phase = max(temp_phase);
            temp_qc = temp_mat(:,3);
            max_qc = max(temp_qc);
            
            i_max_phase = double(temp_phase==max_phase);
            i_max_qc = double(temp_qc == max_qc).*2;
            score = i_max_phase + i_max_qc;
            i_max = (score==max(score));
            
            mat_max = temp_mat(i_max,:);
            mat_avg = nanmean(mat_max,1);
            mat_Im( mat_Im(:,1)==month_copy(j) ,:) = ones(length_temp, size(mat_Im,2)) .* mat_avg;         
         end
      end
    mat_Im = unique(mat_Im,'rows','stable');
    month_Im =mat_Im(:,1);
    
    mat_Merge = Merge_num(find(Merge_num(:,1)==ID_Im),[2 6:28 4 5]); % '4' here indicates the study phase of ADNI (1, Go, 2, or 3)
    month_Merge = round((mat_Merge(:,end)-ones(size(mat_Merge,1),1).*first_date) ./ 180) .* 6;
    mat_Merge(:,1) = month_Merge;
    
    mat_AV45 = AV45_num(find(AV45_num(:,1)==ID_Im),[2 4 5:90 3]);
    mat_AV45(:,3:88) = mat_AV45(:,3:88) ./ mat_AV45(:,2); %calculate SUVR over whole cerebellum
    month_AV45 = round((mat_AV45(:,end)-ones(size(mat_AV45,1),1).*first_date) ./ 180) .* 6;
    mat_AV45(:,1) = month_AV45;
    
    mat_ASL = ASL_num(find(ASL_num(:,1)==ID_Im),[3 7 9:94 5]);
    month_ASL = round((mat_ASL(:,end)-ones(size(mat_ASL,1),1).*first_date) ./ 180) .* 6;
    mat_ASL(:,1) = month_ASL;
    
    mat_MMSE = MMSE_num(find(MMSE_num(:,1)==ID_Im),[2 5:35]);
    month_MMSE = mat_MMSE(:,1);
    
    num_follow = length(month_Dx);
    
    [inter_Im_Dx, Im_Dx, Dx_Im] = intersect(month_Im, month_Dx);
    [inter_Merge_Dx, Merge_Dx, Dx_Merge] = intersect(month_Merge, month_Dx);
    [inter_MMSE_Dx, MMSE_Dx, Dx_MMSE] = intersect(month_MMSE, month_Dx);
    [inter_AV45_Dx, AV45_Dx, Dx_AV45] = intersect (month_AV45, month_Dx);
    [inter_ASL_Dx, ASL_Dx, Dx_ASL] = intersect (month_ASL, month_Dx);
    
    ADNI_1Go2(i).RID = ID_Im;  % field 1
    ADNI_1Go2(i).mon_bl = month_Dx; % field 2
    ADNI_1Go2(i).mon_tot = month_Dx(end); % field 3
    ADNI_1Go2(i).exam_date = mat_Dx_date;  % field 4
    
    exam_mr = zeros(size(month_Dx,1),1);
    exam_mr(Dx_Im)= mat_Im(Im_Dx, 2);
%     exam_mr(Dx_Im)= mat_Dx(Dx_Im, 4); % NO! We can not trust the study
%     phase information from MERGE. file
    ADNI_1Go2(i).exam_mr = exam_mr;% field 5 indicating the MR coming from ADNI1 or Go(1.5) or 2
    
    exam_AV45 = zeros(1,size(month_Dx,1),1);
    exam_AV45(Dx_AV45)=1;
    ADNI_1Go2(i).exam_AV45 = exam_AV45; % field 6
    
    exam_ASL = zeros(1,size(month_Dx,1),1);
    exam_ASL(Dx_ASL)=1;
    ADNI_1Go2(i).exam_ASL = exam_ASL; % field 7
    
    vec_Age = NaN .* ones(num_follow, 1);
    vec_Age(Dx_Merge) = mat_Merge(Merge_Dx,5)+mat_Merge(Merge_Dx, 6);
    ADNI_1Go2(i).age = vec_Age;  % field 8
    
    ADNI_1Go2(i).gender = mat_Merge(1,2);  % field 9
    ADNI_1Go2(i).marriage = mat_Merge(1,3);  % field 10
    ADNI_1Go2(i).edu = mat_Merge(1,4);  % field 11
    
    % dealing with Dx vectors
    vec_Dx = mat_Dx(:,3);
    vec_natural = vec_Dx;
    vec_natural(find(vec_natural==7))=1;
    vec_natural(find(vec_natural==9))=1;
    vec_natural(find(vec_natural==4))=2;
    vec_natural(find(vec_natural==8))=2;
    vec_natural(find(vec_natural==5))=3;
    vec_natural(find(vec_natural==6))=3;
    vec_stringent = vec_natural;
    
    trustable_Dx = 1;    
    if length(vec_stringent)>=3
       vec_stringent(1)= round(mean(vec_stringent(1:3)));
%        vec_stringent(end) = round(mean(vec_stringent((end-2):end)));
    else
    trustable_Dx = 0;                
    end
    
%     complex_Dx = 0;    
%     if length(find(vec_Dx>3))>=3
%             complex_Dx = 1;
%     else
%             complex_Dx = 0;
%     end
    
    convertor_Dx = 0;
    convertor_stringent = 0;
    if vec_Dx(end) > vec_Dx(1)
            convertor_Dx = 1;
    else
            convertor_Dx = 0;
    end
    
    if vec_stringent(end) > vec_stringent(1)
            convertor_stringent = 1;
    else
            convertor_stringent = 0;
    end
    
    Dx_bl = mat_Merge(1, 24);
    ADNI_1Go2(i).Dx_bl = Dx_bl;%vec_natural(1,1);  % field 12
    ADNI_1Go2(i).Dx_conv = convertor_Dx;  % field 13
    ADNI_1Go2(i).Dx_natural = vec_natural; % field 14
%     ADNI_1Go2(i).Dx_dynamic = vec_Dx; %
    ADNI_1Go2(i).Dx_strg = vec_stringent; % field 15
    ADNI_1Go2(i).Dx_bl_strg = vec_stringent(1, 1); % field 16
    ADNI_1Go2(i).Dx_conv_strg = convertor_stringent; % field 17
    ADNI_1Go2(i).Dx_trustable = trustable_Dx; % field 18
%     ADNI_1Go2(i).cmplx_case = complex_Dx; % 
    
    ADNI_1Go2(i).APOE4 = mat_Merge(1,8); % field 19
    
    vec_CSF_ABETA = NaN .* ones(num_follow, 1);
    vec_CSF_ABETA(Dx_Merge) = mat_Merge(Merge_Dx,20);
    ADNI_1Go2(i).CSF_ABETA = vec_CSF_ABETA; % field 20
    
    vec_CSF_TAU = NaN .* ones(num_follow, 1);
    vec_CSF_TAU(Dx_Merge) = mat_Merge(Merge_Dx,21);
    ADNI_1Go2(i).CSF_TAU = vec_CSF_TAU; % field 21
    
    vec_CSF_PTAU = NaN .* ones(num_follow, 1);
    vec_CSF_PTAU(Dx_Merge) = mat_Merge(Merge_Dx,22);
    ADNI_1Go2(i).CSF_PTAU = vec_CSF_PTAU; % field 22
    
    vec_ADAS11 = NaN .* ones(num_follow, 1);
    vec_ADAS11(Dx_Merge) = mat_Merge(Merge_Dx,9);
    ADNI_1Go2(i).ADAS11 = vec_ADAS11; % field 23
    
    vec_ADAS13 = NaN .* ones(num_follow, 1);
    vec_ADAS13(Dx_Merge) = mat_Merge(Merge_Dx,10);
    ADNI_1Go2(i).ADAS13 = vec_ADAS13; % field 24
    
    vec_RAVLT_i = NaN .* ones(num_follow, 1);
    vec_RAVLT_i(Dx_Merge) = mat_Merge(Merge_Dx,11);
    ADNI_1Go2(i).RAVLT_immediate = vec_RAVLT_i; % field 25
    
    vec_RAVLT_l = NaN .* ones(num_follow, 1);
    vec_RAVLT_l(Dx_Merge) = mat_Merge(Merge_Dx,12);
    ADNI_1Go2(i).RAVLT_learning = vec_RAVLT_l; % field 26
    
    vec_RAVLT_f = NaN .* ones(num_follow, 1);
    vec_RAVLT_f(Dx_Merge) = mat_Merge(Merge_Dx,13);
    ADNI_1Go2(i).RAVLT_forgetting = vec_RAVLT_f; % field 27
    
    vec_RAVLT_pf = NaN .* ones(num_follow, 1);
    vec_RAVLT_pf(Dx_Merge) = mat_Merge(Merge_Dx,14);
    ADNI_1Go2(i).RAVLT_perc_forgetting = vec_RAVLT_pf; % field 28
    
    vec_FAQ = NaN .* ones(num_follow, 1);
    vec_FAQ(Dx_Merge) = mat_Merge(Merge_Dx,16);
    ADNI_1Go2(i).FAQ = vec_FAQ; % field 29
    
    vec_CDR = NaN .* ones(num_follow, 1);
    vec_CDR(Dx_Merge) = mat_Merge(Merge_Dx,17);
    ADNI_1Go2(i).CDR = vec_CDR; % field 30
  
    vec_TRAB = NaN .* ones(num_follow, 1);
    vec_TRAB(Dx_Merge) = mat_Merge(Merge_Dx,18);
    ADNI_1Go2(i).TRAB = vec_TRAB; % field 31
    
    vec_LDEL = NaN .* ones(num_follow, 1);
    vec_LDEL(Dx_Merge) = mat_Merge(Merge_Dx,19);
    ADNI_1Go2(i).LDEL = vec_LDEL; % field 32
   
    vec_MMSE = NaN .* ones(num_follow, 1);
    vec_MMSE(Dx_Merge) = mat_Merge(Merge_Dx,15);
%     ADNI_1Go2(i).MMSE = vec_MMSE; % field 33
    
    vec_MMSE_total = NaN .* ones(num_follow, 1);
    vec_MMSE_total(Dx_MMSE) = mat_MMSE(MMSE_Dx, 2);
    vec_MMSE_total(vec_MMSE_total<0)=NaN;
    vec_MMSE_total = nanmean([vec_MMSE_total, vec_MMSE], 2);
    ADNI_1Go2(i).MMSE_total = vec_MMSE_total; % field 33
    
    vec_MMSE_time = NaN .* ones(num_follow, 5);
    vec_MMSE_time(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 3:7);
    ADNI_1Go2(i).MMSE_time = vec_MMSE_time; % field 34
    
    vec_MMSE_place = NaN .* ones(num_follow, 5);
    vec_MMSE_place(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 8:12);
    ADNI_1Go2(i).MMSE_place = vec_MMSE_place;   % field 35
    
    vec_MMSE_registration = NaN .* ones(num_follow, 3);
    vec_MMSE_registration(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 13:15);
    ADNI_1Go2(i).MMSE_regstr = vec_MMSE_registration; % field 36
    
    vec_MMSE_attention = NaN .* ones(num_follow, 5);
    vec_MMSE_attention(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 16:20);
    ADNI_1Go2(i).MMSE_attn = vec_MMSE_attention; % field 37
    
    vec_MMSE_recall = NaN .* ones(num_follow, 3);
    vec_MMSE_recall(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 21:23);
    ADNI_1Go2(i).MMSE_recall = vec_MMSE_recall; % field 38
    
    vec_MMSE_language = NaN .* ones(num_follow, 2);
    vec_MMSE_language(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 24:25);
    ADNI_1Go2(i).MMSE_lang = vec_MMSE_language; % field 39
    
    vec_MMSE_repetition = NaN .* ones(num_follow, 1);
    vec_MMSE_repetition(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 26);
    ADNI_1Go2(i).MMSE_rept = vec_MMSE_repetition; % field 40
    
    vec_MMSE_complex = NaN .* ones(num_follow, 6);
    vec_MMSE_complex(Dx_MMSE,:) = mat_MMSE(MMSE_Dx, 27:32);
    ADNI_1Go2(i).MMSE_cmplx = vec_MMSE_complex;  % field 41
    
    % dealing with MR image
    vec_volume = NaN .* ones(num_follow, 118);
    vec_volume(Dx_Im,:) = mat_Im(Im_Dx, 5:122);
    ADNI_1Go2(i).vol_MRI = vec_volume; % field 42
    
    vec_ICV = NaN .* ones(num_follow, 1);
    vec_ICV(Dx_Im,:) = mat_Im(Im_Dx, 4);
    ADNI_1Go2(i).ICV = vec_ICV; % field 43
    
    vec_volume_QC =NaN .* ones(num_follow,1);
    vec_volume_QC(Dx_Im,:) = mat_Im(Im_Dx, 3);
    ADNI_1Go2(i).vol_QC = vec_volume_QC; % field 44
    
    % dealing with AV45 image
    vec_AV45_Desikan = NaN .* ones(num_follow,86);
    vec_AV45_Desikan(Dx_AV45,:) = mat_AV45(AV45_Dx, 3:88);
    ADNI_1Go2(i).AV45_Desikan = vec_AV45_Desikan; % field 45
    
    % dealing with ASL image
    vec_ASL_Desikan = NaN .* ones(num_follow,86);
    vec_ASL_Desikan(Dx_ASL,:) = mat_ASL(ASL_Dx, 3:88);
    ADNI_1Go2(i).ASL_Desikan = vec_ASL_Desikan; % field 46
    
    vec_ASL_QC =NaN .* ones(num_follow,1);
    vec_ASL_QC(Dx_ASL,:) = mat_ASL(ASL_Dx, 2);
    ADNI_1Go2(i).ASL_QC = vec_ASL_QC; % field 47

end

