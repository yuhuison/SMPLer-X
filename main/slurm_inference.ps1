# PowerShell version

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$PARTITION="Zoetrope"

$INPUT_VIDEO=$args[0]
$FORMAT=$args[1]
$FPS=$args[2]
$CKPT=$args[3]

$GPUS=1
$JOB_NAME="inference_$INPUT_VIDEO"

$GPUS_PER_NODE= if ($GPUS -lt 8) {$GPUS} else {8}
$CPUS_PER_TASK=4 # ${CPUS_PER_TASK:-2}
$SRUN_ARGS=$null # ${SRUN_ARGS:-""}

$IMG_PATH="../demo/images/$INPUT_VIDEO"
$SAVE_DIR="../demo/results/$INPUT_VIDEO"

# video to images
Write-Output "Start Creating Folder"
New-Item -ItemType Directory -Force -Path $IMG_PATH
New-Item -ItemType Directory -Force -Path $SAVE_DIR
Write-Output "Start Video To Frames"
ffmpeg -i "../demo/videos/$INPUT_VIDEO.$FORMAT" -f image2 -vf "fps=$FPS/1" -qscale 0 "../demo/images/$INPUT_VIDEO/%06d.jpg" 
Write-Output "End Video To Frames"
$end_count= (Get-ChildItem $IMG_PATH -File | Measure-Object).Count
Write-Output $end_count
Write-Output "Start Inference"
# inference
$env:PYTHONPATH="$(Get-Location)/..;$env:PYTHONPATH"
# srun command is not available in Windows. You might need to find an alternative.
# srun -p $PARTITION --job-name=$JOB_NAME --gres=gpu:$GPUS_PER_NODE --ntasks=$GPUS --ntasks-per-node=$GPUS_PER_NODE --cpus-per-task=$CPUS_PER_TASK --kill-on-bad-exit=1 $SRUN_ARGS python inference.py --num_gpus $GPUS_PER_NODE --exp_name output/demo_$JOB_NAME --pretrained_model $CKPT --agora_benchmark agora_model --img_path $IMG_PATH --start 1 --end $end_count --output_folder $SAVE_DIR --show_verts --show_bbox --save_mesh
Write-Output "End Inference"
# images to video
ffmpeg -y -f image2 -r $FPS -i "$SAVE_DIR/img/%06d.jpg" -vcodec mjpeg -qscale 0 -pix_fmt yuv420p "../demo/results/$INPUT_VIDEO.mp4"