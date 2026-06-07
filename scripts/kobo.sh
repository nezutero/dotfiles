#!/usr/bin/env bash

manga_name=$(basename "$PWD")
chapters=(Chapitre*)
total=${#chapters[@]}
per_volume=20
volume_num=1

for ((i=0; i<total; i+=per_volume)); do
  volume_dir="${manga_name} (Vol ${volume_num})"
  mkdir -p "$volume_dir"

  echo "Creating $volume_dir ..."

  # Copy (or move) 20 chapters into this volume
  for ((j=i; j<i+per_volume && j<total; j++)); do
    cp -r "${chapters[j]}" "$volume_dir/"
  done

  cd "$volume_dir" || exit

  # Zip each chapter inside the volume
  for chapitre in Chapitre*; do
    if [ -d "$chapitre" ]; then
      zip -qr "${chapitre}.zip" "$chapitre"
    fi
  done

  # Create a .cbz file for this volume
  zip -qr "../${volume_dir}.cbz" ./*.zip

  # Optional: remove intermediate zips and chapter folders
  rm -rf Chapitre* ./*.zip

  cd ..
  ((volume_num++))
done

echo "✅ All volumes created and converted to .cbz!"
