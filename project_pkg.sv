/*#####################################################################################################################################
## Package name : project_pkg
## Revision     : 
## Release note :   
/*#####################################################################################################################################*/

package project_pkg ;
   import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef class Transaction ;
  typedef class Driver;
  typedef class Sequencer;
  typedef class Monitor;
  typedef class Coverage_Collector;
  typedef class Evaluator;
  typedef class Predictor;
  typedef class Scoreboard;
 // typedef class Trn_Config;
  typedef class Agent;
  typedef class Sequence;
  typedef class Base_Test;

  `include "./transaction.svh"
  `include "./driver.svh"
  `include "./sequencer.svh"
  `include "./monitor.svh"
  `include "Coverage_Collector.svh"
  `include "evaluator.svh"
  `include "predictor.svh"
  `include "scoreboard.svh"
  //`include "trn_config.svh"
  `include "./agent.svh"
  `include "./sequence.svh"
  `include "./base_test.svh"




endpackage