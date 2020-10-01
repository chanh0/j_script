#!/usr/bin/env bash
#
# Version: 1.0.0
#


studio_json="./studioarray-3.json"
movedone=0
folder_idx=0
code_idx=0
#studio folder name
studio_folder="/mnt/g/JAV1/Studio"

studioarray=($(jq -r '.[].name' ${studio_json} ))
countarray=($(jq -r '.[].count' ${studio_json} ))
codearray=($(jq -r '.[].code' ${studio_json} ))
len_studio_array=${#studioarray[@]}

echo ${studioarray[@]}
#echo ${countarray[@]}
#echo ${codearray[@]}
echo "Studio array count :" ${len_studio_array}
#echo -e  "hello world"

#loop ls the file and put into filearray 
files=(*/) 
#echo "scanned filename :" ${files[@]}
files_len=${#files[@]} 
echo "No of files :" ${files_len}
#echo "folder array idx : " ${folder_idx}


#[@] means: Output the elements as INDIVIDUAL items.
#[*] means: Output the elements as ONE item.

#this for loop is loop every filename scanned to array 
for (( f=0 ; f < ${files_len}  ; f++ )) ; do
    echo "----" $((f+1)) "of ${files_len} - 工作室檢查 ${files[$f]//\//}	----------------------------"
    #echo "folder array idx : " ${folder_idx}
    #jq 'length' <  ${studio_json}
    #echo "len_studio_array : " ${len_studio_array}
	folder_idx=0
    	movedone=0
	while [ ${movedone} == 0 ]
	do
	#and ${folder_idx} => ${len_studio_array ]  do
        foldername=${studioarray[${folder_idx}]}
	len_code_array=${countarray[$folder_idx]}
	
	#debug line
	#$echo -n -e "\\r	...checking -" ${foldername} "		-" $len_code_array "loop..."
	
	# this is re-load code and count under studio idx 
	codearray=$( jq -r '.['$folder_idx'].code' ${studio_json} )
	
	#debug line
	#echo ${foldername} "code array : " $codearray
	
	codedone=0
	code_idx=1
	while [ ${movedone} == 0 ] && [ ${codedone} == 0 ]
		#for codename in "$codearray[@]" ;
		do		
		codearray=($(jq -r '.['$folder_idx'].code' ${studio_json} ))
		codename=${codearray[${code_idx}]//\"/}  
		codename=$(sed 's/,$//' <<<"${codename}")
		
		#debg line
		#echo ${codename}
		#echo ${files[$f]//\//} " == " $codename " / loop " $code_idx " of " $len_code_array 
		if [[ ${files[$f]//\//} == ${codename}* ]];  
		then
                    	echo -e "\\r"${files[$f]//\//} moving to $studio_folder/${foldername}/${codename}/${files[$f]}
						echo 
                    	rclone move --progress --drive-server-side-across-configs -v --log-file=$HOME/jav1-move.log JAV2:S/JAV_output/${files[$f]} JAV1:/Studio/${foldername}/${codename}/${files[$f]}
						#itemmove ${files[$f]} moved to ${foldername}\${codename} 
                    	movedone=1
            	fi
		((code_idx++)) 
	        if (( $((code_idx-1)) >= $len_code_array ));
	        	then
	                #echo "done"
			codedone=1
			code_idx=0
	        	fi
		done	
		((folder_idx++)) 
        if (( $folder_idx == $((len_studio_array-1)) ));
        then
                movedone=1
        fi
        
    done 
done




