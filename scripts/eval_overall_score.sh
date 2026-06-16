#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH

res_dir=./results/res_deqa_lora_overall_score/

# SRCC / PLCC for the overall-quality model on our released test set.
python src/evaluate/cal_plcc_srcc.py \
	--level_names excellent good fair poor bad \
	--pred_paths $res_dir/test_Overall_score.json \
	--gt_paths   ./data_preprocess/test/test_Overall_score.json \
	--output_csv $res_dir/overall_score.csv

# Optional generalization study on standard IQA datasets (must be inferred first),
# with gt_dir=../Data-DeQA-Score, e.g.:
#	--pred_paths $res_dir/test_pipal_5k.json $res_dir/test_livew_1k.json ... \
#	--gt_paths   $gt_dir/PIPAL/metas/test_pipal_5k.json $gt_dir/LIVE-WILD/metas/test_livew_1k.json ...
