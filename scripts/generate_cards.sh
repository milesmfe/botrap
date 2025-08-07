#!/bin/bash

# Configuration - Assets folder location
ASSETS_FOLDER="../assets"
CARDS_FOLDER="${ASSETS_FOLDER}/cards"

# Create output folder
mkdir -p "$CARDS_FOLDER"

# Card values
VALUES=("A" "2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K")

# Suits and settings
SUITS=("spades" "clubs" "hearts" "diamonds")
SYMBOLS=("♠" "♣" "♥" "♦")
COLORS=("black" "blue" "red" "gold")

# Card dimensions
WIDTH=256
HEIGHT=384
POINTSIZE=128
RADIUS=32

# Function to draw a rounded rectangle mask
create_rounded_mask() {
    local mask=$1
    convert -size ${WIDTH}x${HEIGHT} xc:none \
        -fill white -draw "roundrectangle 0,0,$((WIDTH-1)),$((HEIGHT-1)),$RADIUS,$RADIUS" \
        "$mask"
}

# Generate card fronts
for i in "${!SUITS[@]}"; do
    suit="${SUITS[$i]}"
    symbol="${SYMBOLS[$i]}"
    color="${COLORS[$i]}"

    for value in "${VALUES[@]}"; do
        base="temp_card.png"
        rounded="${CARDS_FOLDER}/${value}_of_${suit}.png"

        # Draw the base card
        convert -size ${WIDTH}x${HEIGHT} xc:white \
            -gravity north -pointsize $POINTSIZE -fill "$color" -annotate +0+8 "$value" \
            -gravity center -pointsize $((POINTSIZE + 6)) -fill "$color" -annotate +0+10 "$symbol" \
            "$base"

        # Create rounded version
        mask="mask.png"
        create_rounded_mask "$mask"
        convert "$base" "$mask" -compose CopyOpacity -composite "$rounded"
        # Cleanup
        rm "$base" "$mask"
    done
done

# Function to create a rounded solid color back
create_back() {
    local color="$1"
    local output="$2"
    local tmp="back_tmp.png"
    local mask="mask.png"

    convert -size ${WIDTH}x${HEIGHT} xc:"$color" "$tmp"
    create_rounded_mask "$mask"
    convert "$tmp" "$mask" -alpha on -compose DstIn -composite "$output"
    rm "$tmp" "$mask"
}

# Create red and blue backs
create_back "#B22222" "${CARDS_FOLDER}/back_red.png"
create_back "#1E3A8A" "${CARDS_FOLDER}/back_blue.png"

echo "✅ 52 card faces and 2 backs (red & blue) with rounded corners created in ${CARDS_FOLDER}/"
