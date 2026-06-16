#!/bin/bash
export CUDA_VISIBLE_DEVICES=$1
export PYTHONPATH=./:$PYTHONPATH

python src/evaluate/iqa_eval.py \
	--level-names excellent good fair poor bad \
	--model-path ./checkpoints/deqa_lora_content \
	--model-base ../ModelZoo/mplug-owl2-llama2-7b/ \
	--prompt "How concise and uncluttered does this image appear?" \
	--save-dir results/res_deqa_lora_content/ \
	--preprocessor-path ./preprocessor/ \
	--root-dir ../data/ \
	--meta-paths ./data_preprocess/test/test_Content_Conciseness.json
