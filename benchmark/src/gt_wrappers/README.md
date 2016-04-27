
## Ground-Truth Wrappers
Code to homogenize the access to the different object ground trtuh datasets (COCO, Pascal, SBD).

### Usage
- Point `db_root_dir.m` to the folder where each database is stored in your system.
- For COCO, download and compile `coco_api` in the same folder than the COCO dataset.
- Test by running `demo.m` or `demo_script.m`.

### Current compatibility
- COCO, Pascal, SBD, both to read images and ground truth.
- ILSVRC only to read images.

### Note
The code reads the different ground-truth subsets (train, test, etc.) from a file in `gt_sets`.
The majority of sets are already created, but if you need one not in `gt_sets` either ask me to add it or create it yourself using the following commands:
```
ls image_folder > tmp.txt
sed -e 's/.jpg//g' -i tmp.txt > gt_set_ids.txt
```
Where you should change the `.jpg` by the images extension (`.JPEG` in ILSVRC for example).
