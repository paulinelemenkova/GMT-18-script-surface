#!/bin/sh
# Purpose: Surface modelling of the topography along the Mariana Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert
# Step-1. Generate a file
ps=SurfaceGMT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1.3c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,dimgray \
    MAP_GRID_PEN_SECONDARY=thinnest,dimgray \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=6p,Palatino-Roman,dimgray \
    FONT_LABEL=6p,Palatino-Roman,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.
# Step-5. Check up dimensions of the table (data range)
gmt info grav_MT.xyz
# output: grav_MT.xyz: N = 3815189    <120.0083/160.0083>    <5.002/30.0019>    <-354.7/416.6>
# Step-6. Make color palette
gmt makecpt -Celevation.cpt -V -T-400/500 > surfMTgrav.cpt
# Step-7. Generate 1 by 1 minute block mode values from the raw ASCII data (xyg table)
gmt blockmode grav_MT.xyz -R120/160/5/30 -I1m -Vv > grav_MT_BM.xyg
# Step-8. Generate grid from xyz table format
gmt surface grav_MT_BM.xyg -R120/160/5/30 -T0.25 -I30s -GSurfaceG_MT.nc -Vv
# Step-9. Make raster image
gmt grdimage SurfaceG_MT.nc -CsurfMTgrav.cpt -R120/160/5/30 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
# Step-10. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a2 -Bpyg4f2a2 -Bsxg4 -Bsyg4 \
    -B+t"Surface modelling of the gravity along the Mariana Trench" -O -K >> $ps
# Step-11. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.8c/9.0c+w0.3i+f2+l+o0.0c \
    -Lx5.3i/-0.5i+c50+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-12. Add color legend
gmt psscale -R -J -CsurfMTgrav.cpt \
    -Dg120/4+w10c/0.4c+v+o-1.8/0.2c+ml  \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Surface gravimetric model color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-13. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-14. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y2.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.2 13.7 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.5 13.2 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmode filter.
3.0 12.7 Output spatial model: 30-sec grid spacing in netCDF format
EOF
# Step-15. Convert to image file using GhostScript
gmt psconvert SurfaceGMT.ps -A0.2c -E720 -P -Tj -Z
