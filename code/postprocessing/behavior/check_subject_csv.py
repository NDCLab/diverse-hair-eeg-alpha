import os
import re
import glob

input_dataset_path = "/home/data/NDClab/datasets/read-study2-dataset/"
data_path = "sourcedata/raw/s1_r1/psychopy/"
skip_subjects = ["3300118", "3300138"] #subs with _1 after s1_r1_e1 in reading-ranger filenames

sub_folders = [i for i in os.listdir(input_dataset_path + data_path) if i.startswith("sub-")]
subjects = sorted([re.findall(r'\d+', item)[0] for item in sub_folders])
for sub in subjects:
    if sub in skip_subjects:
        print(f"sub-{sub} skipped (in skip list)")
        continue
    subject_folder = (input_dataset_path + data_path + "sub-" + sub + os.sep)
    num_files = len(os.listdir(subject_folder))
    if (num_files != 6):
        print("sub-{} has unresolved deviation in psychopy data ({} files), skipping ...".format(sub, num_files))
        pass
    else:
        print("sub-{} checked".format(sub))    
        pattern_arrow = "{}sub-{}_arrow-alert-nf-v1-2_psychopy_s1_r1_e1.csv".format(subject_folder, sub)
        assert len(glob.glob(pattern_arrow)) != 0, f"sub-{sub} arrow-alert .csv has deviation in filename"
        pattern_reading = "{}sub-{}_reading-ranger-v2-*_psychopy_s1_r1_e1.csv".format(subject_folder, sub)
        assert len(glob.glob(pattern_reading)) != 0, f"sub-{sub} reading-ranger .csv has deviation in filename"