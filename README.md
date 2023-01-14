# This is a replica from [Janspiry's Image-Super-Resolution-via-Iterative-Refinement](https://github.com/Janspiry/Image-Super-Resolution-via-Iterative-Refinement) repo, please go there instead, this repo is uniquely for a private project purposes

## Brief introduction
This repository is an implementation of the SR3 (Super-Resolution via Iterative Refinement) a diffusion model described in C. Saharia's, et. al. paper [Image Super-Resolution via Iterative Refinement](https://arxiv.org/pdf/2104.07636v2.pdf), and, as stated above, a modifed repository inspired from [Janspiry's Image-Super-Resolution-via-Iterative-Refinement](https://github.com/Janspiry/Image-Super-Resolution-via-Iterative-Refinement) one.

To run SR3 in Google Collab you can use [this notebook](https://colab.research.google.com/drive/1sKw0ouiejYAS6_JMw4igJe6y4jKJF0hO?usp=sharing)


## Prerequisites

First of all you must clone this repository in a gpu-compatible device:
```python
git clone https://github.com/Scoles12/CPIA_Sionis_Scoles.git
```
Then, go to the cloned directory and install the needed packages:
```python
cd CPIA_Sionis_Scoles
pip install -r requirement.txt
```


## Tracking with wandb

Using wandb ([Weights and Biases](https://wandb.ai/site)) one can track the model in real-time while it is training and compare different runs.

We have already installed it with the requirement.txt file, so, in order to use it you only need to run the login line. 

```
pip install wandb

# get your API key from wandb.ai/authorize
wandb login
```

When running the commands that we will explain next, if you wish to track with wandn, a part form logging in you must also uncomment these commented parts:
```python
#-enable_wandb -log_wandb_ckpt
```


## Usage

### Data Prepare

If you want to use your own set of images to train or validate the model you need to prepare them. This is done automatically with this command:

```python
# Size should be 16,128 or 64,512
python data/prepare_data.py  --path [dataset root]  --out [output root] --size 16,128
```
This will create, inside the output root, three subfolders:
- hr_128: high-resolution 128x128 images
- lr_16: low-resolution 16x16 images
- sr_16_128: 128x128 low-resolution images ready for super resolution

You can also use our own set which is already prepared inside the dataset folder.

If you have used your own set of images yo must now change the dataset config in the file /config/sr_sr3_16_128.json (or __64_512_) to your data path: 

```json
"datasets": {
    "train|val": { // train and validation part
        "dataroot": "dataset/input_16_128", // [output root] in prepare data command
        "l_resolution": 16, // low resolution need to super_resolution
        "r_resolution": 128, // high resolution
        "datatype": "img", //lmdb or img, path of img files
    }
},
```


### Training/Resume Training

To start the training you need to run the following command:

```python
# If you want to train from 64x64 to 512x512 change the training file name to config/sr_sr3_64_512.json
python sr.py -p train -c config/sr_sr3_16_128.json #-enable_wandb -log_wandb_ckpt
```

Alternatively, if you are using a Slurm managed cluster you can make use of the sumbit_sr.sh file by submiting the job with this structure:
```python
# [small_size] must be either 16 (for 16x16 to 128x128) or 64 (for 64x64 to 512x512)
submit_sr.sh [small_size] train
```

To use wandb with this method of submiting the job, you must uncomment, in the sumbit_sr.sh file, both the login line and the "-enable_wandb ...". You also must substitute <API KEY> with your [API key](https://wandb.ai/authorize).
    
To start the training from scratch make sure the "resume_state" property in the path config of /config/sr_sr3_16_128.json (or __64_512_) file is set to null. If you want to carry on from a previous checkpoint you must change this property to the path were the checkpoint is stored:
    
```json
"path": { //set the path
        "log": "logs",
        "tb_logger": "tb_logger",
        "results": "results",
        "checkpoint": "checkpoint",
        "resume_state": null
        // "resume_state": "experiments/OUT_16_128_210806_204158/checkpoint/I640000_E37" //pretrain model or training state
    },
},
```
    
    
### Test/Evaluation

Once the method is trained, we can validate another set of images (remember to do the data prepare step for this as well). To do so, we need to change the "resume_state" property to the last checkpoint (as explained above) which is the trained model. Now, we only need to change train to val in the training command:
    
```python
# If you want to train from 64x64 to 512x512 change the training file name to config/sr_sr3_64_512.json
python sr.py -p val -c config/sr_sr3_16_128.json #-enable_wandb -log_wandb_ckpt

# Quantitative evaluation alone using SSIM/PSNR metrics on given result root
python eval.py -p [result root]
```

Again, if you are using a Slurm based cluster you should run:
```python
# [small_size] must be either 16 (for 16x16 to 128x128) or 64 (for 64x64 to 512x512)
submit_sr.sh [small_size] val
```
    
