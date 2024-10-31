# create one second of sinus wave

# ffmpeg -f lavfi -i "sine=frequency=220:duration=1:sample_rate=48000" -ac 2 -af "volume=20dB" sin48k.wav

ffmpeg -f lavfi -i "sine=frequency=220:duration=1:sample_rate=11025" -ac 2 -af "volume=20dB" sinus.wav
