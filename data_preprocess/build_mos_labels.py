import argparse
import json
import os
import random


# Decouple the two bipolar dimensions (Sharpness, Details; range -3 .. +3, where 0
# is the perceptual optimum) into four unipolar metrics so each can be trained as a
# standard quality score. Index into these tables gives the unipolar "mos".
score_table_nega = [-3, -2.5, -2, -1.5, -1, -0.5, 0]   # negative side (<= 0)
score_table_posi = [0, 0.5, 1, 1.5, 2, 2.5, 3]         # positive side (>= 0)

# Output file stem for each metric (config.json / scripts refer to these names).
METRICS = [
    "Visual_Clarity",        # Sharpness, scores <= 0
    "Sharpness_Naturalness", # Sharpness, scores >= 0
    "Detail_Completeness",   # Details,   scores <= 0
    "Content_Conciseness",   # Details,   scores >= 0
    "Semantics",             # 0 .. 4
    "Overall_score",         # Overall, 0 .. 4
]


def load_records(data_root, subsets):
    """Flatten the released dataset_info.json files into (image_path, annotations).

    Each released subset is a list of LQ images; every LQ image holds a ``results``
    map of {method_name: {image_path, annotations}}. We emit one record per restored
    image, keyed by its dataset-root-relative ``image_path`` (which is unique).
    """
    records = []
    for sub in subsets:
        info_path = os.path.join(data_root, sub, "dataset_info.json")
        with open(info_path, "r", encoding="utf-8") as f:
            info = json.load(f)
        for item in info:
            for _method, res in item["results"].items():
                records.append((res["image_path"], res["annotations"]))
    return records


def build_mos_files(records, save_dir):
    """Convert raw annotations into per-metric MOS files keyed by image_path."""
    result = {m: {} for m in METRICS}
    for img, ann in records:
        sharp, detail = ann["Sharpness"], ann["Details"]

        # Sharpness -> Visual Clarity (<= 0) / Sharpness Naturalness (>= 0)
        if sharp < 0:
            result["Visual_Clarity"][img] = {"mos": score_table_nega.index(sharp), "std": 0.0}
        elif sharp > 0:
            result["Sharpness_Naturalness"][img] = {"mos": score_table_posi.index(sharp), "std": 0.0}
        else:
            result["Visual_Clarity"][img] = {"mos": 6, "std": 0.0}
            result["Sharpness_Naturalness"][img] = {"mos": 6, "std": 0.0}

        # Details -> Detail Completeness (<= 0) / Content Conciseness (>= 0)
        if detail < 0:
            result["Detail_Completeness"][img] = {"mos": score_table_nega.index(detail), "std": 0.0}
        elif detail > 0:
            result["Content_Conciseness"][img] = {"mos": score_table_posi.index(detail), "std": 0.0}
        else:
            result["Detail_Completeness"][img] = {"mos": 6, "std": 0.0}
            result["Content_Conciseness"][img] = {"mos": 6, "std": 0.0}

        # Semantics and Overall are already unipolar (0 .. 4)
        result["Semantics"][img] = {"mos": ann["Semantics"], "std": 0.0}
        result["Overall_score"][img] = {"mos": ann["Overall"], "std": 0.0}

    os.makedirs(save_dir, exist_ok=True)
    for metric, content in result.items():
        save_path = os.path.join(save_dir, f"{metric}.json")
        with open(save_path, "w", encoding="utf-8") as f:
            json.dump(content, f, indent=4, ensure_ascii=False)
        print(f"Saved: {save_path} ({len(content)} items)")


def build_split(records, save_path, train_ratio, seed):
    """Random train/test split over restored-image keys (default 9:1)."""
    imgs = [img for img, _ in records]
    random.seed(seed)
    random.shuffle(imgs)
    n_train = int(round(len(imgs) * train_ratio))
    split = {"train": imgs[:n_train], "test": imgs[n_train:]}
    with open(save_path, "w", encoding="utf-8") as f:
        json.dump(split, f, indent=4)
    print(f"Saved: {save_path} (train {n_train}, test {len(imgs) - n_train})")


def parse_args():
    parser = argparse.ArgumentParser(description="Build per-metric MOS files and the train/test split from the released dataset_info.json")
    parser.add_argument("--data_root", type=str, default="../../data",
                        help="Folder containing the released subsets (Real_World/, Simulation/)")
    parser.add_argument("--subsets", type=str, nargs="+", default=["Real_World", "Simulation"])
    parser.add_argument("--json_dir", type=str, default="json_dir", help="Output dir for per-metric MOS files")
    parser.add_argument("--split_path", type=str, default="split.json", help="Output path for the train/test split")
    parser.add_argument("--train_ratio", type=float, default=0.9)
    parser.add_argument("--seed", type=int, default=131)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    records = load_records(args.data_root, args.subsets)
    print(f"Loaded {len(records)} restored-image annotations from {args.subsets}")
    build_mos_files(records, args.json_dir)
    build_split(records, args.split_path, args.train_ratio, args.seed)
