#!/bin/bash

#      -+- ClusterScript -+-
#  -+- Rev. 5.1_LINPRERELEASE -+-

# these need to be at the top for Reasons
aafcworks=1 # manual flag so i only have to change 1 character to disable AAFC when it breaks
ShotgunDebug=0 # provide "extra debugging" *BITE*
debl='\033[0;34m' # DEbug BLue
der='\033[0;31m' # DEbug Red
recl='\033[0m' # REmove CoLor
DM(){ # Debug Message
    if [[ $debugmessages == 0 ]]; then return 0; fi # immediately quit if debug messages are turned off
    # this is now a bit neater due to me learning how to use case statements
    case $1 in # look at the first argument for flags
        -e) # error
            echo -e "${der}[$(getUnixTimestamp)] ERROR: $2${recl}"
        ;;
        -d) # debug
            echo -e "${debl}[$(getUnixTimestamp)] DEBUG: $2${recl}"
        ;;
        -epa) # error (potentially annoying)
            if [[ $annoyMe == 1 ]]; then
                echo -e "${der}[$(getUnixTimestamp)] ERROR: $2${recl}"
            else
                return 0
            fi
        ;;
        -dpa) # debug (potentially annoying)
            if [[ $annoyMe == 1 ]]; then
                echo -e "${debl}[$(getUnixTimestamp)] DEBUG: $2${recl}"
            else
                return 0
            fi
        ;;
    esac
}

clrpl(){ # CLeaR Previous Line
    tput cuu1
    tput el
}

AtTheEnd() { # we finished the function!
    if [[ $directInFile == "1" ]]; then
        DM -dpa "Removing temporary infile..."
        rm "./${infileBaseName}"
    fi
    read -p "Do you want to convert another file? (Y/N) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        MainAsk
    else
        exit 1
    fi
}

LowQualitize() {
    # the first ClusterScript function ever.
    if [[ -e cluster_result ]]; then
        DM -dpa "directory cluster_result already exists."
    else
        mkdir "cluster_result"
    fi
    sleep 0.5
    # the initial 5
    if [[ $ShotgunDebug == 0 ]]; then
    DM -dpa "Trying OPUS..."
        if [[ $nopus == 1 ]]; then
            echo "NoOPUS has been enabled, skipping OPUS..."
        else
            DM -dpa "NoOPUS is disabled... "
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 1k "cluster_result/$1_1kbopus_$RANDOM.ogg"
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 1k "cluster_result/$1_1kbopus_$RANDOM.opus"
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 8k "cluster_result/$1_8kbopus_$RANDOM.ogg"
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 8k "cluster_result/$1_8kbopus_$RANDOM.opus"
        fi
        DM -dpa "Trying MP3..."
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -b:a 8k -ar 8000 "cluster_result/$1_8kbmp3_$RANDOM.mp3"
        DM -dpa "Trying SPEEX..."
        if [[ $nospeex == 1 ]]; then
            echo "NoSPEEX has been enabled, skipping SPEEX..."
        else
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 1k -acodec libspeex "cluster_result/$1_1kbspeex_$RANDOM.ogg"
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 8k -acodec libspeex "cluster_result/$1_8kbspeex_$RANDOM.ogg"
        fi
    else
        DM -d "Extra Debugging was requested... "
    fi

    # 3 bit depth 4096hz and dpcm8192
    DM -dpa "Trying AAFC..."
    if [[ $noaafc == 1 ]]; then
        echo "NoAAFC has been enabled, skipping AAFC functions... "
    elif [[ $aafcworks == 1 ]]; then # this saves me manually commenting out every line of this when AAFC breaks and i want to use this darn thing
        DM -d "entering into AAFC territory..."
        cd "cluster_AAFC"
        DM -d "Changed directory to cluster_AAFC."
        ffmpeg -hide_banner -loglevel error -y -i "../$1.$2" "../$1_tmp.wav"
        DM -d "Trying to convert to 3 bit depth 4096Hz..."
        ./aud2aafc -i "../$1_tmp.wav" --bps 3 -ar 4096 # aafc pass 1
        DM -d "converting to WAV..."
        ./aafc2wav "aafc_conversions/$1_tmp.aafc" "../cluster_result/$1_3bitdepth4096hz_$RANDOM"
        DM -d "Trying to convert to DPCM8192..."
        ./aud2aafc -i "../$1_tmp.wav" -n -m --dpcm -ar 8192 # aafc pass 2, OVERWRITE DISTHINGKFXLKZJ
        DM -d "converting to WAV..."
        ./aafc2wav "aafc_conversions/$1_tmp.aafc" "../cluster_result/$1_dpcm8192hz_$RANDOM"
        DM -d "Removing tempfiles..."
        rm "aafc_conversions/$1_tmp.aafc" "../$1_tmp.wav"
        cd ..
    elif [[ $aafcworks == 0 ]]; then
        echo "AAFC support is currently broken, skipping..."
    fi

    if [[ $ShotgunDebug == 0 ]]; then
        # CODify
        DM -dpa "Trying CODify..."
        if [[ $nopus == 1 ]] || [[ $nospeex == 1 ]]; then
            echo "NoSPEEX and/or NoOPUS has been enabled, skipping CODify..."
        else
            ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 1k -acodec libspeex "TEMPSPEEX_$1.$2.ogg" # encode to speex for Effect(tm)
            ffmpeg -hide_banner -loglevel error -y -i "TEMPSPEEX_$1.$2.ogg" -c:a libopus -b:a 1k "TEMPOPUS_$1.$2.ogg" # encode that speex with OPUS
            rm "TEMPSPEEX_$1.$2.ogg"
            ffmpeg -hide_banner -loglevel error -y -i "TEMPOPUS_$1.$2.ogg" -filter:a "volume = 35dB" "TEMPLOUD_$1.$2.wav" # make it loud for that COD Quality(tm)
            rm "TEMPOPUS_$1.$2.ogg"
            ffmpeg -hide_banner -loglevel error -y -i "TEMPLOUD_$1.$2.wav"  -c:a libopus -b:a 1k "cluster_result/$1_codlobby_$RANDOM.ogg" # encode it with opus again for that Extra Quality(tm)
            rm "TEMPLOUD_$1.$2.wav"
        fi

        # SSDPCM
        DM -dpa "Trying SSDPCM..."
        if [[ $nossdpcm == 1 ]]; then
            echo "NoSSDPCM has been enabled, skipping SSDPCM... "
        else
            ffmpeg -hide_banner -loglevel error -i "$1.$2" -ar 11025 "$1_temp11025hz.wav" # take the input and convert it to 11025Hz WAV temporarily
            ./cluster_SSDPCM/encoder ss1 "$1_temp11025hz.wav" "$1_tempssdpcm.aud" # convert the 11025Hz WAV to 1-bit SSDPCM
            ./cluster_SSDPCM/encoder decode "$1_tempssdpcm.aud" "cluster_result/$1_1bssdpcm11025_$RANDOM.wav" # convert the 1-bit SSDPCM back to WAV
            rm "$1_temp11025hz.wav" # remove the temporary 11025Hz WAV
            rm "$1_tempssdpcm.aud" # remove the temporary 1-bit SSDPCM
        fi

        # stereo difference (inverted right channel (FFmpeg), out-of-phase stereo (SoX))
        if ! command -v sox 2>&1 >/dev/null
        then
            DM -dpa "Trying Stereo Difference (FFmpeg)..."
            ffmpeg -hide_banner -loglevel error -i "$1.$2" -filter_complex \
            "[0:0]pan=1|c0=c0[left]; \
            [0:0]pan=1|c0=c1[right]" \
            -map "[left]" left.wav -map "[right]" right.wav
            ffmpeg -hide_banner -loglevel error -i right.wav -af "aeval='-val(0)':c=same" rightinv.wav
            ffmpeg -hide_banner -loglevel error -i left.wav -i rightinv.wav -filter_complex amix=inputs=2:duration=longest "cluster_result/$1_stdiff_$RANDOM.wav"
            rm left.wav
            rm right.wav
            rm rightinv.wav
        else
            DM -dpa "Trying Stereo Difference (SoX)..."
            ffmpeg -hide_banner -loglevel error -i "$1.$2" ".tempwav.wav" # "sox FAIL formats: no handler for file extension `mp3'"
            sox ".tempwav.wav" "cluster_result/$1_stdiff_$RANDOM.wav" gain -1 oops
            rm ".tempwav.wav"
        fi
    else
        DM -d "Extra Debugging was requested... "
    fi

    # DFPWM, AAC, squash&stretch
    DM -dpa "Trying DFPWM..."
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a dfpwm -ar 11025 ".tempwav.wav"
    ffmpeg -hide_banner -loglevel error -y -i ".tempwav.wav" -ar 44100 "cluster_result/$1_11025hzdfpwm_$RANDOM.wav"

    DM -dpa "Trying AAC..."
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a aac -b:a 16k -filter:a "volume=0.5" "cluster_result/$1_16kbaac_$RANDOM.aac" # low quality AAC tends to be loud, decrease volume by 2x to avoid clipping and bursting eardrums

    DM -dpa "Trying Stretch..."

    echo "2x: [                ] (0%)"
    sleep 0.3
    clrpl
    echo "2x: [========        ] (50%)"
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=2" ".tempstretch.wav" # 2x
    clrpl
    echo "2x: [================] (100%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" "cluster_result/$1_stretch_2x_$RANDOM.wav" # 1x
    clrpl
    echo "2x stretch done!"

    echo "4x: [                ] (0%)"
    sleep 0.3
    clrpl
    echo "4x: [======          ] (34%)"
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=4" ".tempstretch.wav" # 4x
    clrpl
    echo "4x: [==========      ] (67%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" ".tempstretch2.wav" # 2x
    clrpl
    echo "4x: [================] (100%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch2.wav" -af "atempo=0.5" "cluster_result/$1_stretch_4x_$RANDOM.wav" # 1x
    clrpl
    echo "4x stretch done!"

    echo "8x: [                ] (0%)"
    sleep 0.3
    clrpl
    echo "8x: [====            ] (25%)"
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=8" ".tempstretch.wav" # 8x
    clrpl
    echo "8x: [========        ] (50%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" ".tempstretch2.wav" # 4x
    clrpl
    echo "8x: [============    ] (75%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch2.wav" -af "atempo=0.5" ".tempstretch.wav" # 2x
    clrpl
    echo "8x: [================] (100%)"
    ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" "cluster_result/$1_stretch_8x_$RANDOM.wav" # 1x
    clrpl
    echo "8x stretch done!"

    rm ".tempwav.wav"
    rm ".tempstretch.wav"
    rm ".tempstretch2.wav"

    AtTheEnd
}

Visualize() {
    # the newest function in the current iteration. designed to be modular.

    echo "This may take a long time!"

    if [[ -e cluster_result ]]; then
        DM -dpa "directory cluster_result already exists."
    else
        mkdir "cluster_result"
    fi

    # Vectorscope
    DM -d "trying vectorscope..."
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -filter_complex "[0:a]avectorscope=draw=line:mode=lissajous_xy:rf=50:bf=50:gf=50:af=50:rc=255:bc=255:gc=255:r=60:s=1080x1080,format=yuv420p[v]" -map "[v]" -map 0:a -vcodec libx264 -movflags frag_keyframe+empty_moov "cluster_result/$1_vectscope_$RANDOM.mp4" # initially wasn't fragmenting. attempt #1 to fix: tacking on "-movflags frag_keyframe+empty_moov", also made resolution 1080x1080.

    # Modified Binary Waterfall
    DM -d "trying modified binary waterfall..."
    ffmpeg -hide_banner -loglevel error -i "$1.$2" -c:a pcm_u8 -ar 22050 ".temppcmu8.wav" # convert to unsigned 8-bit PCM to make it work
    if [[ ! -e ".temppcmu8.wav" ]]; then # skip binary waterfall if FFmpeg fucks up
        DM -e "temp WAV was not generated."
        echo "oh shit" # CBA to write actual error messages right now lmfao
        AtTheEnd
    fi

    ffmpeg -hide_banner -loglevel error -f u8 -ar 22050 -ac 2 -i ".temppcmu8.wav" -f rawvideo -pix_fmt rgb555 -c:a pcm_s16le -r 25 -s 42x42 -i ".temppcmu8.wav" -vf scale=w=16*iw:h=16*ih:sws_flags=neighbor -b:v 10000k "cluster_result/$1_binarywaterfall_$RANDOM.avi" -y # FFmpeg binary waterfall
    echo "don't worry about the errors lmao"
    echo "oh yea and sometimes the binary waterfall just stops like halfway through and i dont know how to fix it lmfao"
    # BUG: changing the "42x42" causes the video to freeze randomly unless scaler is set to bicubic for some reason (no known fix)

    rm ".temppcmu8.wav" # clean up tempfile

    AtTheEnd
}

MainAsk() {
    # ask for the file
    read -e -p "Type the name of the file: " file
    infile="${file%.*}" # credit to Architect for these lines
    extension="${file##*.}" # credit to Architect for these lines
    if [[ -e "$infile.$extension" ]]; then # check if the file actually exists
        MainAskExtended
    else
        echo "File does not exist. Please try again." # fun fact: we did not have this check until semi-recently
        MainAsk
    fi
}

MainAskExtended(){
    # functions menu
    echo "Select a function (or press F to disable certain features if you do not have them):"
    echo "LowQualitize (1), Visualize (2)"
    read -p "" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY == "1" ]]; then
        LowQualitize "$infile" "$extension"
    elif [[ $REPLY == "2" ]]; then
        Visualize "$infile" "$extension"
    elif [[ $REPLY =~ ^[Ff]$ ]]; then
        TheOnlyReasonINeedThisMenuIsBecauseICompiledMyFuckingFFmpegWrongAndLeftOutOverHalfOfIt
    fi
}

TheOnlyReasonINeedThisMenuIsBecauseICompiledMyFuckingFFmpegWrongAndLeftOutOverHalfOfIt(){ # self-explanatory function name, and only takes up half my screen space!
    echo "Welcome to the menu to disable features. Select a feature or press N to go back to the main menu. "
    echo "Disable SPEEX (1), Disable OPUS (2) "
    read -p "" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY == "1" ]]; then
        nospeex=1
    elif [[ $REPLY == "2" ]]; then
        nopus=1
    elif [[ $REPLY == "3" ]]; then
        noaafc=1
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        MainAskExtended
    fi
    TheOnlyReasonINeedThisMenuIsBecauseICompiledMyFuckingFFmpegWrongAndLeftOutOverHalfOfIt
}

checkSSDPCM(){
    if [[ -e ./cluster_SSDPCM ]]; then # if the folder exists, then:
    DM -d "SSDPCM folder check passed. "
        if [[ -e ./cluster_SSDPCM/encoder ]]; then # if the SSDPCM encoder file exists, then:
            DM -d "SSDPCM encoder check passed. "
            if [[ $directInFile == "1" ]]; then
                MainAskExtended
            else
                MainAsk
            fi
        else # SSDPCM encoder does not exist
            echo "SSDPCM encoder does not exist, disabling SSDPCM... "
            nossdpcm=1
        fi
    else # SSDPCM folder does not exist
        echo "SSDPCM folder does not exist! Create the folder \"cluster_SSDPCM\" and put the required SSDPCM files into it!"
        echo "Disabling SSDPCM..."
        nossdpcm=1
        if [[ $directInFile == "1" ]]; then
            MainAskExtended
        else
            MainAsk
        fi
    fi
}


checkAAFC(){
    if [[ -e ./cluster_AAFC ]]; then # if the folder exists, then:
    DM -d "AAFC folder check passed. "
        if [[ -e cluster_AAFC/aud2aafc ]] && [[ -e cluster_AAFC/aafc2wav ]] && [[ -e cluster_AAFC/libaafc.so ]]; then # if the required files exist, then:
            DM -d "AAFC check passed. "
            checkSSDPCM
        else # required AAFC files do not exist
            echo "AAFC resources (aud2aafc, aafc2wav, libaafc.so) do not exist, disabling AAFC... "
            noaafc=1
            checkSSDPCM
        fi
    else # AAFC folder does not exist
        echo "AAFC folder does not exist! Create the folder \"cluster_AAFC\" and put \"aud2aafc\", \"aafc2wav\", and \"libaafc.so\" into it!"
        checkSSDPCM
    fi
}

cleanupASingleFuckingTempFileThenExitWhyGodDoINeedAFuctionDedicatedToThis(){
    if [[ $directInFile == "1" ]]; then
        DM -dpa "Removing temporary infile..."
        rm "./${infileBaseName}"
        exit 0
    else
        exit 0
    fi
}

debugmessages=1 # manual flag to enable debug messages
annoyMe=1 # enable this if you love annoying debug messages
getUnixTimestamp(){ # get the current unix timestamp.
    date +%s
}
trap cleanupASingleFuckingTempFileThenExitWhyGodDoINeedAFuctionDedicatedToThis INT

DM -dpa "if you see this the annoyMe check passed" # debug annoyMe. this also serves as a warning if the user leaves it on.
if [[ -n "$1" ]]; then
    if [[ ! -e "$1" ]]; then
        DM -dpa "\$1 was not empty but did not contain a valid file."
        echo "Direct file usage: ./$(basename "$0") <file>"
        checkAAFC
    fi
    DM -dpa "\$1 has a valid file."
    directInFile="1"
    infileBaseName=$(basename "$1")
    DM -d "\$infileBaseName is $infileBaseName"
    DM -dpa "Attempting to copy direct file to current directory."
    if [[ -e "./${infileBaseName}" ]]; then
        echo -e "${der}what.${recl}" # writing actual error messages takes brainpower that i don't have
        exit 1
    fi
    cp "$1" "./${infileBaseName}"
    infileTMP="${infileBaseName}"
    infile="${infileTMP%.*}"
    extensionTMP="${infileTMP##*.}"
    extension=$extensionTMP
    DM -d "\$infileTMP is $infileTMP"
    DM -d "\$infile is $infile"
    DM -d "\$extension is $extension"
    checkAAFC
fi
checkAAFC
