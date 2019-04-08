#!/bin/bash
# Thomas Reerink
#
# This scripts needs four or five arguments
#
# ${1} the first   argument is the MIP name
# ${2} the second  argument is the experiment name or MIP name in the latter case all MIP experiments are taken.
# ${3} the third   argument is the ec-earth model configuration
# ${4} the fourth  argument is the meta data template json file which is used as input, the file: resources/metadata-templates/cmip6-CMIP-piControl-metadata-template.json
# ${5} the fifth   argument is the meta data template json file which is created as output by this script.
# ${6} the first   argument is the component, e.g.: ifs, nemo, tm5, lpjg or pism.
#
#
# Run example:
#  ./modify-metadata-template.sh CMIP piControl 1 1
#
# With this script it is possible 
#
# This script is part of the subpackage genecec (GENerate EC-Eearth Control output files)
# which is part of ece2cmor3.
#
# Note that this script is called in a loop over the MIP experiments by the script:
#  genecec.py

if [ "$#" -eq 5 ] || [ "$#" -eq 6 ]; then
#if [ "$#" -eq 5 ]; then
 mip=$1
 experiment=$2
 ececonf=$3
 input_template=$4
 output_template=$5
 component=$6
 
 echo
 echo ${mip}
 echo ${experiment}
 echo ${ececonf}
 echo ${input_template}
 echo ${output_template}
 if [ "$#" -eq 6 ]; then
  echo ${component}
 fi
 echo


 if [ "${ececonf}" != 'EC-EARTH-AOGCM' ] && [ "${ececonf}" != 'EC-EARTH-HR' ] && [ "${ececonf}" != 'EC-EARTH-LR' ] && [ "${ececonf}" != 'EC-EARTH-CC' ] && [ "${ececonf}" != 'EC-EARTH-GrisIS' ] && [ "${ececonf}" != 'EC-EARTH-AerChem' ] && [ "${ececonf}" != 'EC-EARTH-Veg' ] && [ "${ececonf}" != 'EC-EARTH-Veg-LR' ]; then
  echo ' Error in ' $0 ': unkown ec-earth configuration: '  ${ececonf}
  exit
 fi

 if [ "$#" -eq 6 ]; then
  if [ "${component}" != 'ifs' ] && [ "${component}" != 'nemo' ] && [ "${component}" != 'tm5' ] && [ "${component}" != 'lpjg' ] && [ "${component}" != 'pism' ]; then
   echo ' Error in ' $0 ': unkown ec-earth component: '  ${component} '  Valid options: ifs, nemo, tm5, lpjg or pism'
   exit
  fi
 fi

 #                    name in script                             ece conf name       ifs res     nemo res      tm5 res     lpjg res   pisces res  pism res    source_type

 if [ "${ececonf}" = 'EC-EARTH-AOGCM'   ]; then declare -a arr=('EC-Earth3'          'T255L91'  'ORCA1L75'    'none'       'none'     'none'      'none'      'AOGCM'                    ); fi
 if [ "${ececonf}" = 'EC-EARTH-HR'      ]; then declare -a arr=('EC-Earth3-HR'       'T511L91'  'ORCA025L75'  'none'       'none'     'none'      'none'      'AOGCM'                    ); fi
 if [ "${ececonf}" = 'EC-EARTH-LR'      ]; then declare -a arr=('EC-Earth3-LR'       'T159L91'  'ORCA1L75'    'none'       'none'     'none'      'none'      'AOGCM'                    ); fi
 if [ "${ececonf}" = 'EC-EARTH-CC'      ]; then declare -a arr=('EC-Earth3-CC'       'T255L91'  'ORCA1L75'    '3 x 2 deg'  'T255L91'  'ORCA1L75'  'none'      'AOGCM BGC AER?CHEM LAND?' ); fi
 if [ "${ececonf}" = 'EC-EARTH-GrisIS'  ]; then declare -a arr=('EC-Earth3-GrIS'     'T255L91'  'ORCA1L75'    'none'       'none'     'none'      '5 x 5 km'  'AOGCM ISM'                ); fi
 if [ "${ececonf}" = 'EC-EARTH-AerChem' ]; then declare -a arr=('EC-Earth3-AerChem'  'T255L91'  'ORCA1L75'    '3 x 2 deg'  'none'     'none'      'none'      'AOGCM AER CHEM'           ); fi
 if [ "${ececonf}" = 'EC-EARTH-Veg'     ]; then declare -a arr=('EC-Earth3-Veg'      'T255L91'  'ORCA1L75'    'none'       'T255L91'  'none'      'none'      'AOGCM LAND'               ); fi
 if [ "${ececonf}" = 'EC-EARTH-Veg-LR'  ]; then declare -a arr=('EC-Earth3-Veg-LR'   'T159L91'  'ORCA1L75'    'none'       'T159L91'  'none'      'none'      'AOGCM LAND'               ); fi


 if [ "$#" -eq 6 ]; then
  if [ "${component}" = 'ifs' ]; then
   grid_label='gr'
  elif [ "${component}" = 'nemo' ]; then
   grid_label='gn'
  elif [ "${component}" = 'tm5' ]; then
   grid_label='gr'
  elif [ "${component}" = 'lpjg' ]; then
   grid_label='gr'
  elif [ "${component}" = 'pism' ]; then
   grid_label='gn'
  fi
 fi


 # Creating and adjusting with sed the output meta data template json file:
 sed    's/"activity_id":                  "CMIP"/"activity_id":                  "'${mip}'"/' ${input_template} >   ${output_template}
 sed -i 's/"experiment_id":                "piControl"/"experiment_id":                "'${experiment}'"/'           ${output_template}
 sed -i 's/"source_id":                    "EC-Earth3"/"source_id":                    "'${arr[0]}'"/'               ${output_template}
 sed -i 's/"source":                       "EC-Earth3 (2019)"/"source":                       "'${arr[0]}'" (2019)/' ${output_template}  # The 2019 is correct as long no P verison from 2017 is taken.
 sed -i 's/"source_type":                  "AOGCM"/"source_type":                  "'"${arr[7]}"'"/'                 ${output_template}  # Note the double quote for the spaces in the variable
 sed -i 's/"grid":                         "T255L91"/"grid":                         "'${arr[1]}'"/'                 ${output_template}
 sed -i 's/"grid_label":                   "gr"/"grid_label":                   "'${grid_label}'"/'                  ${output_template}
#sed -i 's/"nominal_resolution":           "100 km"/"nominal_resolution":           "'${arr[1]}'"/'                  ${output_template}

 for i in "${arr[@]}"
 do
    echo "$i"
 done

else
    echo '  '
    echo '  This scripts requires  variable, e.g.:'
    echo '  ' $0 CMIP piControl EC-EARTH-AOGCM cmip6-CMIP-piControl-metadata-template.json try.json
    echo '  '
fi



#  "AER":"aerosol treatment in an atmospheric model where concentrations are calculated based on emissions, transformation, and removal processes (rather than being prescribed or omitted entirely)",
#  "AGCM":"atmospheric general circulation model run with prescribed ocean surface conditions and usually a model of the land surface",
#  "AOGCM":"coupled atmosphere-ocean global climate model, additionally including explicit representation of at least the land and sea ice",
#  "BGC":"biogeochemistry model component that at the very least accounts for carbon reservoirs and fluxes in the atmosphere, terrestrial biosphere, and ocean",
#  "CHEM":"chemistry treatment in an atmospheric model that calculates atmospheric oxidant concentrations (including at least ozone), rather than prescribing them",
#  "ISM":"ice-sheet model that includes ice-flow",
#  "LAND":"land model run uncoupled from the atmosphere",

#       "source_type":{
#           "AER":"aerosol treatment in an atmospheric model where concentrations are calculated based on emissions, transformation, and removal processes (rather than being prescribed or omitted entirely)",
#           "AGCM":"atmospheric general circulation model run with prescribed ocean surface conditions and usually a model of the land surface",
#           "AOGCM":"coupled atmosphere-ocean global climate model, additionally including explicit representation of at least the land and sea ice",
#           "BGC":"biogeochemistry model component that at the very least accounts for carbon reservoirs and fluxes in the atmosphere, terrestrial biosphere, and ocean",
#           "CHEM":"chemistry treatment in an atmospheric model that calculates atmospheric oxidant concentrations (including at least ozone), rather than prescribing them",
#           "ISM":"ice-sheet model that includes ice-flow",
#           "LAND":"land model run uncoupled from the atmosphere",
#           "OGCM":"ocean general circulation model run uncoupled from an AGCM but, usually including a sea-ice model",
#           "RAD":"radiation component of an atmospheric model run 'offline'",
#           "SLAB":"slab-ocean used with an AGCM in representing the atmosphere-ocean coupled system"
#       },
#       "frequency":{
#           "1hr":"sampled hourly",
#           "1hrCM":"monthly-mean diurnal cycle resolving each day into 1-hour means",
#           "1hrPt":"sampled hourly, at specified time point within an hour",
#           "3hr":"sampled every 3 hours",
#           "3hrPt":"sampled 3 hourly, at specified time point within the time period",
#           "6hr":"sampled every 6 hours",
#           "6hrPt":"sampled 6 hourly, at specified time point within the time period",
#           "day":"daily mean samples",
#           "dec":"decadal mean samples",
#           "fx":"fixed (time invariant) field",
#           "mon":"monthly mean samples",
#           "monC":"monthly climatology computed from monthly mean samples",
#           "monPt":"sampled monthly, at specified time point within the time period",
#           "subhrPt":"sampled sub-hourly, at specified time point within an hour",
#           "yr":"annual mean samples",
#           "yrPt":"sampled yearly, at specified time point within the time period"
#       },
#       "grid_label":{
#           "gm":"global mean data",
#           "gn":"data reported on a model's native grid",
#           "gna":"data reported on a native grid in the region of Antarctica",
#           "gng":"data reported on a native grid in the region of Greenland",
#           "gnz":"zonal mean data reported on a model's native latitude grid",
#           "gr":"regridded data reported on the data provider's preferred target grid",
#           "gr1":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr1a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr1g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr1z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr2":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr2a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr2g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr2z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr3":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr3a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr3g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr3z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr4":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr4a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr4g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr4z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr5":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr5a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr5g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr5z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr6":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr6a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr6g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr6z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr7":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr7a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr7g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr7z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr8":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr8a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr8g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr8z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gr9":"regridded data reported on a grid other than the native grid and other than the preferred target grid",
#           "gr9a":"regridded data reported in the region of Antarctica on a grid other than the native grid and other than the preferred target grid",
#           "gr9g":"regridded data reported in the region of Greenland on a grid other than the native grid and other than the preferred target grid",
#           "gr9z":"regridded zonal mean data reported on a grid other than the native latitude grid and other than the preferred latitude target grid",
#           "gra":"regridded data in the region of Antarctica reported on the data provider's preferred target grid",
#           "grg":"regridded data in the region of Greenland reported on the data provider's preferred target grid",
#           "grz":"regridded zonal mean data reported on the data provider's preferred latitude target grid"
#       },
#       "nominal_resolution":[
#           "0.5 km",
#           "1 km",
#           "10 km",
#           "100 km",
#           "1000 km",
#           "10000 km",
#           "1x1 degree",
#           "2.5 km",
#           "25 km",
#           "250 km",
#           "2500 km",
#           "5 km",
#           "50 km",
#           "500 km",
#           "5000 km"
