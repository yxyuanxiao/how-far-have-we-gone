#!/bin/bash
export PYTHONPATH=./:$PYTHONPATH

LOAD="../ModelZoo/mplug-owl2-llama2-7b"

# The overall-quality model is trained on our released data together with the
# standard IQA datasets KonIQ / SPAQ / KADID (in DeQA-Score meta format). Download
# those from https://huggingface.co/datasets/zhiyuanyou/Data-DeQA-Score and place
# them under the same data root (../data), so all image paths resolve via
# --image_folder. Drop the three extra lines to train on our data only.

deepspeed --include localhost:$1 --master_port 6688 src/train/train_mem.py \
    --deepspeed scripts/zero3.json \
    --lora_enable True \
    --model_name_or_path $LOAD \
    --version v1 \
    --dataset_type pair \
    --level_prefix "The quality of the image is" \
    --level_names excellent good fair poor bad \
    --softkl_loss True \
    --weight_rank 1.0 \
    --weight_softkl 1.0 \
    --weight_next_token 0.05 \
    --continuous_rating_loss True \
    --closeset_rating_loss True \
    --use_fix_std True \
    --detach_pred_std True \
    --data_paths ./data_preprocess/train/train_Overall_score.json \
                 ../data/KONIQ/metas/train_koniq_7k.json \
                 ../data/SPAQ/metas/train_spaq_9k.json \
                 ../data/KADID10K/metas/train_kadid_8k.json \
    --data_weights 1 1 1 1 \
    --image_folder ../data \
    --output_dir ./checkpoints/deqa_lora_overall_score \
    --image_aspect_ratio pad \
    --group_by_modality_length True \
    --bf16 True \
    --num_train_epochs 3 \
    --per_device_train_batch_size 16 \
    --per_device_eval_batch_size 4 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no" \
    --save_strategy "no" \
    --learning_rate 2e-5 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --tune_visual_abstractor True \
    --freeze_vision_model False \
    --dataloader_num_workers 4 \
    --lazy_preprocess True \
    --report_to tensorboard
