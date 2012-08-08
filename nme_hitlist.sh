#!/bin/sh

hitlist_uri="http://en.wikipedia.org/w/index.php?title=List_of_1960s_UK_Singles_Chart_number_ones&action=edit&section=1"

wget -O- "$uri" \
| hxselect -c 'textarea[cols="80"]' \
| awk -F '[]{}[]' -f trim -v OFS="" -e '
/sort\|/ {
  band = $5
  song = $11
}

/sortname/ {
 band = $3
 song = $7
}

/dts/ {
  l = split(band, a, "|")
  if(l > 1) {
    band = ""
    for(i=2; i<=l; i++) {
      if(a[i] !~ / /)
        band = band " " a[i]
    }
  }
  l = split(song, a, "|")
  song = a[1]
  split($3, a, "|")
  year = a[4]
  gsub("&amp;", "\\&", band)
  gsub("&amp;", "\\&", song)
  print "Band: ", trim(band), "\nSong: ", song,"\nYear: ", year, "\n"
  band = ""
  song = ""
  year = ""
  delete(a)
}'
