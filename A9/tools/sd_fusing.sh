#
# Copyright (C) 2013 100ask
#              http://www.100ask.net/
####################################

if [ -z $1 ]  #�жϲ���1���ַ����Ƿ�Ϊ�գ����Ϊ�գ����ӡ��������Ϣ
then
    echo "usage: sd_fusing.sh <SD Reader's device file> <Source file>"
    exit 0
fi

if [ -z $2 ]  #�жϲ���2���ַ����Ƿ�Ϊ�գ����Ϊ�գ����ӡ��������Ϣ
then
    echo "usage: sd_fusing.sh <SD Reader's device file> <Source file>"
    exit 0
fi

if [ -b $1 ]  #�жϲ���1��ָ����豸�ڵ��Ƿ����
then
    echo "$1 reader is identified."
else
    echo "$1 is NOT identified."
    exit -1
fi

####################################
#<verify device>

BDEV_NAME=`basename $1`
BDEV_SIZE=`cat /sys/block/${BDEV_NAME}/size`

#�����������С��0�����ӡʧ����Ϣ�����˳�
if [ ${BDEV_SIZE} -le 0 ]; then 
 echo "Error: NO media found in card reader."
 exit 1
fi

#���������������32000000�����ӡʧ����Ϣ�����˳�
if [ ${BDEV_SIZE} -gt 32000000 ]; then                               
 echo "Error: Block device size (${BDEV_SIZE}) is too large"
 exit 1
fi

####################################
# check files

SOURCE_FILE=$2
MKBL2=my_mkbl2

#���source file�Ƿ����
if [ ! -f ${SOURCE_FILE} ]; then                                     
 echo "Error: $2 NOT found, please build it & try again."
 exit -1
fi


#<make bl2>
#ʹ��my_mkbl2���������������bin���Ӷ�����bl2.bin
${MKBL2} ${SOURCE_FILE} bl2.bin 14336                                

####################################
# fusing images

signed_bl1_position=1  #bl1�ľ�����д��sd���ĵ�1������
bl2_position=17        #bl2�ľ�����д��sd���ĵ�17������

#<BL1 fusing>
echo "---------------------------------------"
echo "BL1 fusing"
# ��дbl1��SD��512�ֽڴ�
dd iflag=dsync oflag=dsync if=/work/4412/tools/E4412_N.bl1.bin of=$1 seek=$signed_bl1_position

# ���ʧ�����˳�
if [ $? -ne 0 ]
then
   echo Write BL1 Error!
   exit -1
fi

#<BL2 fusing>
echo "---------------------------------------"
echo "BL2 fusing"
# ��дbl2��SD��(512+8K)�ֽڴ�, 512+8K=17x512,����17��block
dd iflag=dsync oflag=dsync if=./bl2.bin of=$1 seek=$bl2_position

# ���ʧ�����˳�
if [ $? -ne 0 ]
then
   echo Write BL2 Error!
   exit -1
fi


#<flush to disk>
# ͬ���ļ�
sync

rm bl2.bin

####################################
#<Message Display>
echo "---------------------------------------"
echo "source file image is fused successfully."
echo "Eject SD card and insert it to Exynos 4412 board again."
