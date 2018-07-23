#!/bin/bash

debug_str="import pydevd;pydevd.settrace('localhost', port=8081, stdoutToServer=True, stderrToServer=True)"
export PYTHONPATH=/home/Peterou/Desktop/usr/soft/pycharm-2017.3.5/debug-eggs/pycharm-debug-py3k/


insert_debug_string()
{
file=$1
line=$2
debug_string=$3
debug=$4

value=`sed -n ${line}p $file`
if [ "$value" != "$debug_str" ] && [ "$debug" = debug ]
then
echo "++Insert $debug_string in line_${line}++"
sed -i "${line}i $debug_str" $file
fi
}

delete_debug_string()
{
file=$1
line=$2
debug_string=$3

value=`sed -n ${line}p $file`
if [ "$value" = "$debug_str" ]
then
echo "--Delete $debug_string in line_${line}--"
sed -i "${line}d" $file
fi
}


export PYTHONPATH=/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local:/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local/lib/python2.7/site-packages:/home/Peterou/Desktop/usr/code/caffe2/detectron:$PYTHONPATH
export LD_LIBRARY_PATH=/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local/lib:/usr/local/cudnn_v6/lib64:/usr/local/cuda-8.0/lib64
export CUDA_VISIBLE_DEVICES=1

source ~/anaconda3/bin/activate caffe2


if [ $1 = test ]
then
    python detectron/tests/test_spatial_narrow_as_op.py
elif [ $1 = inference ]
then
    # ./run.sh inference debug
    # weights: https://s3-us-west-2.amazonaws.com/detectron/35861858/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml.02_32_51.SgT4y1cO/output/train/coco_2014_train:coco_2014_valminusminival/generalized_rcnn/model_final.pkl
    debug=$2
    file="tools/infer_simple.py"
    line=26
    insert_debug_string $file $line "$debug_str" $debug

    python "$file" \
    --cfg configs/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml \
    --output-dir results/detectron-visualizations \
    --image-ext jpg \
    --wts models/model_final.pkl \
    demo

    delete_debug_string $file $line "$debug_str"

elif [ $1 = e2e_mask_rcnn_R-101-FPN_2x ]
then
    # ./run.sh e2e_mask_rcnn_R-101-FPN_2x debug 1
    # weights: https://s3-us-west-2.amazonaws.com/detectron/35861858/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml.02_32_51.SgT4y1cO/output/train/coco_2014_train:coco_2014_valminusminival/generalized_rcnn/model_final.pkl
    debug=$2
    gpus=$3
    file="tools/test_net.py"
    line=24
    insert_debug_string $file $line "$debug_str" "$debug"

    if [ $gpus > 1 ]
    then

        python "$file" \
        --cfg configs/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml \
        --multi-gpu-testing \
        TEST.WEIGHTS  ./models/model_final.pkl.1 \
        TRAIN.WEIGHTS ./models/model_final.pkl.1 \
        NUM_GPUS $"$gpus"
    else
        python "$file" \
            --cfg configs/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml \
            TEST.WEIGHTS  ./models/model_final.pkl.1 \
            TRAIN.WEIGHTS ./models/model_final.pkl.1 \
            NUM_GPUS 1

    fi

    delete_debug_string $file $line "$debug_str"

else
    echo Pass
fi






