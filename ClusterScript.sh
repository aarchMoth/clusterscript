#!/bin/bash

#      -+- ClusterScript -+-
#  -+- Rev. 1.0-LINRELEASE -+-

# these need to be at the top for Reasons
DIV_VERSION="Rev. 1.0-LINRELEASE"
whoAmI="aarchMoth"

thatFancyEffectTwo(){
    one=$1
    echo ""
    for ((i=1;i<=${#1};i++)); do
        clrple "${one:(-$i):$i}"
        sleep 0.05
    done
}

thatFancyEffect(){
    one=$1
    echo ""
    for ((i=1;i<=${#1};i++)); do
        clrple "${one:0:$i}"
        sleep 0.05
    done
}

credits(){
    random=$RANDOM
    clear
    eepyTimeShort="0.5"
    eepyTimeLong="2"
    if [[ $random -lt 4000 ]]; then
        if [[ $RANDOM -le 9000 ]]; then
            echo "Playing: Credits (2A03 + VRC6, $whoAmI)"
            sndplay creditsnes -l
        else
            echo "Playing: Credits (OPL2, $whoAmI)"
            sndplay creditsopl2 -l
        fi
    else
        if [[ $RANDOM -lt 16384 ]]; then
            echo "Playing: Credits (PC v1, $whoAmI)"
            sndplay creditspcaarch -l
        else
            echo "Playing: Credits (PC v2, Architect)"
            sndplay creditspcarchitect -l
        fi
    fi
    echo "[CREDITS]" && echo ""
    sleep $eepyTimeLong
    echo "Creator:"
    sleep $eepyTimeShort
    thatFancyEffect "$whoAmI" && echo ""
    sleep $eepyTimeLong
    echo "Contributors:"
    sleep $eepyTimeShort
    thatFancyEffect "$whoAmI"
    sleep $eepyTimeShort
    thatFancyEffectTwo "Architect" && echo ""
    sleep $eepyTimeLong
    echo "Music (Credits):"
    sleep $eepyTimeShort
    thatFancyEffect "$whoAmI (OPL2, 2A03 + VRC6, PC v1)"
    thatFancyEffectTwo "Architect (PC v2)" && echo ""
    sleep $eepyTimeLong
    echo "Sounds:"
    sleep $eepyTimeShort
    thatFancyEffect "$whoAmI (original)"
    sleep $eepyTimeShort
    thatFancyEffectTwo "Architect (new)" && echo ""
    sleep $eepyTimeLong
    echo "Special Thanks:"
    sleep $eepyTimeShort
    thatFancyEffect "subG/ashley"
    sleep $eepyTimeShort
    thatFancyEffectTwo "EntropyAuthor"
    sleep $eepyTimeShort
    thatFancyEffect "StackOverflow"
    sleep $eepyTimeShort
    thatFancyEffectTwo "www.devhints.io"
    sleep $eepyTimeShort
    echo ""
    echo "and finally..."
    sleep 0.2
    for i in {1..10}; do
        clrple "" && sleep 0.05
        clrple "and finally..."
        sleep 0.05
    done
    sleep $eepyTimeLong
    echo ""
    thatFancyEffect "Thank"
    sleep 0.3
    clrple "Thank Y" && sleep 0.2
    clrple "Thank YO" && sleep 0.2
    clrple "Thank YOU" && sleep 0.2
    clrple "Thank YOU!"
    sleep $eepyTimeLong
    echo ""
    if [[ $directToCredits -eq 1 ]]; then
        exitSaying="exit..."
    else
        exitSaying="go back to the menu..."
    fi
    read -p "Press any key at any time to $exitSaying " -n 1 -r # halt until a key press is detected
    echo ""
    pkill play
    if [[ $directToCredits -eq 1 ]]; then
        exit 0
    else
        MainAskExtended
    fi
}

notify(){ # notify with format: (appname hard-coded) [title] [body] <notification sound>
    notify-send -a ClusterScript "$1" "$2"
    if [[ -n $3 && $nosound -ne 1 ]]; then
        sndplay "$3"
    fi
}

sndplay(){
    if [[ $2 == "-l" ]]; then
        if ! command -v sox 2>&1 >/dev/null; then
            loopType="-loop 0"
        else
            loopType="repeat 2000000000"
        fi
    else
        loopType=""
    fi
    if [[ $nosound -eq 1 ]]; then return; fi # one-liner to immediately exit if nosound is on
    if ! command -v sox 2>&1 >/dev/null; then
        # WARNING: PUTTING QUOTES AROUND $loopType CAUSES FFPLAY TO BREAK!!
        ffplay $loopType -hide_banner -loglevel error -i "cluster_sound/${1}.wav" -autoexit -nodisp &
    else
        # WARNING: PUTTING QUOTES AROUND $loopType CAUSES PLAY TO BREAK!!
        play -q "cluster_sound/${1}.wav" $loopType &
    fi
}

clrpl(){ # CLeaR Previous Line
    tput cuu1 # move cursor up
    tput el   # clear line
}

clrple(){ # CLeaR Previous Line (with Echo)
    tput cuu1 # move cursor up
    tput el   # clear line
    echo "$1" # echo the func input
}

AtTheEnd() { # we finished the function!
    if [[ $directInFile == "1" ]]; then
        rm "./${_infile}"
    fi
    if [[ $RANDOM == "5709" ]]; then
        echo "Trans rights!" # some people may get mad over this. those people deserve to get hit over the head with a cast iron skillet
    fi
    notify "Conversion complete" "Conversion completed with hopefully no errors." convsuccess
    read -p "Do you want to convert another file? (Y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        MainAsk
    else
        exit 1
    fi
}

LowQualitize() {
    if [[ $noInFIle -eq 1 ]]; then
        echo "You have not provided a file!"
        MainAskExtended
    fi
    eepyTime="0.4"
    # the first ClusterScript function ever.
    if [[ -e cluster_result ]]; then
        true
    else
        mkdir "cluster_result"
    fi
    sleep 0.5
    # the initial 5
    echo "Opus: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_1kbopus_*") ]]; then
        clrple "Opus: 1kbopus"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 1k "cluster_result/$1_1kbopus_$RANDOM.ogg"
    else
        _1kbAG=1 # 1kbopus Already Generated
        clrple "Opus: 1kbopus already generated"
        sleep $eepyTime
    fi
    if [[ -z $(find cluster_result -name "$1_8kbopus_*") ]]; then
        clrple "Opus: 8kbopus"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libopus -b:a 8k "cluster_result/$1_8kbopus_$RANDOM.ogg"
        clrple "Opus: Complete"
    elif [[ $_1kbAG -eq 1 ]]; then # both exist already
        clrple "Opus: Already generated"
    else
        clrple "Opus: 8kbopus already generated"
    fi
    echo "MP3: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_8kbmp3_*") ]]; then
        clrple "MP3: 8kbmp3"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -b:a 8k -ar 8000 "cluster_result/$1_8kbmp3_$RANDOM.mp3"
        clrple "MP3: Complete"
    else
        clrple "MP3: Already generated"
    fi
    echo "SPEEX: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_1kbspeex_*") ]]; then
        clrple "SPEEX: 1kbspeex"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 1k -acodec libspeex "cluster_result/$1_1kbspeex_$RANDOM.ogg"
    else
        clrple "SPEEX: 1bkspeex already generated"
        _1kbsAG=1
        sleep $eepyTime
    fi
    if [[ -z $(find cluster_result -name "$1_8kbspeex_*") ]]; then
        clrple "SPEEX: 8kbspeex"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 8k -acodec libspeex "cluster_result/$1_8kbspeex_$RANDOM.ogg"
        clrple "SPEEX: Complete"
    elif [[ $_1kbsAG -eq 1 ]]; then
        clrple "SPEEX: Already generated"
    else
        clrple "SPEEX: 8kbspeex already generated"
    fi

    # 3 bit depth 4096hz and dpcm8192
        if [[ $noaafc == 1 ]]; then
        echo "NoAAFC has been enabled, skipping AAFC functions... "
    else
        echo "AAFC: [...]"
        cd "cluster_AAFC" || return
        sleep "$eepyTime"
        clrple "FFmpeg: generating AAFC input"
        ffmpeg -hide_banner -loglevel error -y -i "../$1.$2" "../$1_tmp.wav"
        if [[ -z $(find ../cluster_result -name "$1_3bitdepth4096hz_*") ]]; then
            clrple "AAFC: 3-bit 4096Hz"
            ./aud2aafc -i "../$1_tmp.wav" --bps 3 -ar 4096 > /dev/null # aafc pass 1
            clrple "AAFC: converting to WAV..."
            ./aafc2wav "aafc_conversions/$1_tmp.aafc" "../cluster_result/$1_3bitdepth4096hz_$RANDOM" > /dev/null
        else
            _3bd4hAG=1
            clrple "AAFC: 3bitdepth4096hz already generated"
            sleep $eepyTime
        fi
        if [[ -z $(find ../cluster_result -name "$1_dpcm8192hz_*") ]]; then
            clrple "AAFC: dpcm8192"
            ./aud2aafc -i "../$1_tmp.wav" -n -m --dpcm -ar 8192 > /dev/null # aafc pass 2, OVERWRITE DISTHINGKFXLKZJ
            clrple "AAFC: converting to WAV..."
            ./aafc2wav "aafc_conversions/$1_tmp.aafc" "../cluster_result/$1_dpcm8192hz_$RANDOM" > /dev/null
            clrple "AAFC: Complete"
        elif [[ $_3bd4hAG -eq 1 ]]; then
            clrple "AAFC: Already generated"
        else
            clrple "AAFC: DPCM8192 already generated"
            if [[ $keepTempFiles -ne 1 ]]; then
                rm "aafc_conversions/$1_tmp.aafc" "../$1_tmp.wav"
            fi
        fi
        cd ..
    fi

    # CODify
    echo "CODify: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_codlobby_*") ]]; then
        clrple "CODify: generate temporary SPEEX"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -ar 8000 -b:a 1k -acodec libspeex "TEMPSPEEX_$1.$2.ogg" # encode to speex for Effect(tm)
        clrple "CODify: encode with Opus"
        ffmpeg -hide_banner -loglevel error -y -i "TEMPSPEEX_$1.$2.ogg" -c:a libopus -b:a 1k "TEMPOPUS_$1.$2.ogg" # encode that speex with OPUS
        clrple "CODify: make loud"
        ffmpeg -hide_banner -loglevel error -y -i "TEMPOPUS_$1.$2.ogg" -filter:a "volume = 35dB" "TEMPLOUD_$1.$2.wav" # make it loud for that COD Quality(tm)
        clrple "CODify: encode with Opus"
        ffmpeg -hide_banner -loglevel error -y -i "TEMPLOUD_$1.$2.wav"  -c:a libopus -b:a 1k "cluster_result/$1_codlobby_$RANDOM.ogg" # encode it with opus again for that Extra Quality(tm)
        if [[ $keepTempFiles -ne 1 ]]; then
            rm "TEMPOPUS_$1.$2.ogg"
            rm "TEMPSPEEX_$1.$2.ogg"
            rm "TEMPLOUD_$1.$2.wav"
        fi
        clrple "CODify: Complete"
    else
        clrple "CODify: Already generated"
    fi

    # SSDPCM
    if [[ -z $(find cluster_result -name "$1_1bssdpcm11025_*") ]]; then
        if [[ $nossdpcm == 1 ]]; then
            echo "NoSSDPCM has been enabled, skipping SSDPCM... "
        else
            echo "SSDPCM: [...]"
            sleep "$eepyTime"
            clrple "FFmpeg: generating SSDPCM input"
            ffmpeg -hide_banner -loglevel error -i "$1.$2" -ar 11025 "$1_temp11025hz.wav" # take the input and convert it to 11025Hz WAV temporarily
            clrple "SSDPCM: encode"
            ./cluster_SSDPCM/encoder ss1 "$1_temp11025hz.wav" "$1_tempssdpcm.aud" > /dev/null 2>&1 # convert the 11025Hz WAV to 1-bit SSDPCM
            clrple "SSDPCM: decode"
            ./cluster_SSDPCM/encoder decode "$1_tempssdpcm.aud" "cluster_result/$1_1bssdpcm11025_$RANDOM.wav" > /dev/null 2>&1 # convert the 1-bit SSDPCM back to WAV
            if [[ $keepTempFiles -ne 1 ]]; then
                rm "$1_temp11025hz.wav" # remove the temporary 11025Hz WAV
                rm "$1_tempssdpcm.aud" # remove the temporary 1-bit SSDPCM
            fi
            clrple "SSDPCM: Complete"
        fi
    else
        echo "SSDPCM: [..]"
        sleep $eepyTime
        clrple "SSDPCM: Already generated"
    fi

    # stereo difference (inverted right channel (FFmpeg), out-of-phase stereo (SoX))
    echo "Stereo Difference: [...]"
    if [[ -z $(find cluster_result -name "$1_stdiff_*") ]]; then
        if ! command -v sox 2>&1 >/dev/null
        then
            clrple "Stereo Difference (FFmpeg): split audio channels"
            ffmpeg -hide_banner -loglevel error -i "$1.$2" -filter_complex \
            "[0:0]pan=1|c0=c0[left]; \
            [0:0]pan=1|c0=c1[right]" \
            -map "[left]" left.wav -map "[right]" right.wav
            clrple "Stereo Difference (FFmpeg): invert right channel"
            ffmpeg -hide_banner -loglevel error -i right.wav -af "aeval='-val(0)':c=same" rightinv.wav
            clrple "Stereo Difference (FFmpeg): mix channels"
            ffmpeg -hide_banner -loglevel error -i left.wav -i rightinv.wav -filter_complex amix=inputs=2:duration=longest "cluster_result/$1_stdiff_$RANDOM.wav"
            if [[ $keepTempFiles -ne 1 ]]; then
                    rm left.wav
                rm right.wav
                rm rightinv.wav
            fi
            clrple "Stereo Difference (FFmpeg): Complete"
        else
            clrple "FFmpeg: generating SoX input"
            ffmpeg -hide_banner -loglevel error -i "$1.$2" ".tempwav.wav" # "sox FAIL formats: no handler for file extension `mp3'"
            clrple "Stereo Difference (SoX): run \"oops\" pass"
            sox ".tempwav.wav" "cluster_result/$1_stdiff_$RANDOM.wav" gain -1 oops
            if [[ $keepTempFiles -ne 1 ]]; then
                    rm ".tempwav.wav"
            fi
            clrple "Stereo Difference (SoX): Complete"
        fi
    else
        clrple "Stereo Difference: Already generated"
    fi
    # DFPWM, AAC, squash&stretch
    echo "DFPWM: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_11025hzdfpwm_*") ]]; then
        clrple "DFPWM: encode"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a dfpwm -ar 11025 ".tempwav.wav"
        clrple "DFPWM: decode"
        ffmpeg -hide_banner -loglevel error -y -i ".tempwav.wav" -ar 44100 "cluster_result/$1_11025hzdfpwm_$RANDOM.wav"
        clrple "DFPWM: Complete"
    else
        clrple "DFPWM: Already generated"
    fi

    echo "AAC: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_16kbaac_*") ]]; then
        clrple "AAC: encode"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a aac -b:a 16k -filter:a "volume=0.5" "cluster_result/$1_16kbaac_$RANDOM.aac" # low quality AAC tends to be loud, decrease volume by 2x to avoid clipping and bursting eardrums
        clrple "AAC: Complete"
    else
        clrple "AAC: Already generated"
    fi

    echo "Stretch 2x: [                ] (0%)"
    sleep $eepyTime
    if [[ -z $(find cluster_result -name "$1_stretch_2x_*") ]]; then
        clrple "Stretch 2x: [========        ] (50%)"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=2" ".tempstretch.wav" # 2x
        clrple "Stretch 2x: [================] (100%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" "cluster_result/$1_stretch_2x_$RANDOM.wav" # 1x
        clrple "2x stretch done!"
    else
        _2xsAG=1
        clrple "2x stretch already generated!" # this is what happens when one happens
    fi

    echo "Stretch 4x: [                ] (0%)"
    sleep $eepyTime
    if [[ -z $(find cluster_result -name "$1_stretch_4x_*") || -z $(find cluster_result -name "$1_stretch_*") ]]; then # accounting for legacy "$1_stretch_$RANDOM"
        clrple "Stretch 4x: [======          ] (34%)"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=4" ".tempstretch.wav" # 4x
        clrple "Stretch 4x: [==========      ] (67%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" ".tempstretch2.wav" # 2x
        clrple "Stretch 4x: [================] (100%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch2.wav" -af "atempo=0.5" "cluster_result/$1_stretch_4x_$RANDOM.wav" # 1x
        clrple "4x stretch done!"
    else
        _4xsAG=1
        clrple "4x stretch already generated!"
    fi

    echo "Stretch 8x: [                ] (0%)"
    sleep $eepyTime
    if [[ -z $(find cluster_result -name "$1_stretch_8x_*") ]]; then
        clrple "Stretch 8x: [====            ] (25%)"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -af "atempo=8" ".tempstretch.wav" # 8x
        clrple "Stretch 8x: [========        ] (50%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" ".tempstretch2.wav" # 4x
        clrple "Stretch 8x: [============    ] (75%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch2.wav" -af "atempo=0.5" ".tempstretch.wav" # 2x
        clrple "Stretch 8x: [================] (100%)"
        ffmpeg -hide_banner -loglevel error -y -i ".tempstretch.wav" -af "atempo=0.5" "cluster_result/$1_stretch_8x_$RANDOM.wav" # 1x
        clrple "8x stretch done!"
    else
        _8xsAG=1
        clrple "8x stretch already generated!"
    fi


    if [[ $_2xsAG -ne 1 || $_4xsAG -ne 1 || $_8xsAG -ne 1 && $keepTempFiles -ne 1 ]]; then
        # MENTAL NOTE: if 2xs, 4xs, and 8xs all generate nothing this doesn't run, but even if ONE ~~happens~~ generates, it runs
        rm ".tempwav.wav"
        rm ".tempstretch.wav"
        rm ".tempstretch2.wav"
    fi

    echo "GSM: [...]"
    sleep "$eepyTime"
    if [[ -z $(find cluster_result -name "$1_gsm*") ]]; then
        clrple "GSM: encode"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:a libgsm -ar 8000 ".tempgsm.gsm"
        clrple "GSM: decode"
        ffmpeg -hide_banner -loglevel error -y -i ".tempgsm.gsm" -c:a pcm_s16le -ar 44100 "cluster_result/$1_gsm_$RANDOM.wav"
        clrple "GSM: Complete!"
        if [[ $keepTempFiles -ne 1 ]]; then
            rm ".tempgsm.gsm"
        fi
    else
        clrple "GSM: Already generated"
    fi

    AtTheEnd
}

Visualize() {
    # the newest function in the current iteration. designed to be modular.

    if [[ $noInFIle -eq 1 ]]; then
        echo "You have not provided a file!"
        MainAskExtended
    fi

    echo "This may take a long time!"

    if [[ -e cluster_result ]]; then
        true
    else
        mkdir "cluster_result"
    fi

    # Vectorscope
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -filter_complex "[0:a]avectorscope=draw=line:mode=lissajous_xy:rf=50:bf=50:gf=50:af=50:rc=255:bc=255:gc=255:r=60:s=1080x1080,format=yuv420p[v]" -map "[v]" -map 0:a -vcodec libx264 -movflags frag_keyframe+empty_moov "cluster_result/$1_vectscope_$RANDOM.mp4" # initially wasn't fragmenting. attempt #1 to fix: tacking on "-movflags frag_keyframe+empty_moov", also made resolution 1080x1080.

    # Modified Binary Waterfall
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

    if [[ $keepTempFiles -ne 1 ]]; then
        rm ".temppcmu8.wav" # clean up tempfile
    fi

    AtTheEnd
}

LowQualitizeVideo(){

    eepyTime="0.4"

    if [[ $RANDOM == "3000" ]]; then # originally a placeholder but made me laugh my ass off
        echo "Place. Hold. erv.;s,;dm nnnajklv;smrnkkkahkcv"
    elif [[ $RANDOM == "20" ]]; then # aRchitcte
        echo "holdis palic of holderplace"
    fi

    if [[ $noInFIle -eq 1 ]]; then # standard CYA code
        echo "You have not provided a file!"
        MainAskExtended
    fi

    echo "Video: [...]"
    sleep $eepyTime
    if [[ -z $(find cluster_result -name "$1_80kbx264aac_*") ]]; then
        clrple "Video: 80k x264, AAC"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 80k -c:a aac -b:a 16k "cluster_result/$1_80kbx264aac_${RANDOM}.mp4"
    else
        clrple "Video: 80k x264 w/ AAC already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_50kbx264aac_*") ]]; then
        clrple "Video: 50k x264, AAC"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 50k -c:a aac -b:a 16k "cluster_result/$1_50kbx264aac_${RANDOM}.mp4"
    else
        clrple "Video: 50k x264 w/ AAC already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_30kbx264aac_*") ]]; then
        clrple "Video: 30k x264, AAC"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 30k -c:a aac -b:a 16k "cluster_result/$1_30kbx264aac_${RANDOM}.mp4"
    else
        clrple "Video: 30k x264 w/ AAC already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_80kbx264opus_*") ]]; then
        clrple "Video: 80k x264, Opus"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 80k -c:a libopus -b:a 1k "cluster_result/$1_80kbx264opus_${RANDOM}.mp4"
    else
        clrple "Video: 80k x264 w/ Opus already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_50kbx264opus_*") ]]; then
        clrple "Video: 50k x264, Opus"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 50k -c:a libopus -b:a 1k "cluster_result/$1_50kbx264opus_${RANDOM}.mp4"
    else
        clrple "Video: 50k x264 w/ Opus already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_30kbx264opus_*") ]]; then
    clrple "Video: 30k x264, Opus"
    ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v libx264 -b:v 30k -c:a libopus -b:a 1k "cluster_result/$1_30kbx264opus_${RANDOM}.mp4"
    else
        clrple "Video: 30k x264 w/ Opus already generated"
        sleep $eepyTime
    fi

    if [[ -z $(find cluster_result -name "$1_flvmp3_*") ]]; then
        clrple "Video: FLV, MP3"
        ffmpeg -hide_banner -loglevel error -y -i "$1.$2" -c:v flv -b:v 69k -c:a libmp3lame -b:a 32k -ar 11025 "cluster_result/$1_flvmp3_${RANDOM}.flv" # NOTE: Untested
    else
        clrple "Video: FLV /w MP3 already generated"
        sleep $eepyTime
    fi

    clrple "Video: Complete"

    AtTheEnd

}

MainAsk() {
    # ask for the file
    read -r -e -p "Type the name of the file: " file
    infile="${file%.*}" # credit to Architect for these lines
    extension="${file##*.}" # credit to Architect for these lines
    if [[ -e "$infile.$extension" ]]; then # check if the file actually exists
        sndplay startmenu
        MainAskExtended
    else
        sndplay error
        echo "File does not exist. Please try again." # fun fact: we did not have this check until semi-recently
        MainAsk
    fi
}

MainAskExtended(){
    # functions menu
    if [[ $extension == "mp4" || $extension == "webm" ]]; then
        one="Video LowQualitize"
    else
        one="Visualize"
    fi
    echo "Select a function (or press C for credits):"
    echo "LowQualitize (1), $one (2)"
    read -p "" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY == "1" ]]; then
        LowQualitize "$infile" "$extension"
    elif [[ $REPLY == "2" ]]; then
        if [[ $one == "Video LowQualitize" ]]; then
            LowQualitizeVideo "$infile" "$extension"
        else
            Visualize "$infile" "$extension"
        fi
    elif [[ $REPLY =~ ^[Cc]$ ]]; then
        credits
    fi
}

checkSND(){
    if [[ -e ./cluster_sound ]]; then # if folder exists, then
        if [[ $directInFile == "1" ]]; then
            MainAskExtended
        else
            sndplay startprompt
            MainAsk
        fi
    else
        echo "Sound folder does not exist! Disabling sound..."
        nosound=1
        if [[ $directInFile == "1" ]]; then
            MainAskExtended
        else
            sndplay startprompt
            MainAsk
        fi
    fi
}

checkSSDPCM(){
    if [[ -e ./cluster_SSDPCM ]]; then # if the folder exists, then:
        if [[ -e ./cluster_SSDPCM/encoder ]]; then # if the SSDPCM encoder file exists, then:
            checkSND
        else # SSDPCM encoder does not exist
            echo "SSDPCM encoder does not exist, disabling SSDPCM... "
            nossdpcm=1
            checkSND
        fi
    else # SSDPCM folder does not exist
        echo "SSDPCM folder does not exist! Create the folder \"cluster_SSDPCM\" and put the required SSDPCM files into it!"
        echo "Disabling SSDPCM..."
        nossdpcm=1
        checkSND
    fi
}


checkAAFC(){
    if [[ -e ./cluster_AAFC ]]; then # if the folder exists, then:
        if [[ -e cluster_AAFC/aud2aafc ]] && [[ -e cluster_AAFC/aafc2wav ]] && [[ -e cluster_AAFC/libaafc.so ]]; then # if the required files exist, then:
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
    if [[ $keepTempFiles -eq 1 ]]; then
        exit 0
    fi
    if [[ $directInFile == "1" ]]; then
        rm "./${_infile}"
        exit 0
    else
        exit 0
    fi
}

getUnixTimestamp(){ # get the current unix timestamp.
    date +%s
}
trap cleanupASingleFuckingTempFileThenExitWhyGodDoINeedAFuctionDedicatedToThis INT

if [[ -n "$1" ]]; then
    onetwo=$1
    if [[ "$1" == "-k" ]]; then
        keepTempFiles=1
        MainAsk
    elif [[ "$1" == "-m" ]]; then
        noInFIle=1
        MainAskExtended
    elif [[ "$1" == "-h" ]]; then
        echo "ClusterScript, the audiovisual obliteration tool"
        echo "Version: $DIV_VERSION"
        echo "Usage: ./$(basename "$0") <switches/file>"
        echo "Switches:
-c: Show credits directly
-m: Enter menu with no file (Legacy)
-h: Show this help text"
        exit 0
    elif [[ "$1" == "-c" ]]; then
        directToCredits=1
        credits
    fi
    if [[ ! -e "$1" ]]; then
        echo "Invalid file!"
        echo "Direct file usage: ./$(basename "$0") <file>"
        exit 1
    fi
    directInFile="1"
    _infile=${onetwo##*/}
    if [[ -e "./${onetwo}" ]]; then
        echo "A file with that name already exists in current directory, use that instead? (Y/N)"
        read -p "" -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$  ]]; then
            _infile=${onetwo##*/} # "[out#0/mp3 @ 0x634f96f84fc0] Error opening output cluster_result//home/ashley/Documents/_3_8kbmp3_6364.mp3: No such file or directory"
            infile="${_infile%.*}"
            extension="${_infile##*.}"
            MainAskExtended
        else
            exit 0
        fi
    fi
    cp "$1" "./${_infile}"
    infileTMP="${_infile}"
    infile="${infileTMP%.*}"
    extensionTMP="${infileTMP##*.}"
    extension=$extensionTMP
    if [[ -e ./cluster_sound ]]; then
        sndplay startdirect
    fi
    checkAAFC
fi
checkAAFC
