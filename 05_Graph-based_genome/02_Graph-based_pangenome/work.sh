#!/bin/bash
#### Variation graph construction
ref=13C.fa
threads=12
spe=pan_SV
##vg
vg construct -S -a -f -v $vcf -r $ref  > ${spe}.vg
###xg ## store the graph in the xg/gcsa index pair
mkdir tmp
vg index -L -b tmp -t $threads -x ${spe}.xg ${spe}.vg
vg gbwt -d tmp -g ${spe}.gg -o ${spe}.gbwt -x ${spe}.xg -P
## snarls
vg snarls -t $threads --include-trivial ${spe}.xg > ${spe}.trivial.snarls
##GBWT with greedy path cover
vg index -b tmp -t $threads -j ${spe}.dist -s ${spe}.trivial.snarls  ${spe}.vg
vg minimizer -t $threads -i ${spe}.min -g ${spe}.gbwt -d ${spe}.dist ${spe}.xg
vg snarls -t $threads ${spe}.xg > ${spe}.snarls

