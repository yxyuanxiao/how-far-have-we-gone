# Data Preprocessing

This folder converts the released human annotations into the distribution-based soft
labels used to train the per-dimension IQA models.

## Input: the released dataset

Download the dataset (see the main README) so the `data/` root sits next to this repo.
Each subset ships a `dataset_info.json` (a list of LQ images, each with a `results`
map of `{method: {image_path, annotations}}`, where `annotations` holds the raw
`Details / Sharpness / Semantics / Overall` scores):

```
data/
├── Real_World/
│   ├── dataset_info.json
│   ├── lq/                 # low-quality inputs (images)
│   └── results/<method>/   # restored images, 20 methods
└── Simulation/
    ├── dataset_info.json
    ├── lq/
    └── results/<method>/
```

## Output (generated here, git-ignored)

```
data_preprocess/
├── config.json             # (tracked) per-dimension questions + soft-label params
├── build_mos_labels.py     # (tracked) dataset_info.json -> per-metric MOS + split
├── gen_soft_label.py       # (tracked) per-metric MOS -> distribution soft labels
├── split.json              # (generated) train/test split (image paths)
├── json_dir/               # (generated) per-metric MOS files
│   ├── Visual_Clarity.json
│   ├── Sharpness_Naturalness.json
│   ├── Detail_Completeness.json
│   ├── Content_Conciseness.json
│   ├── Semantics.json
│   └── Overall_score.json
├── train/                  # (generated) soft-label train metas
└── test/                   # (generated) test metas
```

## Dimensions

The bipolar **Details** and **Sharpness** scores (`-3 … +3`, where `0` is best) are
each split into two unipolar metrics, so every model regresses a standard score:

| Released model (`checkpoints/`) | Metric                 | Source dimension        |
| ------------------------------- | ---------------------- | ----------------------- |
| `deqa_lora_detail`              | Detail Completeness    | Details, scores `<= 0`  |
| `deqa_lora_content`             | Content Conciseness    | Details, scores `>= 0`  |
| `deqa_lora_visual`              | Visual Clarity         | Sharpness, scores `<= 0`|
| `deqa_lora_sharpness`           | Sharpness Naturalness  | Sharpness, scores `>= 0`|
| `deqa_lora_semantics`           | Semantics              | Semantics (`0 … 4`)     |
| `deqa_lora_overall_score`       | Overall                | Overall (`0 … 4`)       |

## Pipeline

```shell
cd data_preprocess

# 1) parse dataset_info.json -> json_dir/<Metric>.json + split.json (9:1 split)
python build_mos_labels.py --data_root ../../data

# 2) build distribution soft labels for every metric in config.json
python gen_soft_label.py --config config.json
```

Step 2 writes `train/train_<Metric>.json` and `test/test_<Metric>.json`, which the
`scripts/train_*.sh` and `scripts/infer_*.sh` scripts consume. The `image` field in
each meta is the dataset-root-relative path, so the scripts pass the `data/` root via
`--image_folder` / `--root-dir`.
