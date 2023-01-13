#!/bin/bash


#SBATCH --job-name=submit_sr.sh
#SBATCH --output=output.sh.o%j
#SBATCH --error=output.sh.e%j


USAGE="\n USAGE: ./submit_sr.sh small_size mode \n
        small_size      -> 16: 16-128; 64: 64-512\n
        mode  -> train or val\n"

if (test $# -lt 2 || test $# -gt 2)
then
        echo -e $USAGE
        exit 0
fi

if (test $1 = 16)
then
    SIZE="16_128"
else
    if (test $1 = 64)
    then
        SIZE="64_512"
    else
        echo "Use 16 or 64 to specify size"
        exit 0
    fi
fi

python sr.py -p $2 -c config/sr_sr3_${SIZE}.json #-enable_wandb -log_wandb_ckpt
