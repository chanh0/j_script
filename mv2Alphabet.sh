#!/bin/bash
#version 1.0
# mv2Alphabet.sh


#Alphabet folder name
alphabet_folder="/mnt/g/JAV2/Alphabet"

#cd /mnt/g/JAV2/S/JAV_output
files=(*/) 
echo "scanned filename :" ${files[@]//\//}
files_len=${#files[@]} 
echo "No of files :" ${files_len}


for (( f=0 ; f < ${files_len}  ; f++ )) ; do
    echo "----" $((f+1)) "of ${files_len} - Alphabet test ${files[$f]//\//}	----------------------------"
	var=${files[$f]:0:1}
	subfolder=${files[$f]:0:4}
	#echo ${var}
	#echo ${subfolder}
	case "$var" in [A-C]) mv ${files[$f]//\//} $alphabet_folder"/A-C/$subfolder/${files[$f]}" ;; esac
	case "$var" in [D-F]) mv ${files[$f]//\//} $alphabet_folder"/D-F/$subfolder/${files[$f]}" ;; esac
	case "$var" in [G-J]) mv ${files[$f]//\//} $alphabet_folder"/G-J/$subfolder/${files[$f]}" ;; esac		
	case "$var" in [K-M]) mv ${files[$f]//\//} $alphabet_folder"/K-M/$subfolder/${files[$f]}" ;; esac		
	case "$var" in [N-R]) mv ${files[$f]//\//} $alphabet_folder"/N-R/$subfolder/${files[$f]}" ;; esac		
	case "$var" in [S]) mv ${files[$f]//\//} $alphabet_folder"/S/$subfolder/${files[$f]}" ;; esac	
	case "$var" in [T-Z]) mv ${files[$f]//\//} $alphabet_folder"/T-Z/$subfolder/${files[$f]}" ;; esac	
	
done
