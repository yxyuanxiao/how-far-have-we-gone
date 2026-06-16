#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH


python src/evaluate/cal_plcc_srcc.py \
	--level_names excellent good fair poor bad \
	--pred_paths ./results/res_deqa_lora_visual/test_Visual_Clarity.json \
	--gt_paths  ./data_preprocess/test/test_Visual_Clarity.json \
	--output_csv ./results/res_deqa_lora_visual/visual_score.csv
