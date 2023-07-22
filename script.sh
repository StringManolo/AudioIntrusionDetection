#!/usr/bin env bash

# Amplitud superior a ruido de fondo
threshold=0.05

# Tiempo de inicio
sleep 10s

while true; do
    if [ -e "audio.m4a" ]; then
        echo "Eliminando audio.m4a anterior..."
        rm audio.m4a
    fi

    if [ -e "audio.wav" ]; then
        echo "Eliminando audio.wav anterior..."
        rm audio.wav
    fi

    # Grabar audio
    termux-microphone-record -l 5 -f audio.m4a > /dev/null

    # Esperar 5 segundos antes de acceder al archivo
    sleep 5s

    # Cambiar la codificación a formato popular (WAV)
    ffmpeg -i audio.m4a audio.wav > /dev/null 2>&1

    # Obtener la amplitud máxima del sonido
    pico=$(sox audio.wav -n stat 2>&1 | grep "Maximum amplitude" | awk '{print $3}')

    # Procesar la amplitud
    if (( $(echo "$pico >= $threshold" | bc) )); then
        echo "Intruso detectado! Pico: $pico"
        espeak -v es "Intruso detectado"
        termux-telephony-call +34666666666
    else
        echo "Ruido detectado. Pico: $pico"
    fi

    # Esperar antes de la próxima grabación
    sleep 1s
done
