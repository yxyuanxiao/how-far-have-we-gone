#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH


python src/evaluate/cal_plcc_srcc.py \
	--level_names excellent good fair poor bad \
	--pred_paths ./results/res_deqa_lora_sharpness/test_Sharpness_Naturalness.json \
	--gt_paths  ./data_preprocess/test/test_Sharpness_Naturalness.json \
	--output_csv ./results/res_deqa_lora_sharpness/sharpness_score.csv
