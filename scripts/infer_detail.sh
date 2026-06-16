#!/bin/bash
export CUDA_VISIBLE_DEVICES=$1
export PYTHONPATH=./:$PYTHONPATH

python src/evaluate/iqa_eval.py \
	--level-names excellent good fair poor bad \
	--model-path ./checkpoints/deqa_lora_detail \
	--model-base ../ModelZoo/mplug-owl2-llama2-7b/ \
	--prompt "How complete are the fine details in this image?" \
	--save-dir results/res_deqa_lora_detail/ \
	--preprocessor-path ./preprocessor/ \
	--root-dir ../data/ \
	--meta-paths ./data_preprocess/test/test_Detail_Completeness.json
