#!/bin/bash
#
# Vesion: 1.0.0
#


amateur_json="./amateur-2.json"
movedone=0
folder_idx=0
code_idx=0
#素人 folder name
amateur_folder="/mnt/g/JAV2/Alphabet/素人"

prefixarray=($(jq -r '.[].prefix' ${amateur_json} ))
codearray=($(jq -r '.[].name' ${amateur_json} ))
len_prefix_array=${#prefixarray[@]}


#echo ${prefixrarray[@]}
#echo ${countarray[@]}
#echo ${codearray[@]}
echo "素人檢查 prefix count :" ${len_prefix_array}
#echo -e  "hello wold"


#this pat ls the file and put into filearray 
#cd /mnt/g/JAV2/S/JAV_output
files=(*/) 
echo "scanned filename :" ${files[@]//\//}
files_len=${#files[@]} 
echo "No of files :" ${files_len}

#echo "folder array idx : " ${folder_idx}
#echo "length of prefix array " ${len_prefix_array}

#[@] means: Output the elements as INDIVIDUAL items.
#[*] means: Output the elements as ONE item.

#this fo loop is loop every filename scanned to array 
for ((f=0 ; f < ${files_len}  ; f++)); do
    echo "----------------" $((f+1)) "of ${files_len} - 素人檢查 ${files[$f]//\//}-----------------"
    #echo "folder array idx : " ${folder_idx}
    #jq 'length' <  ${amateur_json}
    #echo "len_prefix_array : " ${len_prefix_array}
	folder_idx=0
    movedone=0
    while [ ${movedone} == 0 ]
        do
               foldername=${prefixarray[${folder_idx}]}
			   codename=${codearray[${folder_idx}]}  #folder and code share same #idx
               #echo "real file name = "${files[${f}]//\//}
			   #echo "foldername =" ${foldername} " / " "codename ="${codename}
                        #len_code_aray=${#codearray[@]}
                        #while [ ${movedone}=0 and ${code_idx} < ${len_code_aray} ];  do
               
                
                        #    code_idx++
               #echo "comparing #"${folder_idx}
			   if [[ ${files[$f]//\//} == ${foldername}* ]];  
               then
                       echo moving ${files[${f}]//\//} to $amateur_folder/${codename}/${files[${f}]} 
                        mv ${files[${f}]//\//} $amateur_folder/${codename}/${files[${f}]}
                        #clone move  ${files[$f]} JAV2:/Alphabet/素人/${codename}             
                       movedone=1
               fi
               ((folder_idx++)) 
                #echo "length of prefix array =" ${len_prefix_array}
               
                if (( $folder_idx >= $len_prefix_array ));
                then
                        movedone=1
                fi
        done
done
