#!/bin/zsh

if [[ ! $1 =~ ^[0-9]+$ ]]; then
  echo First argument should specify the year.
fi

if (( $1 >= 2000 )); then
  uri="http://en.wikipedia.org/w/index.php?title=List_of_${1}s_UK_Singles_Chart_number_ones&action=edit&section=2"
else
  uri="http://en.wikipedia.org/w/index.php?title=List_of_${1}s_UK_Singles_Chart_number_ones&action=edit&section=1"
fi

#wget -qO- "$uri" > dims
#cat 00s.mu \
wget -qO- "$uri" \
| hxselect -c 'textarea[cols="80"]' \
| awk -F '[]{}[]' -f trim -v OFS="" -e '
/sort\|/ {
  band = $5

  if($11 == "") {
    song = $15
  }
  else
    song = $11

  l = split(band, a, "|")
  band = a[1]
}

/sortname/ {
  band = $3
  song = $7
  l = split(band, a, "|")
  if(l > 1) {
    band = ""
    for(i=2; i<=l; i++) {
      if(a[i] !~ / /)
        band = band " " a[i]
    }
  }
}

/^\| ?\|? ?\[\[/ {
  band = $3
  song = $7
  l = split(band, a, "|")
  band = a[1]
}

/dts/ {
  l = split(song, a, "|")
  song = a[1]
  split($3, a, "|")

  if($2 ~ /link/ || $2 == "")
    year = a[4]
  else
    year = a[3]

  gsub("&amp;", "\\&", band)
  gsub("&amp;", "\\&", song)
  gsub("#.*", "", band)
  gsub("#.*", "", song)

  #print "Band: ", trim(band), "\nSong: ", song,"\nYear: ", year, "\n"
  printf("%s|%s|%s\n", trim(band), trim(song), trim(year));
  band = ""
  song = ""
  year = ""
  delete(a)
}'
