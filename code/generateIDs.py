import os
import re
 
eeg_dir = '/home/data/NDClab/datasets/social-flanker-eeg-dataset/sourcedata/raw/eeg'
 
pattern = re.compile(r'^(16\d{4})_sfe_eeg(?:-flanker)?_s1-r1-e1\.eeg$')
 
ids = set()
for fname in os.listdir(eeg_dir):
    match = pattern.match(fname)
    if match:
        ids.add(match.group(1))
 
print('/'.join(sorted(ids)))