#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH


python src/evaluate/cal_plcc_srcc.py \
	--level_names excellent good fair poor bad \
	--pred_paths ./results/res_deqa_lora_detail/test_Detail_Completeness.json \
	--gt_paths  ./data_preprocess/test/test_Detail_Completeness.json \
	--output_csv ./results/res_deqa_lora_detail/detail_score.csv
