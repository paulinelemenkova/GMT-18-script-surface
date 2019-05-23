#!/bin/sh
# Purpose: Surface modelling of the topography along the Mariana Trench
# GMT modules: gmtset, gmtdefaults, makecpt, gmtinfo, blockmean, surface, grdgradient, grdimage, psbasemap, psscale, gmtlogo, pstext, psconvert
# Step-1. Generate a file
ps=SurfaceTMT.ps
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
    FONT_LABEL=6p,Palatino-Roman,dimgray \
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-4. Download data:
### http://topex.ucsd.edu/cgi-bin/get_data.cgi
## E-144-162;N40-51.
# Step-5. Check up dimensions of the table (data range)
gmt info topo_MT.xyz
# output: topo_MT.xyz: N = 3815189    <120.0083/160.0083>    <5.002/30.0019>    <-10913/3559>
# Step-6. Make color palette
gmt makecpt -CGMT_sealand.cpt -V -T-11000/4000 > surfaceMT.cpt
# Step-7. Generate 1 by 1 minute block mean values from the raw ASCII data (xyg table)
gmt blockmean topo_MT.xyz -R120/160/5/30 -I1m -Vv > topo_MT_BM.xyg
# Step-8. Generate grid from xyz table format
gmt surface topo_MT_BM.xyg -R120/160/5/30 -T0.25 -I30s -GSurface_MT.nc -Vv
# Step-9. Make gradient illumination with azimuth 45 degree
gmt grdgradient Surface_MT.nc -GSurface_MT.int -A0/45 -Ne1 -fg
# Step-10. Make raster image
gmt grdimage Surface_MT.nc -CsurfaceMT.cpt -R120/160/5/30 -JM6i -P -ISurface_MT.int -Xc -K > $ps
# Step-11. Add grid
gmt psbasemap -R -J \
    -Bpxg6f2a2 -Bpyg6f1a2 -Bsxg2 -Bsyg2 \
    -B+t"Surface modelling of the topography along the Mariana Trench" -O -K >> $ps
# Step-12. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.2c \
    -Tdx0.8c/9.0c+w0.3i+f2+l+o0.0c \
    -Lx5.3i/-0.5i+c50+w600k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-13. Add color legend
gmt psscale -R -J -CsurfaceMT.cpt \
    -Dg120/4+w10.0c/0.4c+v+o-1.8/0.2c+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Surface topographic model color scale" \
    -I0.2 -By+lm -O -K >> $ps
# Step-14. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-15. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y2.2c -N -O \
    -F+f9p,Palatino-Roman,black+jLB >> $ps << EOF
1.2 13.7 Modelling: GMT surface module, tension factor of the continuous curvature splines 0.25
0.5 13.2 Input raw table data: global 1-min grid resolution in ASCII XYZ-format, applied blockmean filter.
1.0 12.7 Output spatial model: 30-sec grid spacing in netCDF format, shading azimuth gradient: 45\232
EOF
# Step-16. Convert to image file using GhostScript
gmt psconvert SurfaceTMT.ps -A0.2c -E720 -P -Tj -Z
