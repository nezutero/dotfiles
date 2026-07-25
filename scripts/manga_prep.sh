#!/usr/bin/env bash
#
# manga_prep.sh
#
# Full pipeline to go from raw downloaded chapter files straight to
# something KCC can convert:
#
#   1. Rename "Chapitre N_hash.cbz" -> "Chapitre 0NN.cbz" (zero-padded,
#      hash stripped) so files sort correctly.
#   2. Split the zero-padded chapters into "volumes/Volume NN/" folders,
#      N chapters per volume (default 10).
#   3. Extract each chapter .cbz inside every volume folder into its own
#      subfolder of images, then delete the original .cbz -- KCC refuses
#      folders that contain nested archives, so this step is required.
#
# End result:
#   volumes/Volume 01/Chapitre 001/*.jpg
#   volumes/Volume 01/Chapitre 002/*.jpg
#   ...
#   volumes/Volume 24/Chapitre 240/*.jpg
#
# Point KCC at each "volumes/Volume NN" folder to convert one volume per
# book (see the printed instructions at the end of this script).
#
# Usage:
#   ./manga_prep.sh                 # everything, 10 chapters/volume
#   ./manga_prep.sh 12               # everything, 12 chapters/volume
#   ./manga_prep.sh --dry-run        # show what would happen, change nothing
#   ./manga_prep.sh --dry-run 12     # dry-run with a custom volume size
#
# Safe to re-run: already-renamed files, already-split volumes, and
# already-extracted chapters are all detected and skipped.
#
# Run this from the folder that contains your "Chapitre *.cbz" files.

set -euo pipefail

CHUNK_SIZE=10
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    ''|*[!0-9]*) ;;      # ignore anything that's not a plain number
    *) CHUNK_SIZE="$arg" ;;
  esac
done

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# Step 1: rename "Chapitre N_hash.cbz" -> "Chapitre 0NN.cbz"
echo "== Step 1: renaming chapter files =="

shopt -s nullglob
files=(Chapitre*.cbz)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No files matching 'Chapitre*.cbz' found in $(pwd)."
  echo "(this is fine if you already ran Step 1 and moved on to volumes/)"
else
  for f in "${files[@]}"; do
    num=$(echo "$f" | grep -oP '(?<=Chapitre )[0-9]+' || true)

    if [[ -z "$num" ]]; then
      echo "  ! skipping '$f' (couldn't find a chapter number)"
      continue
    fi

    # force base-10 interpretation: printf treats a leading-zero string
    # like "008" as octal otherwise, which crashes on numbers with 8/9.
    padded=$(printf "%03d" "$((10#$num))")
    newname="Chapitre ${padded}.cbz"

    if [[ "$f" == "$newname" ]]; then
      continue
    fi

    if [[ -e "$newname" && "$DRY_RUN" -eq 0 ]]; then
      echo "  ! skipping '$f' -> '$newname' (target already exists)"
      continue
    fi

    echo "  '$f' -> '$newname'"
    run mv -n -- "$f" "$newname"
  done
fi

# Step 2: split zero-padded chapters into volume folders
echo
echo "== Step 2: splitting into volumes of $CHUNK_SIZE chapters =="

run mkdir -p volumes

# null-delimited so filenames with spaces are handled safely (plain
# command substitution word-splits on spaces and breaks things)
shopt -s nullglob
mapfile -d '' renamed < <(printf '%s\0' Chapitre*.cbz | sort -z)
shopt -u nullglob

if [[ ${#renamed[@]} -eq 0 ]]; then
  echo "No top-level chapter files left to split (already split, or none found)."
else
  i=1
  vol=1
  for f in "${renamed[@]}"; do
    voldir=$(printf "volumes/Volume %02d" "$vol")
    run mkdir -p "$voldir"
    echo "  '$f' -> '$voldir/'"
    run mv -- "$f" "$voldir/"

    if (( i % CHUNK_SIZE == 0 )); then
      ((vol++)) || true
    fi
    ((i++)) || true
  done
fi

# Step 3: extract each chapter .cbz inside every volume into images
echo
echo "== Step 3: extracting chapters inside each volume =="

shopt -s nullglob
volume_dirs=(volumes/*/)
shopt -u nullglob

if [[ ${#volume_dirs[@]} -eq 0 ]]; then
  echo "No volume folders found under ./volumes -- nothing to extract."
else
  extracted=0
  for vol in "${volume_dirs[@]}"; do
    shopt -s nullglob
    cbz_files=("$vol"*.cbz)
    shopt -u nullglob

    if [[ ${#cbz_files[@]} -eq 0 ]]; then
      continue
    fi

    echo "  -- $vol --"
    for cbz in "${cbz_files[@]}"; do
      base="$(basename "$cbz" .cbz)"
      destdir="${vol}${base}"

      echo "    '$cbz' -> '${destdir}/'"

      if ! run mkdir -p "$destdir"; then
        echo "    ! ERROR: could not create '$destdir', skipping this chapter"
        continue
      fi

      if ! run unzip -q -o "$cbz" -d "$destdir"; then
        echo "    ! ERROR: unzip failed on '$cbz' (left in place)"
        continue
      fi

      if ! run rm -- "$cbz"; then
        echo "    ! WARNING: extracted '$cbz' but couldn't delete the original"
      fi

      extracted=$((extracted + 1))
    done
  done
  echo "  Extracted $extracted chapter archive(s) this run."
fi

echo
echo "== Done =="
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "(dry-run: no files were actually changed)"
else
  echo "Next: point KCC at each volume folder, e.g.:"
  echo "  kcc-c2e -p KoF -m -f EPUB -o ./output \"./volumes/Volume 01\"   # test one first"
  echo "  kcc-c2e -p KoF -m -f EPUB -o ./output ./volumes/Volume*        # then the rest"
fi
