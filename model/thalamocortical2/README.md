# thalamocortical2
Large-scale thalamocortical network model for simulating physiological and paroxysmal brain rhythms (4-7 Hz spike and wave discharges) described in manuscripts:

Dervinis, M and Crunelli, V (2023) Sleep waves in a large-scale corticothalamic model constrained by activities intrinsic to neocortical networks and single thalamic neurons. bioRxiv 2022.10.31.514504; doi: https://doi.org/10.1101/2022.10.31.514504

Dervinis, M and Crunelli, V (2023) Spike-and-wave discharges of absence seizures in a sleep waves-constrained corticothalamic model. bioRxiv 2022.10.31.514510; doi: https://doi.org/10.1101/2022.10.31.514510

The main file is ```init.hoc```

Language: Neuron

Major points:
- Executing the init.hoc file on Neuron with all the parameters set up as it is currently, would produce 20 minutes of simulated neural activity resembling wakefulness. The data is saved in DAT files corresponding to individual cell models in the network. The files contain time, voltage, and synaptic current data.
- In order to obtain simulations of physiological network sleep oscillations, adjust the ```state``` variable in the file ```init.hoc```.
- To get pure cortical simulations, set variables isFO and isHO to zero in the file ThCxprocs.hoc.
- To obtain SWDs induced by the hyperpolarisation of thalamocortical (TC) cells, set the ```state``` variable inside the ```init.hoc``` file to ```'SWDs_long'```.
- To obtain SWDs induced by tonic GABAa inhibition of TC cells, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'``` and adjust variable ```GABAfullsyn.gbar_c``` on line 698 inside the ```TCcell.hoc``` file.
- To obtain SWDs induced by the decrease in the cortical GABAa current, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'``` and adjust variable ```GABAsyn.gbar_a``` on line 693 inside the ```Cx3cell.hoc``` file.
- To obtain SWDs induced by the increase in the cortical AMPA current, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'``` and adjust variable ```GLUsyn.gbar_a``` on line 622 inside the ```Cx3cell.hoc``` file.
- To obtain SWDs induced following the introduction of strongly intrinsically bursting cells in deep cortical layers, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'```, comment out lines 12 and 15, and uncomment lines 13 and 16 in the file ```Cx.hoc```.
- To obtain SWDs induced by the increase in the T-type calcium current in NRT cells, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'``` and adjust variable ```gcabar_its``` on line 333 inside the ```NRTcell.hoc``` file.
- To obtain SWDs induced by the increase in the T-type calcium current in the higher order TC cells, set the ```state``` variable inside the ```init.hoc``` file to ```'awake_long'``` and adjust variable ```gcabar_it``` on line 236 inside the ```TCcell.hoc``` file.
- The repository also contains Matlab files used to analyse the simulated data. The main files are ```coherenceAnalysis.m```, ```coherenceAnalysis2.m```, ```coherenceAnalysis4.m```, ```compareSync.m```, ```summaryFigs.m```, and ```frFractions.m```.
- For other issues, consult the manuscripts.
