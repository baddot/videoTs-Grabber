#!/bin/bash
LINK=$1
NAME=$2

START=0
END=2000

help()
{
    echo "download-video.sh <url> <output-name>"
    echo "<url>: x.mp4 (without .ts)"
    echo "<output-name>: x (without .mp4)"
} 

create_folders()
{
    # create folder for streaming media
    cd ~/Videos
    mkdir download-videos
    cd download-videos
}

print_variables()
{
    echo "Execute Download with following parameters"
    echo "Link $LINK"
    echo "Name $NAME"
}

check_video()
{
    i=$START
    while [[ $i -le $END ]]
    do
        URL=$LINK'-'$i.ts
        STATUS_CODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' $URL)
        if [ "$STATUS_CODE" == "200" ]; then
            break
        fi
        ((i = i + 1))
    done

    if [ "$STATUS_CODE" == "200" ]; then
        START=$i
        echo "START is $START"
    else 
        echo "File not found"
    fi
} 


download_video()
{
    i=$START
    e=$END
    while [[ $i -le $END ]]
    do
        URL=$LINK'-'$i.ts
        STATUS_CODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' $URL)
        if [ "$STATUS_CODE" != "200" ]; then
            break
        fi
        wget $URL
        e=$i
        ((i = i + 1))
    done

    END=$e
}

concat_videos()
{
    DIR="${LINK##*/}"

    i=$START
    echo "i is $i"
    while [[ $i -le $END ]]
    do
        FILE=$DIR'-'$i.ts
        echo $FILE | tr " " "\n" >> tslist
        ((i = i + 1))
    done
    while read line; 
    do 
        echo "gugu"$line
        cat $line >> $NAME.mp4; 
    done < tslist

    rm *.ts tslist
}

if [ "$1" == "" ]; then
    echo "No video url provided"
    help
else
    LINK=$1
    if [ "$2" == "" ]; then
        echo "No video output-name provided"
        help
    else
        NAME=$2
        create_folders
        print_variables
        check_video
        download_video
        concat_videos
    fi
fi
