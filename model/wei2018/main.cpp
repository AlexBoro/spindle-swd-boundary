//Created by M.Bazhenov, 1997-2009
//All rights reserved
//Most recently edited by Peter Lonjers(just search the net if you need to find me)
//I added all the MPI stuff but don't know much about the bio
#include <omp.h>
#include "CellSyn.h"    //header for all classes describing currents and basic cell types
#include "io.h"
#include "network.h"
#include "protocol.h"
#include <vector>
#include "bmalgo.h"

int num_mp_threads; //number of openMP threads

int print_c_sten; // if 1 prints all the connection strengths for cx every once in awile note this only works with openmp
int fre_print_cs; // how often to print connection strengths(every how many milliseconds)
int total_rec; // used for debugging number of non normal messages received in a time step
int total_rec_norm; // used for debugging number of normal(basic spiking messages) messages received in a time step

string output_location; // keeps track of what folder to put outputs in

Homeostasis homeo;

//block size for openmp
int block_size = 13;

//boolean for if we are doing the very first step and send functions
int first_round = 1;
//main track of milliseconds of simulation so far. ii tracks steps of simulation locally
double t = 0;

//how long we run the simulation
double tmax;
//time at which we print information from all cells
double t3D;
//smaller time interval to print information from some cells
double ttime;
//how long main process runs for set in input
double run_time = 0;

double input_strength,input_start_neuron,input_end_neuron;

// number of types of cells
int Num_Types;
//gives the dimensions of the arrays of cells of each type
Pair *cell_sizes;
//total number of cells
int num_cells;
//total number of cells of each type
int *cell_numbers;
//cells info is an array of all cells containing the color of each cell and the numbers of different types of connections it has.
Cell_Info ****cells_info = NULL;
//array of all the pointers to cells belonging to this process
CellSyn **cells =NULL;

int *mapns, *hhns;

int mapi,hhi;

int one_state=0;
// (donor timeline globals test*_start ... stage3_end removed: see protocol.h)

/// CX neuron -gKl
double fac_gkl; 
double fac_gkl_TC; 
double fac_gkl_RE; 

double fac_gkv_cx; 
double fac_gkca_cx;
double fac_gkm_cx;

double fac_gh_TC;

double fac_AMPA_D2;
double fac_AMPA_TC;
double fac_GABA_D2;
double fac_GABA_TC;


//run for openMP
//all == whether both RK and MAP should be called at the same time
//the order is important in order to ensure signaling and receiveing spikes between different steps

void runMP(int all){
  int iter,i;
#pragma omp parallel  private(i,iter)  num_threads(num_mp_threads)
  {
    // Run step for maps
    if (all){
#pragma omp for schedule(dynamic, block_size)
      for(i=0; i<mapi; i++){
        cells[mapns[i]]->step();
      }
    }

    for(iter=0; iter<4; iter++){
#pragma omp for schedule(dynamic, block_size)
      for(i=0; i<hhi; i++){
        cells[hhns[i]]->step();
      }
    }

#pragma omp for schedule(dynamic, block_size)
    for(i=0; i<hhi; i++){
      cells[hhns[i]]->reset_y();
    }

    // Signal and/or reset spikes here
    if (all) {
#pragma omp for schedule(dynamic, block_size)
      for(i=0; i<mapi; i++) {
        //Reset flip for maps which should be consumed in this time step (used for HH->Map connection)
        cells[mapns[i]]->reset_flip_maps();
      }

#pragma omp for schedule(dynamic, block_size)
      for(i=0; i<hhi; i++) {
        cells[hhns[i]]->reset_flip_maps();
      }
    }

#pragma omp for schedule(dynamic, block_size)
    for(i=0; i<mapi; i++) {
      cells[mapns[i]]->signal_spike();
    }

#pragma omp for schedule(dynamic, block_size)
    for(i=0; i<hhi; i++) {
      cells[hhns[i]]->signal_spike();
    }


  }
}

//gets index for a particular cell in a group(cells on the same process)
int get_cell_index(int type, int m, int n){
  return cells_info[type][m][n]->cell_index;
}

//all arguments are inputs
//this functions decides what cells a process should simulate and starts them
void initialize_cells(CellSyn** &cells){
  int total=0;
  for(int x=0; x<Num_Types; x++)
    for(int y=0; y<cell_sizes[x].x; y++)
      for(int z=0; z<cell_sizes[x].y; z++)
        cells_info[x][y][z]->cell_index = total++;

  int type = 0;
  int m = 0;
  int n = 0;
  int total_set = 0;

  cells = new CellSyn*[num_cells];
  for(m = 0; m<num_cells; m++){
    cells[m]= NULL;
  }

  for(type = 0; type<Num_Types; type++){
    printf("Initializing cell %d for %d, %d\n",type, cell_sizes[type].x, cell_sizes[type].y);
    for(m=0; m<cell_sizes[type].x; m++){
      for(n=0; n<cell_sizes[type].y; n++){
        cells[get_cell_index(type,m,n)]=CellSyn::initialize(type,m,n,cells_info,output_location);
        total_set++;
      }
    }
  }

  //sanity checks
  if(total_set != num_cells){
    printf("process not given enough cells. This should not happen\n");
    printf("number given: %d\n",total_set);
    printf("number needed: %d\n",num_cells);
    exit(1);
  }

  for(m=0;m<num_cells;m++){
    if(cells[m]==NULL){
      printf("graph coloring probably failed\n");
      exit(1);
    }
  }
  //all checks passed
  return;
}


// Scale connection strength by number of inputs
void scale_synapses(CellSyn** &cells, int num_cells){
  printf("Scaling Synapses ... \n");
  double factor=1;
  double rr=50;
  for(int i=0; i<num_cells; i++) {
    if(i>=200&&i<200+rr)
    {
      factor=1;
    }
    else if(i>=700-rr&&i<700)
      factor=1;
    else factor=1;
    cout<<i<<":"<<cells[i]->type<<" factor:"<<factor<<endl;
    // -------------- Scaling Method ----------------------
    for(int k=0; k < cells[i]->num_syns; k++) {
      if (cells[i]->syns[k]->type==E_GAP) {
        if ((max_connect_gap[cells[i]->type][cells[i]->syns[k]->from_type])==0) {
          printf("Error during scaling GAP synapse for %d from %d =0 \n",cells[i]->type, cells[i]->syns[k]->from_type);
          exit(1);
        }
        cells[i]->syns[k]->strength= cells[i]->syns[k]->strength/max_connect_gap[cells[i]->type][cells[i]->syns[k]->from_type];
        cells[i]->syns[k]->mini_s = cells[i]->syns[k]->mini_s/max_connect_gap[cells[i]->type][cells[i]->syns[k]->from_type]*factor;
      }
      else{
        if ((max_connect[cells[i]->type][cells[i]->syns[k]->from_type])==0) {
          printf("Error during scaling synapse for %d from %d =0 \n",cells[i]->type, cells[i]->syns[k]->from_type);
          exit(1);
        }
        cells[i]->syns[k]->strength= cells[i]->syns[k]->strength/max_connect[cells[i]->type][cells[i]->syns[k]->from_type];
        cells[i]->syns[k]->mini_s = cells[i]->syns[k]->mini_s/max_connect[cells[i]->type][cells[i]->syns[k]->from_type]*factor;
      }
    }
  }
  return;
}

void send_IStim1(int i, int j,double cx_stim, double cxa_stim){
  int group_index_CXa = get_cell_index(E_CXa,i,j);
  int group_index_CX = get_cell_index(E_CX,i,j);
  ((CX*)cells[group_index_CX]->base_cell)->I_Stim1 = cx_stim;
  ((CX*)cells[group_index_CXa]->base_cell)->I_Stim1 = cxa_stim;
}

//receive for getting things to the root printing
double print_receive(int m , int n, enum Cell_Type type){
  double message = 0;
  int group_index = get_cell_index(type,m,n);
  message = cells[group_index]->base_cell->get_v_soma();
  return message;
}

//receive for getting things to the root printing
void print_receive_gsynapse_index(int m , int n, enum Cell_Type from_type, enum Cell_Type type, enum Syn_Type stype, FILE *fp){
  int group_index = get_cell_index(type,m,n);
  // Run through all synapses
  for(int i =0; i < cells[group_index]->num_syns; i++){
    if ((cells[group_index]->syns[i]->type == stype) && ((cells[group_index]->syns[i]->from_type == from_type))){   
      int from=cells[cells[group_index]->syns[i]->from_cell]->m;
      fprintf(fp,"%d %d ", from ,m);
    }
  }
}

//receive for getting things to the root printing
void print_receive_gsynapse(int m , int n, enum Cell_Type type, enum Syn_Type stype, FILE *fp){
  int group_index = get_cell_index(type,m,n);
  // Run through all synapses
  for(int i =0; i < cells[group_index]->num_syns; i++){
    if (cells[group_index]->syns[i]->type == stype){   
      fprintf(fp,"%d %lf ", m, ((AMPA_D3*)(cells[group_index]->syns[i]))->g_AMPA0); //D3
    }
  }
}

//receive minis for printing
void print_receive_minis(int m , int n, enum Cell_Type type, enum Syn_Type stype, FILE *fp){
  int group_index = get_cell_index(type,m,n);
  // Run through all synapses
  for(int i =0; i < cells[group_index]->num_syns; i++){
    if (cells[group_index]->syns[i]->type == stype){   
      fprintf(fp,"%d %lf ", m, ((AMPA_D3*)(cells[group_index]->syns[i]))->mini_s);
    }
  }
}

//receive for getting how many times a cell has spiked during the fre_window
int fre_receive(int m , int n, enum Cell_Type type){
  int message = 0;
  int group_index = get_cell_index(type,m,n);
  message = cells[group_index]->num_spikes;
  return message;
}

//receives dedritic voltage from connecting cell and returns it
//all args inputs
//m n and type are the index of the sending cell, my_type is the index of the receiving cell
double receive_dend(int my_type,int m, int n, enum Cell_Type type){
  int group_index = get_cell_index(type,m,n);
  return cells[group_index]->base_cell->get_v_dend();
}

//receives voltage from connecting cell and returns it
//all args inputs
//m n and type are the index of the sending cell, my_type is the index of the receiving cell
int receive_spike(int m, int n, enum Cell_Type type){
  int group_index = get_cell_index(type,m,n);
  return cells[group_index]->get_flip();
}

int receive_spike_for_maps(int m, int n, enum Cell_Type type){
  int group_index = get_cell_index(type,m,n);
  return cells[group_index]->get_flip_for_maps();
}

extern FILE *f28; 

void load_input_data(int argc, char *argv[]){ 
  //checks inputs
  if (argc < 5) {
    puts("Bad command: Should be");
    puts("input_file_name output_directory connections_file_name protocol_file");
    exit(1);
  }
  output_location = argv[2];
  output_location = output_location + "/";

  //open up the file of connections
  FILE *connections_file;
  if (!(connections_file=fopen(argv[3],"r"))) {
    printf("%s file for connections does not exist or something\n",argv[3]);
    exit(1);
  }

  set_cell_sizes(connections_file,Num_Types,cell_sizes,cell_numbers); //scans connections file for how many cells of each type we have
  create_connections_from_file(&cells_info,cell_sizes,connections_file,Num_Types);

  //finds total number of cells
  num_cells = 0;
  for(int iter = 0; iter<Num_Types; iter++){
    num_cells = num_cells+cell_numbers[iter];
  }
  printf("number cells: %d\n",num_cells);

}

double correct1_func(double value, double facp){
  if (value<1){
    return value*(1-facp);
  } else{
    return value*(1+facp);    
  }
}

double linear_change(double start_value, double tdiff, double end_value){
  return start_value  + (tdiff * (end_value - start_value));
}

FILE *fmanipulations;


// ---------------- initial weights and compact binary recorder ----------------
// Donor applied a Gaussian jitter to each AMPA_D3 weight inside the parallel
// region at t in (11999,12000) using the global rand(), so the draw order (and
// hence the weights) depended on thread scheduling.  Same formula, drawn
// serially in cell order before the first step.
void init_plastic_weights(){
  for(int i=0; i<num_cells; i++)
    for(int k=0; k<cells[i]->num_syns; k++)
      if(cells[i]->syns[k]->type==E_AMPA_D3){
        AMPA_D3 *s=(AMPA_D3*)cells[i]->syns[k];
        s->g_AMPA0 = s->strength;
        if(weight_jitter){ double Var = s->g_AMPA0/10; double r3 = getGaussian2(Var); s->g_AMPA0 = s->strength + s->strength*r3; }
        s->weight_max = 2*s->strength;
        s->weight_min = 0.00001*s->strength;
        s->minis0 = s->mini_s;
        s->initialised = 1;
      }
}

// Overwrite PY-PY AMPA_D3 weights and minis from a 'pre post g mini' text file
// (protocol directive 'weights').  Iterates synapses in the recorder's order and
// checks every pre/post pair, so a file from a different network aborts the run.
// Bounds (weight_max/min, minis0) stay tied to 'strength', as in the trained run.
void load_plastic_weights(const std::string &path){
  FILE *f=fopen(path.c_str(),"r");
  if(!f){ fprintf(stderr,"cannot open weights file %s\n",path.c_str()); exit(2); }
  int n=0;
  for(int i=0; i<num_cells; i++)
    if(cells[i]->type==E_CX)
      for(int k=0; k<cells[i]->num_syns; k++)
        if(cells[i]->syns[k]->type==E_AMPA_D3){
          AMPA_D3 *s=(AMPA_D3*)cells[i]->syns[k];
          int pre,post; double g,mn;
          if(fscanf(f,"%d %d %lf %lf",&pre,&post,&g,&mn)!=4){ fprintf(stderr,"weights file short at row %d\n",n); exit(2); }
          if(pre!=cells[s->from_cell]->m || post!=cells[i]->m){
            fprintf(stderr,"weights file row %d is %d->%d, network has %d->%d\n",n,pre,post,cells[s->from_cell]->m,cells[i]->m); exit(2); }
          s->g_AMPA0=g; s->mini_s=mn; n++;
        }
  int extra; if(fscanf(f,"%d",&extra)==1){ fprintf(stderr,"weights file has more rows than synapses (%d)\n",n); exit(2); }
  fclose(f);
  printf("loaded %d PY-PY weights from %s\n",n,path.c_str());
}

static FILE *f_lfp=NULL, *f_w=NULL, *f_mini=NULL;
void recorder_step(int ii, double t);
static std::vector<AMPA_D3*> rec_syn;
static int lfp_every=0, w_every=0;

void recorder_open(){
  FILE *fi=fopen((output_location+"weights_index.txt").c_str(),"w");
  fprintf(fi,"# pre_PY post_PY  (row order of weights_g.f32 / weights_mini.f32 after the time column)\n");
  for(int i=0; i<num_cells; i++)
    if(cells[i]->type==E_CX)
      for(int k=0; k<cells[i]->num_syns; k++)
        if(cells[i]->syns[k]->type==E_AMPA_D3){
          rec_syn.push_back((AMPA_D3*)cells[i]->syns[k]);
          fprintf(fi,"%d %d\n", cells[cells[i]->syns[k]->from_cell]->m, cells[i]->m);
        }
  fclose(fi);
  if(lfp_dt>0){ f_lfp=fopen((output_location+"lfp.f32").c_str(),"wb"); lfp_every=(int)(lfp_dt/TAU+0.5); }
  if(weight_dt>0){ f_w=fopen((output_location+"weights_g.f32").c_str(),"wb");
                   f_mini=fopen((output_location+"weights_mini.f32").c_str(),"wb"); w_every=(int)(weight_dt/TAU+0.5); }
}
void recorder_initial_snapshot(){ recorder_step(-1, 0.0); }   // weights at t = 0

// columns of lfp.f32: t, mean PY soma V, mean IN soma V, mean TC V, mean RE V
void recorder_step(int ii, double t){
  if(f_lfp && ii>=0 && ii%lfp_every==0){
    double sum[4]={0,0,0,0}; int n[4]={0,0,0,0};
    for(int i=0;i<num_cells;i++){
      int ty=cells[i]->type, c=-1;
      if(ty==E_CX)c=0; else if(ty==E_IN)c=1; else if(ty==E_TC)c=2; else if(ty==E_RE)c=3;
      if(c<0) continue;
      sum[c]+=cells[i]->base_cell->get_v_soma(); n[c]++;
    }
    float row[5]; row[0]=(float)(t+TAU);   // state after this step
    for(int c=0;c<4;c++) row[c+1]=(float)(n[c]?sum[c]/n[c]:0.0);
    fwrite(row,sizeof(float),5,f_lfp);
  }
  if(f_w && (ii<0 || ii%w_every==0)){
    std::vector<float> g(rec_syn.size()+1), mn(rec_syn.size()+1);
    g[0]=mn[0]=(float)(ii<0 ? t : t+TAU);
    for(size_t k=0;k<rec_syn.size();k++){ g[k+1]=(float)rec_syn[k]->g_AMPA0; mn[k+1]=(float)rec_syn[k]->mini_s; }
    fwrite(&g[0],sizeof(float),g.size(),f_w);
    fwrite(&mn[0],sizeof(float),mn.size(),f_mini);
  }
}


// ---- optional trained-area recorder (rec_area 1): one row per LFP sample (1 ms) ----
// cols: t, then for region R in {trained PY 200-224, control PY 400-424}: mean available efficacy of
// AMPA_D3 PY->PY synapses with pre and post in R, of GABA_A_D2 IN->PY onto R, of AMPA_D2 PY->IN from R;
// mean dendritic V, Ca_i, KCa gate, Km gate of the PY cells in R.  (15 floats per row)
static FILE *f_area = NULL;
static std::vector<int> area_py[2];
static std::vector<AMPA_D3*> area_d3[2];
static std::vector<GABA_A_D2*> area_gaba[2];
static std::vector<AMPA_D2*> area_pyin[2];
void area_open(){
  if(!rec_area) return;
  int lo[2] = {200, 400};
  for(int r = 0; r < 2; r++)
    for(int i = 0; i < num_cells; i++){
      int m = cells[i]->m;
      if(cells[i]->type == E_CX && m >= lo[r] && m < lo[r] + 25){
        area_py[r].push_back(i);
        for(int k = 0; k < cells[i]->num_syns; k++){
          Syn *s = cells[i]->syns[k]; int pm = cells[s->from_cell]->m;
          if(s->type == E_AMPA_D3 && pm >= lo[r] && pm < lo[r] + 25) area_d3[r].push_back((AMPA_D3*)s);
          if(s->type == E_GABA_A_D2) area_gaba[r].push_back((GABA_A_D2*)s);
        }
      }
      if(cells[i]->type == E_IN)
        for(int k = 0; k < cells[i]->num_syns; k++){
          Syn *s = cells[i]->syns[k]; int pm = cells[s->from_cell]->m;
          if(s->type == E_AMPA_D2 && s->from_type == E_CX && pm >= lo[r] && pm < lo[r] + 25) area_pyin[r].push_back((AMPA_D2*)s);
        }
    }
  printf("rec_area: PY %zu/%zu  D3 %zu/%zu  GABA %zu/%zu  PY->IN %zu/%zu\n", area_py[0].size(), area_py[1].size(),
         area_d3[0].size(), area_d3[1].size(), area_gaba[0].size(), area_gaba[1].size(), area_pyin[0].size(), area_pyin[1].size());
  f_area = fopen((output_location + "rec_area.f32").c_str(), "wb");
}
void area_step(int ii, double t){
  if(!f_area || lfp_every <= 0 || ii % lfp_every) return;
  float row[15]; row[0] = (float)(t + TAU); int c = 1;
  for(int r = 0; r < 2; r++){
    double a = 0, g = 0, pi = 0, v = 0, ca = 0, kca = 0, km = 0;
    for(size_t k = 0; k < area_d3[r].size(); k++) a += area_d3[r][k]->efficacy(t);
    for(size_t k = 0; k < area_gaba[r].size(); k++) g += area_gaba[r][k]->efficacy(t);
    for(size_t k = 0; k < area_pyin[r].size(); k++) pi += area_pyin[r][k]->efficacy(t);
    for(size_t k = 0; k < area_py[r].size(); k++){ double *y = cells[area_py[r][k]]->y; v += y[0]; ca += y[1]; kca += y[4]; km += y[5]; }
    double n = area_py[r].size();
    row[c++] = a / area_d3[r].size(); row[c++] = g / area_gaba[r].size(); row[c++] = pi / area_pyin[r].size();
    row[c++] = v / n; row[c++] = ca / n; row[c++] = kca / n; row[c++] = km / n;
  }
  fwrite(row, sizeof(float), 15, f_area);
}

void recorder_close(){ if(f_area)fclose(f_area); if(f_lfp)fclose(f_lfp); if(f_w)fclose(f_w); if(f_mini)fclose(f_mini); }

//+++++++++++++++++++ MAIN PROGRAM +++++++++++++++++++++++++++++++++++++++++++
int main(int argc,char **argv){

  LocalFieldPotential LFP;

  load_input_data(argc,argv);
  load_input_params(argc,argv,tmax,t3D,ttime,num_mp_threads,print_c_sten,fre_print_cs,LFP.local_field_effect,LFP.lfp_scale,LFP.num_field_layers,homeo.boost,homeo.amp_boost,homeo.con_boost,homeo.fre_boost,homeo.target_f,homeo.fre_window,homeo.num_regions,input_strength,input_start_neuron,input_end_neuron, block_size);

  // donor: srand(2000).  sim_seed = 0 reproduces it; other seeds shift every
  // RNG (cell leak heterogeneity here, mini-EPSP streams in currents.h, jitter).
  protocol.load(argv[4]);
  srand(2000 + sim_seed);

  homeo.allocate();

  initialize_cells(cells);

  scale_synapses(cells, num_cells);
  init_plastic_weights();
  if(!protocol.weights_path.empty()) load_plastic_weights(protocol.weights_path);

  LFP.init();
  open_files(output_location,LFP.field_file,LFP.num_field_layers);
  LFP.allocate_state_save(cell_sizes);

  //------Main Loop--------
  printf("timer started");
  printf("\n starting main loop: time= %lf: end_time= %lf\n", t,tmax);
  int print_count = 0;
  int ii = 0;
  int i=0;
  hhns=new int[num_cells];
  for(i=0; i<num_cells; i++){
    if (cells[i]->ismap){
      mapns[mapi]=i;
      mapi=mapi+1;
    }
    else{
      hhns[hhi]=i;
      hhi=hhi+1;
    }
  }

  print_used_mem();
  time_t start_time = time(NULL);
  printf("root set up tau:%lf time:%lf tmax:%lf\n",TAU,t,tmax);

  check_state_table();
  FILE *fproto = fopen((output_location+"protocol_used.txt").c_str(), "w");
  protocol.dump(fproto); fclose(fproto);
  fmanipulations = fopen((output_location+"manipulation.txt").c_str(),"w");
  recorder_open();
  recorder_initial_snapshot();
  area_open();

  print_connectivity(cell_sizes);

  while( t < tmax){
    total_rec = 0;

    // vigilance state, STDP gate and training flag for this step (protocol.h)
    {
      int st = protocol.state_at(t);
      apply_state(st);
      double f = (st == ST_AWAKE) ? 1.0 : (st == ST_N2 ? stdp_factor_n2 : stdp_factor_n3);
      if (t < plasticity_start || protocol.in_test(t)) f = 0.0;
      stdp_factor_now = f;
      in_train_now = 0;
      for (size_t w = 0; w < protocol.wins.size(); w++)
        if (!protocol.wins[w].is_test && t >= protocol.wins[w].t0 && t < protocol.wins[w].t1) in_train_now = 1;
    }

    if(t>print_count){
      printf("milliseconds of sim = %lf \n", t);
      print_count = print_count + 200;
    }

    ii = ii + 1; //number iterations

    if (((ii)/(TAUr))*(TAUr) == (ii))
      runMP(1);
    else
      runMP(0);

    //applies field effects
    if(LFP.local_field_effect == 1){
      LFP.apply_field(ii,t,ttime,t,cell_sizes);
    }

    //prints all 1D cell Voltages or all x cells for one y in 2d voltages occasionally
    if((t > ttime) && ((ii/(50))*(50) == ii)){ //multiples of 50 print
      print_freq(LFP.cx_base_v_SOMA,LFP.cxa_base_v_SOMA,cell_sizes,t);
    }

    //prints all cell voltages occationally
    if((t > t3D) && (((ii)/(50000))*(50000) == (ii))){ //multiples of 500 print
      print_occ(cell_sizes);
      fprintf(fmanipulations, "%lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf \n", t, fac_AMPA_D2, fac_AMPA_TC, fac_GABA_D2, fac_GABA_TC, fac_gkl_RE, fac_gkl_TC, fac_gkl, fac_gh_TC, fac_gkca_cx, fac_gkm_cx, fac_gkv_cx);
    }

    //prints strength of connections
    if((ii >= fre_print_cs) && (ii % fre_print_cs) == 0 && print_c_sten == 1){
      int i =0;
      //TODO we are able to enumerate E_CX directly
      for(i=0; i<num_cells; i++){
        if(cells[i]->type == E_CX){
          ((CXsyn*)cells[i])->print_c_stren(f28);
        }
      }
    }

    //implements homeostatic mechanisms
    if((ii >= homeo.fre_window) && (ii % homeo.fre_window) == 0){
      homeo.spike_fre_calc(cell_sizes,cell_numbers); //figures out frequency of spiking
      int i = 0;
      for(i=0; i<num_cells; i++){
        if(cells[i]->type == E_CX || cells[i]->type == E_CXa || cells[i]->type == E_CX6){
          cells[i]->num_spikes=0;
        }
      }
      homeo.boost_activity(cell_sizes,cells,num_cells); //causes homeostatic changes
    }

    recorder_step(ii, t);
    area_step(ii, t);
    t = t + TAU; //increase time
  } //end while loop

  printf("Computation time: %d s\n",(int)difftime(time(NULL),start_time));
  close_files(LFP.field_file,LFP.num_field_layers);

  fclose(fmanipulations);
  recorder_close();
  return 0;
}
