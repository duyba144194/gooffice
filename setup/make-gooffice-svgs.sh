#!/bin/bash -e
# Generate GoOffice brand SVG at any size N (in px)
# Green rounded-square mark with 3 white lines — the GoOffice logo
SIZE=${1:-64}
cat <<SVGEND
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $SIZE $SIZE">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#00d482"/><stop offset="1" stop-color="#008c54"/>
  </linearGradient></defs>
  <rect x="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.055}")" y="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.055}")"
        width="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.89}")"
        height="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.89}")"
        rx="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.21}")" fill="url(#g)"/>
  <rect x="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.235}")" y="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.31}")"
        width="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.53}")"
        height="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")"
        rx="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")" fill="#fff"/>
  <rect x="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.235}")"
        y="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.31+$SIZE*0.055*1.7}")"
        width="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.53}")"
        height="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")"
        rx="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")" fill="#fff"/>
  <rect x="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.235}")"
        y="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.31+$SIZE*0.055*3.4}")"
        width="$(awk "BEGIN{printf \"%.0f\",$SIZE*0.33}")"
        height="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")"
        rx="$(awk "BEGIN{v=int($SIZE*0.055); if(v<1)v=1; print v}")" fill="#fff"/>
</svg>
SVGEND
