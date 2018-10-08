#!/usr/bin/env python
# Thomas Reerink
#
# Run example:
#  python generate-ec-earth-namelists-for-all-MIP-experiments.py
#
# Looping over all MIPs and within each MIP over all its MIP experiments.
# The experiment tier can be selected. For each selected experiment the
# namelists are created by calling the generate-ec-earth-namelists.sh script.
#

import sys
import os
from dreqPy import dreq
dq = dreq.loadDreq()

# Specify which tier experiments should be included:
experiment_tiers_included = 1
#ec_earth_mips = ['CMIP'] # for basic test
ec_earth_mips = ['CMIP', 'DCPP']
#ec_earth_mips = ['CMIP', 'AerChemMIP', 'C4MIP',          'DAMIP', 'DCPP',                              'HighResMIP', 'ISMIP6', 'LS3MIP', 'LUMIP',         'PAMIP', 'PMIP', 'RFMIP', 'ScenarioMIP', 'VolMIP', 'CORDEX', 'DynVar', 'SIMIP', 'VIACSAB'] # All 18 EC-Earth MIPs
#ec_earth_mips = ['CMIP', 'AerChemMIP', 'C4MIP', 'CFMIP', 'DAMIP', 'DCPP', 'FAFMIP', 'GeoMIP', 'GMMIP', 'HighResMIP', 'ISMIP6', 'LS3MIP', 'LUMIP', 'OMIP', 'PAMIP', 'PMIP', 'RFMIP', 'ScenarioMIP', 'VolMIP', 'CORDEX', 'DynVar', 'SIMIP', 'VIACSAB'] # All 23 CMIP6 MIPs
experiment_counter = 0


command_0 = 'rm -rf cmip6-output-control-files'
os.system(command_0)

# Loop over MIPs:
for mip in dq.coll['mip'].items:
  # Loop over experiments:
  for u in dq.inx.iref_by_sect[mip.uid].a['experiment']:
    ex = dq.inx.uid[u]
    if ex.label == 'esm-hist' or ex.label == 'esm-piControl':
     print 'Skipping this esm experiment ' + ex.label + ' because its CMIP6 data request fails so far.\n'
    else:
     if experiment_counter == 0:
       command = './generate-ec-earth-namelists.sh ' + mip.label + ' ' + ex.label + ' ' + str(ex.tier[0]) + ' 1'
     else:
       command = './generate-ec-earth-namelists.sh ' + mip.label + ' ' + ex.label + ' ' + str(ex.tier[0]) + ' 1 omit-setup'
     command_2 = 'rm -rf cmip6-output-control-files/' + mip.label + '/cmip6-experiment-*/file_def-compact'
     command_3 = 'rm -f  cmip6-output-control-files/' + mip.label + '/cmip6-experiment-*/cmip6-file_def_nemo.xml'
     command_4 = "sed -i -e 's/True\" field_ref=\"toce_pot\"/False\" field_ref=\"toce_pot\"/' cmip6-output-control-files/" + mip.label + '/cmip6-experiment-' + mip.label + '-' + ex.label + '/file_def_nemo-opa.xml'
     command_5 = "sed -i -e '/sfdsi_2/d' cmip6-output-control-files/" + mip.label + '/cmip6-experiment-' + mip.label + '-' + ex.label + '/file_def_nemo-opa.xml'
    #command_4 = "sed -i -e 's/True\" field_ref=\"toce_pot\"/False\" field_ref=\"toce_pot\"/' cmip6-output-control-files/" + mip.label + '/cmip6-experiment-m=' + mip.label + '-e=' + ex.label + '-t=' + str(ex.tier[0]) + '-p=1/file_def_nemo-opa.xml'
    #command_5 = "sed -i -e '/sfdsi_2/d' cmip6-output-control-files/" + mip.label + '/cmip6-experiment-m=' + mip.label + '-e=' + ex.label + '-t=' + str(ex.tier[0]) + '-p=1/file_def_nemo-opa.xml'
    #print print '{}'.format(command)
     if mip.label in ec_earth_mips: 
       #if ex.tier[0] == experiment_tiers_included and mip.label in ec_earth_mips and ex.label == 'piControl':  # for basic test
        if ex.tier[0] == experiment_tiers_included and mip.label in ec_earth_mips: 
           os.system(command)
           os.system(command_2) # Remove the file_def-compact subdirectory with the compact file_def files
           os.system(command_3) # Remove the cmip6-file_def_nemo.xml file
          #os.system(command_4) # Just set the toce fields false again because we still face troubles with them
          #os.system(command_5) # Delete the line with sfdsi_2 from the file_def_nemo-opa.xml files
           experiment_counter = experiment_counter + 1
        else:
           print ' Tier {:2} experiments are not included: Skipping: {}'.format(ex.tier[0], command)
     else:
        print ' EC-Earth3 does not participate in {:2}: Skipping: {}'.format(mip.label, command)


print ' There are {} experiments included. '.format(experiment_counter)

# Add a test case with which all available variables over all EC-Earth MIP experiments are switched on,
# i.e. are enabled in the file_def files:
command_a = "cp -r cmip6-output-control-files/CMIP/cmip6-experiment-CMIP-piControl/ cmip6-output-control-files/test-all-mips/"
command_b = "sed -i 's/enabled=\"False\"/enabled=\"True\"/' cmip6-output-control-files/test-all-mips/file_def_nemo-*"
os.system(command_a)
os.system(command_b)
