# ADNI_COMB
--A pipeline combing the latest csv. files from ADNI-1, Go, 2, and 3 in format of Pdandas DataFrame--
##### Xiao Gao, Department of Radiology and Biomedical Imaging, UCSF; Myriam Chaumail Lab (xiao.gao@ucsf.edu; xiao.gao@berkeley.edu)  

#### Purpose: Reorganizing the latest open-sourced ADNI csv. files from http://adni.loni.usc.edu by using Jupyter notebook; focusing on imaging data

#### Prerequisite: Authorized access to ADNI database and having dowloaded necessary csv. files 

#### Data Framework: Mainly based on adnimerge.csv by Michael C. Donohue, et al., UCSD

#### Notice: This document is presented by the author(s) as a service to ADNI data users. However, users should be aware that no formal review process has vetted this document and that ADNI cannot guarantee the accuracy or utility of this document. This document merely assists in reorganization of variant types of ADNI data, and for a meaningful and in-depth interpretation of any underlying correlation between different data subsets, the user(s) is recommended to get familiar with each subset's own study protocol and analytical method. 



## Workflow:
#### 1. Getting access to ADNI data
#####    - Register your own account on http://adni.loni.usc.edu
#####    - Follow `DATA & SAMPLES` --> `ACCESS DATA AND SAMPLES` --> `DOWNLOAD` --> `Study Data` to search through ADNI data library
#####    - In most cases, the processed ADNI data packages are in `csv.` format, and you need to first decide what sort of biological data you are interested in 
#####    - Download all your `csv. files of interest` to anywhere belonging to the parent directory of our `ADNI_COMB.ipynb` file
#####    - Our code `ADNI_COMB.ipynb` will refer to your shopping list to loacte all csv. files within its parent directory 
#####    - Our code `ADNI_COMB_LT.ipynb` is an optional choice for your research if you want a cleaner version of ADNI neuroimaging database. Its construction needs the output from `ADNI_COMB.ipynb` first. Apart from the size difference between `ADNI_COMB` and `ADNI_COMB_LT`, in `ADNI_COMB_LT` all clinical visits from one certain subject share a single `dataframe index`, while `ADNI_COMB` lets each clinical visit occupy its own index.
#####  
#### 2. Creating a list of `csv. files of interest` for your own study purposes (shopping list)
#####    - It is a shopping list created offline before starting everything as following. Generally speaking, it might be the only thing you need to DIY to reproduce this pipeline's result. Meanwhile, we Do provide our own list in this repository to save your trouble. Please, be our guest! :)

#####    - `ADNIMERGE.csv` must be recruited in your shopping list, which is the essential foundation of this pipeline.

#####    - If you want to reproduce our pipeline's result by focusing on your own `csv. files of interest`, it's necessary to name this list as `adnicomb_list.csv`, which of course should be in the format of `.csv`. It is also required to include the following entries by using the same naming method as `Table1`; case-sensitive, while order-insensitive. Otherwise, you can also hack into our `ADNI_COMB.ipynb` code to create your own way finding and loading csv. files.

#####    Table1: The essential entries in `adnicomb_list.csv` shopping list and 2 examples of csv. files
csv    |  alias  |  date_entry  |  subject_entry  |  subject_type  |  recruit  |
---- | ----- | ---------- | ------------- | ------------ | ------- |
ADNIMERGE.csv | merge|   EXAMDATE  |     RID      |       RID      |     1     |
MRILIST.csv   |mrimeta|  SCANDATE  |   SUBJECT    |      PTID      |     1     |
###### `csv`: the csv. file's name of your research interest, subject to change according to version update from ADNI website
###### `alias`: a nickname for benefit of future calling upon data subsets; it would be added as a prefix in the ouput DataFrame in front of all the columns coming from this csv. file
###### `date_entry`: the exact column naming of examination date in the csv. file; it could be 'EXAMDATE', 'SCANDATE', 'VISCODE', or 'VISCODE2'; it is of significant importance to help locate when those clinical data have been collected.
###### `subject_entry`: the exact column naming of subject identification in the csv. file; it could be 'RID', 'PTID', or 'subject'
###### `subject_type`: telling the subject id type belonging to whether `RID` or `PTID`; these two id types are basically the same but some csv. files only contain 'PTID', which has extra geographical information. For example, one subject with `RID` = 2, its `PTID` could be 011_S_0002 where the prefix `011` is its visit site's number.
###### `recruit`: a flag claiming that this csv .file is subject to recruitment to your Pandas DataFrame; `1` for recruitment, while leaving it empty for ignorance

#####    - Our example of 'adnicomb_list.csv' file is also provided in this repository, which includes all ADNI csv. files recruited by Ashish Raj lab, UCSF. They are all of the latest version by the time of 2019-9-23. This list covers almost all post-processed MRI (including T1, ASL, DTI, fMRI) and PET data available from ADNI data library, majority of CSF and plasma post-processed biomarker data; however, no specific neuropsychological dataset so far (¡because the cognition metric battery in `ADNIMERGE` is already so awsome!). In the future, we would rountinely add more datasets.
#####  
#### 3. Reading ADNIMERGE.csv as Pandas DataFrame (done by `ADNI_COMB.ipynb`)
#####    - This dataset contains routinely updated ADNI subjects' Diagnosis, Exam Date, and Cognitive Scores, etc. from all clinical visit time-points
#####    - This dataset is truly helpful with data organization, in terms of localizing different types and sourses of data to a certain time window where they were collected.
 
#### 4. Stacking dataframes of interest over/alongside ADNIMERGE.csv(done by `ADNI_COMB.ipynb`)
#####    - Tansfer other `csv. files of interest` to Pandas DataFrame. According each DataFrame's `date_entry` and `subject_entry`, match its rows to `ADNIMERGE.csv` rows.
#####    - Law of subject matching: `RID` or `PTID` in `csv. files of interest` matches the same `RID` or `PTID` in `ADNIMERGE.csv`
#####    - Law of date matching (1): if `date_entry` = `VISCODE` or `VICCODE2`, then `VISCODE` or `VICCODE2` in `csv. files of interest` matches the same `VICCODE` in `ADNIMERGE.csv`. `VICCODE2` is one certain clinical visit's number of months from baseline, translated from `VISCODE` (a less straightforward coding method), but in several ADNI csv. files (including `ADNIMERGE.csv`) their so-called `VICCODE` entry is actually `VISCODE2` in nature, which should be noticed here.
#####    - Law of date matching (2): if `date_entry` = numeric date in format of `MM/DD/YYYY` or `YYYY/MM/DD`, then `date_entry` in `csv. files of interest` matches the nearest `date_entry` in `ADNIMERGE.csv`.
#####  
#####  
## Some Tips:
#### 1. No need to edit any downloaded csv. file before applying ADNI_COMB piepline
#####    - Except for `ADNI_EUROIMMUN.csv` (version 2019-4-18), which raw data has a double copy of all rows within the same file. We just simply deleted all the redundant records in site.
##### 
#### 2. Concerning multiple rows from `csv. files of interest` match one single row in `ADNIMERGE.csv`
#####    - Several ADNI studties might use different protocols to process the same sample of data and align the results in diffrent rows, although these records actually correspond to one single row/clinical vist in `ADNIMERGE.csv`. We insert single visit's multiple rows into a list and put it into a DataFrame's cell. For convience purposes, all cells in our `adnicomb` are in format of python list whatever it contains one single record or multiple records, thus when calling upon data from DataFrame cells in the future, we need treat them equally as python list(¡except for the data from `ADNIMERGE.csv`!)
##### 
#### 3. Brain region naming convention (some region names originally from ADNI database have been changed in `ADNI_COMB`)
#####    -Change `Left_PARSFR` and `Right_PARSFR` to `LeftInferiorFrontal` and `RightInferiorFrontal`, because according to the author's limited anatomical knowledge I guess the so-called `Pars Frontal` here is actually pars opercularis, pars triangularis, and pars orbitalis, whose combination is inferior frontal lobe.
#####    -Change `LeftCA2_3` and `RightCA2_3` to `LeftCA23` and `RightCA23`, just making life easier.
#####    -Change `LeftCA4_DG` and `RightCA4_DG` to `LeftCA4DG` and `RightCA4DG`, just making life easier.
##### 
##### 
## History versions:
#### 1. ADNI_COMB_V1.1 (2019/9/25)
#####    -Finishing csv-file-wise sampling checking, it is now safe to assume that all timepoints are all aligned finely along with ADNIMERGE.
##### 
#### 2. ADNI_COMB_V1.2 (2019/10/4)
#####    -Unifying all FreeSufer-resulted brain region naming conventions, according to one created ADNICOMB naming dictionary in the parent directory
##### 
#### 3. ADNI_COMB_V1.3 (2019/10/5)
#####    -Fixing one mistake concerning extra underscores after several naming conventions in `adnicomb_naimng_convention.csv`
##### 
#### 4. ADNI_COMB_V1.4 (2019/10/8)
#####    -Changing all `CereBellumCortex_SV` columns to `CereBellumCortex_CV`
#####    -Changing all `Thalamus_SV` columns to `Thalamus_CV`
#####    -Changing all `Caudate_SV` columns to `Caudate_CV`
#####    -Changing all `Putamen_SV` columns to `Putamen_CV`
#####    -Changing all `Pallidum_SV` columns to `Pallidum_CV`
#####    -Changing all `Hippocampus_SV` columns to `Hippocampus_CV`
#####    -Changing all `Amygdala_SV` columns to `Amygdala_CV`
#####    -Changing all `AccumbensArea_SV` columns to `AccumbensArea_CV`
#####    -Changing all `VentralDC_SV` columns to `VentralDC_CV`
##### 
#### 5. ADNI_COMB_V1.5 (2019/10/9)
#####    -Moving all NaN's into one list within each cell of the DataFrame
