#!/bin/bash

#CORE function list
#CORE end
#define function begin
#define function begin
CHECK_CORE_FILE() {
    CORE_FILE="$(dirname $0)/core"
    if [[ -f "${CORE_FILE}" ]]; then
        . "${CORE_FILE}"
    else
        echo "!!! core file does not exist !!!"
        exit 1
    fi
}

#define function end

#main script begin
CHECK_CORE_FILE "$@"
CHECK_PARAMETER "$@"#

[[ $1 =~ ".mp4" ]] && [[ ${2: -8:8} == "bypass/J" ]] && exit 0
[ ! -z $2 ] && CREATE_TMP_DIR "post" || CREATE_TMP_DIR "move"

DEF_RCLONE_ENV_STRING
#DEF_LOG_FILE_NAME
#DL_TGBOT

GET_FILE_LIST $1 $2

echo -e "${INFO}  ==== 開 始 RCLONE MOVE ==== $TODAY ==== " #2>&1 | tee -a ${LOG_NAME}

echo ${files_len}

for (( f=0 ; f < ${files_len}  ; f++ )) ; do
	#
	[ ! -z $1 ] && pass_src_dir_name=$1 || pass_src_dir_name=${files[$f]}
	[ ! -z $2 ] && pass_src_dir_path=$2 || pass_src_dir_path="JAV2:/bypass/JAV_output/${files[$f]}"
	QUE_STUDIO ${files[$f]}
	QUE_STUDIO_RETURN_CODE=$?
        if [ $QUE_STUDIO_RETURN_CODE -eq 99 ]; then
                echo "$1 not match"
                echo $QUE_STUDIO_RESULT
        else
                echo "$1 match $QUE_STUDIO_RESULT"
                echo "$1 match $QUE_STUDIO_RESULT_WITH_NAME.mp4"
                echo "$1 match $QUE_STUDIO_RESULT_WITH_NAME.nfo"
        fi
	#
done
