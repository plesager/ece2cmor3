#!/bin/bash
#
# This script can not be executed, because a few manual editting steps are required.
#
# Run example:
#  ./update-basic-identifiedmissing-ignored-files.sh
#

if [ "$#" -eq -2 ]; then

# Procedure to produce the list-of-identified-missing-cmpi6-requested-variables.xlsx based on the most updated shaconemo ping files.
# In this way the variable and table can be provided in the list-of-identified-missing-cmpi6-requested-variables.xlsx while at the
# other hand shaconemo updates can be relatively easy followed by copying the entire variable column. In order to catch all provided
# (non dummy) variables from the shaconemo ping files, we use the total CMIP6 request for all CMIP6 MIPs with highest tier and priority.

# Step 1: request all CMIP6 MIPs for most extended tier and priority:
  cd ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/; 
  drq -m CMIP,AerChemMIP,CDRMIP,C4MIP,CFMIP,DAMIP,DCPP,FAFMIP,GeoMIP,GMMIP,HighResMIP,ISMIP6,LS3MIP,LUMIP,OMIP,PAMIP,PMIP,RFMIP,ScenarioMIP,VolMIP,CORDEX,DynVarMIP,SIMIP,VIACSAB -e CMIP -t 3 -p 3 --xls --xlsDir xls-m=all-cmip6-mips-e=CMIP-t=3-p=3

# Step 2: update the Shaconemo repository and thus the ping files:
  cd ${HOME}/cmorize/shaconemo/ping-files/
  ./extract-info-from-ping-files.csh

# # Step 3: Manually select the entire column of variables in the first file and the entire comment from the second file:
#   nedit r274/cmor-varlist-based-on-ping-r274-without-dummy-lines.txt r274/cmor-varlist-based-on-ping-r274-without-dummy-lines-comment2.txt &
# # and copy them manually into the variable and comment column respectively (and update the comment author column) in the file:
#   xdg-open ${HOME}/cmorize/ece2cmor3/ece2cmor3/resources/pre-list-of-identified-missing-cmpi6-requested-variables.xlsx
# # After updating the pre* files it is most convenient to commit them first.

  cd ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/; 
  nedit generate-nemopar.json.sh ../resources/nemopar.json &
# and copy (as described in generate-nemopar.json.sh) the result of:
  more ${HOME}/cmorize/shaconemo/ping-files/r274/cmor-varlist-based-on-ping-r274-without-dummy-lines.txt | sed -e 's/^/"/'  -e 's/$/"/' > tmp-nemopar-list.txt
# into the "arr" list of generate-nemopar.json.sh. Therafter run generate-nemopar.json.sh:
  ./generate-nemopar.json.sh new-nemopar.json
  diff new-nemopar.json ../resources/nemopar.json
  mv -f new-nemopar.json ../resources/nemopar.json
  git diff ../resources/nemopar.json

# Step 4: Temporary overwrite the basic identifiedmissing and basic ignored files by their corresponding pre-* ones:
  cpf ${HOME}/cmorize/ece2cmor3/ece2cmor3/resources/pre-list-of-identified-missing-cmpi6-requested-variables.xlsx             ${HOME}/cmorize/ece2cmor3/ece2cmor3/resources/list-of-identified-missing-cmpi6-requested-variables.xlsx
  cpf ${HOME}/cmorize/ece2cmor3/ece2cmor3/resources/pre-list-of-ignored-cmpi6-requested-variables.xlsx                        ${HOME}/cmorize/ece2cmor3/ece2cmor3/resources/list-of-ignored-cmpi6-requested-variables.xlsx

# Step 5: Run with the --withouttablescheck option checkvars.py based on the largest data request (and the pre-list-*.xlsx):
   cd ${HOME}/cmorize/ece2cmor3/; python setup.py develop; cd -;
   cd ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts;
   ./checkvars.py --withouttablescheck -v --drq  xls-m=all-cmip6-mips-e=CMIP-t=3-p=3/cmvmm_ae.c4.cd.cf.cm.co.da.dc.dy.fa.ge.gm.hi.is.ls.lu.om.pa.pm.rf.sc.si.vi.vo_TOTAL_3_3.xlsx  --output cmvmm-all-mips-t=3-p=3
#  xdg-open cmvmm-all-mips-t=3-p=3.identifiedmissing.xlsx
#  xdg-open cmvmm-all-mips-t=3-p=3.ignored.xlsx

# Step 6: Copy the resulting identifiedmissing and ignored produced by the checkvars.py to the basic identifiedmissing and the basic ignored:
   cpf cmvmm-all-mips-t=3-p=3.identifiedmissing.xlsx ../resources/list-of-identified-missing-cmpi6-requested-variables.xlsx
   cpf cmvmm-all-mips-t=3-p=3.ignored.xlsx           ../resources/list-of-ignored-cmpi6-requested-variables.xlsx

# Note that in order to create the basic lists from the pre basic fields, the variables in the pre basic lists are matched against the data request by drq in 
# step 1 here, which includes all EC-Earth MIPs for the Core MIP experiments, however this does not include the endorsed MIP experiments (e.g drq -m LS3MIP -e LS3MIP ).
# Therefore the identified missing and ignored variables coming from the endorsed MIP experiments have to be added manually to the basic lists:
#  -Note copying using the "Paste Special..." before saving in microsoft format allows correct copying of the links.
#  -Move Antarctic IfxAnt, and ImonAnt variables               from list-of-identified-missing-cmpi6-requested-variables.xlsx manually to the list-of-ignored-cmpi6-requested-variables.xlsx and adjust the comment.
#  -Move CFsubhr AerChemMIP variables (one block of variables) from list-of-identified-missing-cmpi6-requested-variables.xlsx manually to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the IyrGre ISMIP6 (step 3) variables modelCellAreai, sftgif and sftgrf     to the list-of-identified-missing-cmpi6-requested-variables.xlsx
#  -Add manually the Eday   LS3MIP nudgincsm, nudgincswe                                    to the list-of-identified-missing-cmpi6-requested-variables.xlsx
#  -Add manually the Emon    vtendogw,vtendnogw       (table 126)                           to the list-of-identified-missing-cmpi6-requested-variables.xlsx
#  -Add manually the EmonZ   vtendnogw,tntogw,tntnogw (table 126)                           to the list-of-identified-missing-cmpi6-requested-variables.xlsx
#  -Add manually the Emon, CF3hr & Esubhr reffclws combinations                             to the list-of-identified-missing-cmpi6-requested-variables.xlsx
#  -Add manually the       CF3hr & Esubhr reffclws combinations                             to the list-of-identified-missing-cmpi6-requested-variables-enable-pextra.xlsx
#  -Add manually the IyrAnt ISMIP6 (step 3) variables modelCellAreai, sftgif and sftgrf     to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Efx    RFMIP  (step 3) variables rlu, rsu, rld, rsd                    to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the 6hrPlevPt VolMIP (step 3) block (swtoafluxaerocs-lwtoafluxaerocs)      to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Eday   VolMIP (step 3) aod550volso4                                    to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Emon   ec550aer                                                        to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the E6hrZ  VolMIP (step 3) block (szmswaero--zmlwaero)                     to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Eday   LS3MIP (step 3) block of ignored variables (agesno--wtd)        to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Amon   phalf                                                           to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the CFsubhr cl--fco2nat--latitude block                                    to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the E3hr   gpp, ra, rh variables                                           to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Efx    thkcello and masscello                                          to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Eday   mrros                                                           to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the E3hrPt o3                                                              to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Amon   o3Clim, ch4Clim, ch4globalClim                                  to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the CFmon  tnt                                                             to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Esubhr tnt                                                             to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Esubhr tnhus                                                           to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Emon   fHarvestToProduct                                               to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the E3hr   prrc                                                            to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Eday   prrc                                                            to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the Omon   prra                                                            to the list-of-ignored-cmpi6-requested-variables.xlsx
#  -Add manually the E3hrPt rsutcsaf  #556                                                  to the list-of-ignored-cmpi6-requested-variables.xlsx

# Test that this replace gives still the same results:
   mkdir -p ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3; rm -f ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/cmvmm-all-mips-t=3-p=3.*;
   mv ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/cmvmm-all-mips-t=3-p=3.* ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/;
   cd ${HOME}/cmorize/ece2cmor3/; python setup.py install; cd -;
   cd ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts;
   ./checkvars.py -v --drq xls-m=all-cmip6-mips-e=CMIP-t=3-p=3/cmvmm_ae.c4.cd.cf.cm.co.da.dc.dy.fa.ge.gm.hi.is.ls.lu.om.pa.pm.rf.sc.si.vi.vo_TOTAL_3_3.xlsx  --output cmvmm-all-mips-t=3-p=3
# The diff is not identical but the excel-diff gives no cel differences:
   diff       ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/cmvmm-all-mips-t=3-p=3.identifiedmissing.txt  ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/cmvmm-all-mips-t=3-p=3.identifiedmissing.txt
   diff       ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/cmvmm-all-mips-t=3-p=3.ignored.txt            ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/cmvmm-all-mips-t=3-p=3.ignored.txt
#  excel-diff ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/cmvmm-all-mips-t=3-p=3.identifiedmissing.xlsx ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/cmvmm-all-mips-t=3-p=3.identifiedmissing.xlsx
#  excel-diff ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/cmvmm-all-mips-t=3-p=3.ignored.xlsx           ${HOME}/cmorize/ece2cmor3/ece2cmor3/scripts/backup-cmvmm-all-mips-t=3-p=3/cmvmm-all-mips-t=3-p=3.ignored.xlsx

# Note exel-diff is installed by following:
#   https://github.com/na-ka-na/ExcelCompare/blob/master/README.md
# Java is needed, on ubuntu this can be installed by: sudo apt update; sudo apt install -y default-jre
# Extract the zip and 
#  cd ${HOME}; mv Downloads/ExcelCompare-0.6.1 ${HOME}/bin; cd ${HOME}/bin/; chmod uog+x ExcelCompare-0.6.1/bin/excel_cmp; ln -s ExcelCompare-0.6.1/bin/excel_cmp excel-diff;


else
    echo '  '
    echo '  This script can not be executed, because a few manual editting steps are required.'
    echo '  This guidence servers to produce the basic identifiedmissing file and the basic ignored file.'
    echo '  '
fi
