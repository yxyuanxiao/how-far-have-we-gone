#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH


python src/evaluate/cal_plcc_srcc.py \
	--level_names excellent good fair poor bad \
	--pred_paths ./results/res_deqa_lora_semantics/test_Semantics.json \
	--gt_paths  ./data_preprocess/test/test_Semantics.json \
	--output_csv ./results/res_deqa_lora_semantics/semantics_score.csv
