#!/bin/bash
# Thomas Reerink
#
# This scripts needs four or five arguments
#
# ${1} the first   argument is the MIP name
# ${2} the second  argument is the experiment name or MIP name in the latter case all MIP experiments are taken.
# ${3} the third   argument is the experiment tier (tier 1 is obligatory, higher tier is non-obligatory). In case tier 2 is specified, tier 1 and 2 experiments are considered.
# ${4} the fourth  argument is the maximum priority of the variables (1 is highest priority, 3 is lowest priority). In case priority 2 is specified, priority 1 and 2 variables are considered.
# ${5} the fifth   OPTIONAL argument will omit the install of the ece2cmor setup if equal to "omit-setup". To improve the performance when calling this script multiple times from another script.
#
#
# Run example:
#  ./generate-ec-earth-namelists.sh CMIP piControl 1 1
#
# With this script it is possible to generate the EC-Earth3 control output files, i.e.
# the IFS Fortran namelists (the ppt files) and the NEMO xml files for XIOS (the
# file_def files for OPA, LIM and PISCES) for one MIP experiment.
#
# This script is part of the subpackage genecec (GENerate EC-Eearth Control output files)
# which is part of ece2cmor3.
#
# Note that this script is called in a loop over the MIP experiments by the script:
#  genecec.py


# Set the root directory of ece2cmor3 (default ${HOME}/cmorize/ece2cmor3/ ):
ece2cmor_root_directory=${HOME}/cmorize/ece2cmor3/

# Test whether the ece2cmor_root_directory exists:
if [ ! -d ${ece2cmor_root_directory} ]; then 
 echo
 echo ' The root directory of ece2cmor3: ' ${ece2cmor_root_directory} ' is not found.'
 echo ' Adjust the ece2cmor_root_directory at line 19 of the script: ' $0
 echo ' Stop'
 exit
 echo
fi

if [ "$#" -eq 4 ] || [ "$#" -eq 5 ]; then
 mip=$1
 experiment=$2
 tier=$3
 priority=$4

 # Check whether more than one MIP is specified in the data request
 multiplemips='no'
 if [[ ${mip} == *","* ]];then
  multiplemips='yes'
  echo ' Multiple mip case = ' ${multiplemips}
 fi

 # Replace , by dot in label:
 mip_label=$(echo ${mip} | sed 's/,/./g')
#echo ' mip =' ${mip} '    experiment =' ${experiment} '    mip_label =' ${mip_label}
#echo "${mip_label}" | tr '[:upper:]' '[:lower:]'

 if [ "${multiplemips}" == "yes" ]; then
  # The first two lower case characters of the multiple mip string are saved for selecting the experiment data request file:
  select_substring=$(echo "${mip_label:0:2}" | tr '[:upper:]' '[:lower:]')
 else
  select_substring=${mip}
 fi
 echo ${select_substring}

 install_setup="include-setup"
 if [ "$#" -eq 5 ]; then
  if [ "$5" = "omit-setup" ]; then
   install_setup="omit-setup"
  fi
 fi

 # Replace , by dot in label:
 mip_label=$(echo ${mip} | sed 's/,/./g')

#path_of_created_output_control_files=cmip6-output-control-files/${mip_label}/cmip6-experiment-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}
#path_of_created_output_control_files=cmip6-output-control-files/${mip_label}/cmip6-experiment-m=${mip_label}-e=${experiment}-p=${priority}
#path_of_created_output_control_files=cmip6-output-control-files/${mip_label}/cmip6-experiment-m=${mip_label}-e=${experiment}
 path_of_created_output_control_files=cmip6-output-control-files/${mip_label}/cmip6-experiment-${mip_label}-${experiment}

#activateanaconda
 if ! type "drq" > /dev/null; then
  echo
  echo ' The CMIP6 data request tool drq is not available because of one of the following reasons:' 
  echo '  1. drq might be not installed'
  echo '  2. drq might be not active, as the anaconda environment is not activated'
  echo ' Stop'
  echo
  exit
 else
 #source activate ece2cmor3
  if [ "${install_setup}" = "include-setup" ]; then
   cd ${ece2cmor_root_directory}; python setup.py install; cd -;
  else
   echo "Omit python setup.py install"
  fi
  echo
  echo 'Executing the following job:'
  echo ' '$0 "$@"
  echo
  echo 'First, the CMIP6 data request is applied by:'
  echo ' ' drq -m ${mip} -e ${experiment} -t ${tier} -p ${priority} --xls --xlsDir cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}
  echo

  mkdir -p ${ece2cmor_root_directory}/ece2cmor3/scripts/cmip6-data-request/; cd ${ece2cmor_root_directory}/ece2cmor3/scripts/cmip6-data-request/;
  drq -m ${mip} -e ${experiment} -t ${tier} -p ${priority} --xls --xlsDir cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}
  cd ${ece2cmor_root_directory}/ece2cmor3/scripts/
  # Note that the *TOTAL* selection below has the risk that more than one file is selected (causing a crash) which only could happen if externally files are added in this directory:

  # Check wheter there will be selected a unique matching data request file in the created data request directory:
  number_of_matching_files=$(ls -1 cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx|wc -l)
  if [ ${number_of_matching_files} != 1 ]; then
   echo 'Number of matching files: ' ${number_of_matching_files}
   ls cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx
   exit
  fi

  ./drq2ppt.py --vars cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx

  mkdir -p ${path_of_created_output_control_files}/file_def-compact
  if [ -f pptdddddd-100 ]; then rm -f pptdddddd-100 ; fi
  mv -f ppt0000000000 pptdddddd* ${path_of_created_output_control_files}

  # Creating the file_def files for XIOS NEMO input:
  ./drq2file_def-nemo.py --vars cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx
  mv -f ./xios-nemo-file_def-files/cmip6-file_def_nemo.xml          ${path_of_created_output_control_files}
  mv -f ./xios-nemo-file_def-files/file_def_nemo-opa.xml            ${path_of_created_output_control_files}
  mv -f ./xios-nemo-file_def-files/file_def_nemo-lim3.xml           ${path_of_created_output_control_files}
  mv -f ./xios-nemo-file_def-files/file_def_nemo-pisces.xml         ${path_of_created_output_control_files}
  mv -f ./xios-nemo-file_def-files/file_def_nemo-opa-compact.xml    ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-opa.xml
  mv -f ./xios-nemo-file_def-files/file_def_nemo-lim3-compact.xml   ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-lim3.xml
  mv -f ./xios-nemo-file_def-files/file_def_nemo-pisces-compact.xml ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-pisces.xml

  # Estimating the Volume of the TM5 output:
  ./estimate-tm5-volume.py --vars cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx

  # Creating the instruction files for LPJ-GUESS and estimating the Volume of the LPJ-GUESS output:
  ./drq2ins.py --vars cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx
  mv -f ./lpjg_cmip6_output.ins                                     ${path_of_created_output_control_files}

  cat volume-estimate-ifs.txt volume-estimate-nemo.txt volume-estimate-tm5.txt volume-estimate-lpj-guess.txt > ${path_of_created_output_control_files}/volume-estimate-${mip_label}-${experiment}.txt
  rm -f volume-estimate-ifs.txt volume-estimate-nemo.txt volume-estimate-tm5.txt volume-estimate-lpj-guess.txt

  echo
  echo 'The produced data request excel file:'
  ls -1 cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx

  echo
  echo 'The generated ppt files are:'
  ls -1 ${path_of_created_output_control_files}/ppt0000000000
  ls -1 ${path_of_created_output_control_files}/pptdddddd0300
  ls -1 ${path_of_created_output_control_files}/pptdddddd0600

  echo
  echo 'The generated file_def files are:'
  ls -1 ${path_of_created_output_control_files}/cmip6-file_def_nemo.xml
  ls -1 ${path_of_created_output_control_files}/file_def_nemo-opa.xml
  ls -1 ${path_of_created_output_control_files}/file_def_nemo-lim3.xml
  ls -1 ${path_of_created_output_control_files}/file_def_nemo-pisces.xml
  ls -1 ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-opa.xml
  ls -1 ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-lim3.xml
  ls -1 ${path_of_created_output_control_files}/file_def-compact/file_def_nemo-pisces.xml

  echo
  echo 'The estimate of the Volumes:'
  ls -1 ${path_of_created_output_control_files}/volume-estimate-${mip_label}-${experiment}.txt

  # Generating the available, ignored, identified missing and missing files for this MIP experiment:
 #./checkvars.py -v --vars cmip6-data-request/cmip6-data-request-m=${mip_label}-e=${experiment}-t=${tier}-p=${priority}/cmvme_${select_substring}*${experiment}_${tier}_${priority}.xlsx  --output cmvmm_e=${mip_label}-e=${experiment}-t=${tier}-p=${priority}

  echo
 #source deactivate
 fi

else
    echo '  '
    echo '  This scripts requires four arguments: MIP, MIP experiment, experiment tier, priority of variable, e.g.:'
    echo '  ' $0 CMIP piControl 1 1
    echo '  or with the fifth optional arument the "python setup.py install" is omitted:'
    echo '  ' $0 CMIP piControl 1 1 omit-setup
    echo '  '
fi

# ./generate-ec-earth-namelists.sh CMIP         1pctCO2      1 1
# ./generate-ec-earth-namelists.sh CMIP         abrupt-4xCO2 1 1
# ./generate-ec-earth-namelists.sh CMIP         amip         1 1
# ./generate-ec-earth-namelists.sh CMIP         historical   1 1
# ./generate-ec-earth-namelists.sh CMIP         piControl    1 1

# ./generate-ec-earth-namelists.sh AerChemMIP   piControl 1 1
# ./generate-ec-earth-namelists.sh CDRMIP       piControl 1 1
# ./generate-ec-earth-namelists.sh C4MIP        piControl 1 1
# ./generate-ec-earth-namelists.sh DCPP         piControl 1 1
# ./generate-ec-earth-namelists.sh HighResMIP   piControl 1 1
# ./generate-ec-earth-namelists.sh ISMIP6       piControl 1 1
# ./generate-ec-earth-namelists.sh LS3MIP       piControl 1 1
# ./generate-ec-earth-namelists.sh LUMIP        piControl 1 1
# ./generate-ec-earth-namelists.sh OMIP         piControl 1 1
# ./generate-ec-earth-namelists.sh PAMIP        piControl 1 1
# ./generate-ec-earth-namelists.sh PMIP         piControl 1 1
# ./generate-ec-earth-namelists.sh RFMIP        piControl 1 1
# ./generate-ec-earth-namelists.sh ScenarioMIP  piControl 1 1
# ./generate-ec-earth-namelists.sh VolMIP       piControl 1 1
# ./generate-ec-earth-namelists.sh CORDEX       piControl 1 1
# ./generate-ec-earth-namelists.sh DynVar       piControl 1 1
# ./generate-ec-earth-namelists.sh SIMIP        piControl 1 1
# ./generate-ec-earth-namelists.sh VIACSAB      piControl 1 1