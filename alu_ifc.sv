
interface ifc (input logic clk);
  import alu_pkg::*;  // user defined data types 
  // inputs signals 
  data_t alu_in_a, alu_in_b;
  opcode_t alu_op_a, alu_op_b;
  logic alu_enable_a, alu_enable, alu_enable_b;
  logic alu_rst;
  logic alu_irq_clr;
  // outputs signals
  logic alu_irq;
  logic [7:0] alu_out;
  
  /////////////////////////////////////////////////////////////////////////////////////////
  // Tasks used be the drivers
  ///////////////////////////////////////////////////////////////////////////////////////// 
  task automatic  initialize ();
   alu_rst = 0; 
   alu_in_a = 0;
   alu_in_b = 0;
   alu_op_a = OP1 ;
   alu_op_b = OP1;
   alu_enable_a = 0;
   alu_enable_b = 0;
   alu_enable = 0;
   #10;
   alu_rst = 1;
  endtask

  task automatic transfer (project_pkg:: Transaction drv_trn);
   @(posedge clk);
    alu_rst      <= drv_trn.enable_alu_rst_n;
    alu_in_a     <= drv_trn.alu_in_a;
    alu_in_b     <= drv_trn.alu_in_b;
    alu_op_a     <= drv_trn.alu_op_a;
    alu_op_b     <= drv_trn.alu_op_b;
    alu_irq_clr  <= drv_trn.enable_alu_irq_clr;
    {alu_enable_b,alu_enable_a,alu_enable} <= bit'(drv_trn.alu_enables);
  endtask


  ///////////////////////////////////////////////////////////////////////////////////////////
  // Tasks used by the monitors 
  //////////////////////////////////////////////////////////////////////////////////////////






  //////////////////////////////////////////////////////////////////////////////////////////
  // councurrent asertions to implement the verification plan sections
  ///////////////////////////////////////////////////////////////////////////////////////////
  
  // sec.1 If the reset is active low alu_out and alu_irq should be zero  
  rst_async: assert property ( @(posedge clk)
             ($rose(alu_rst))|=> (alu_out && alu_irq) == 0);

  // sec.1.1 if the rst deasserted and the alu_enable is high the alu continue in operation 
  rst_recovery: assert property ( @ (posedge clk) 
	   (!alu_rst && alu_enable) |=> !$stable(alu_out)&&!$stable(alu_irq) [*2]); 
 
  // sec4 check for the values of alu_out the alu_irq is rised when it should be
  sequence alu_out_4a;
	   (alu_out == 8'hff | 
	    alu_out == 8'h00 |
	    alu_out == 8'hf8 | 
	    alu_out == 8'h83 );
  endsequence
  sequence alu_out_4b; 
	   (alu_out == 8'hf1 | 
	    alu_out == 8'hf4 |
	    alu_out == 8'hf5 | 
	    alu_out == 8'hff );
  endsequence 
  irq_triggered_4a: assert property (@(posedge clk) disable iff (!alu_rst && alu_enable && alu_enable_a && !alu_enable_b)
	  alu_out_4a  |-> alu_irq );
  irq_triggered_4b: assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable && alu_enable_b && !alu_enable_a)
	  alu_out_4b  |-> alu_irq );
  
  // sec4.2 make sure that the alu_irq does not rised with other values for alu_out
  irq_accedent_activation: assert property ( @(posedge clk) disable iff (!alu_rst )
	  not(alu_out_4a or alu_out_4b) or alu_irq_clr |-> !alu_irq );
  
  // sec4.3 
  irq_accedent_deactivition: assert property ( @(posedge clk) disable iff (!alu_rst)
	 !alu_irq && $past(alu_irq) |=> $past(alu_irq_clr) );
  
  // sec4.4 check that after irq_clr is high irq is cleared
  irq_clr_triggered: assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable)
	  alu_irq_clr && !$past (alu_irq_clr)|=> ##1 !alu_irq);
  
  // sec4.4.1 alu_irq_clr is high for at least one clk (prevent glich)
  irq_clr_stable_high1cycle: assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable)
	  $past($isunknown (alu_irq_clr))&& $isunknown(alu_irq_clr) |-> $error("There is a glitch in alu_irq_clr" ) );
  
  // sec4.5 
   irq_successive_events_4a: assert property (@(posedge clk) disable iff (!alu_rst && alu_enable && alu_enable_a && !alu_enable_b)
	  alu_out_4a [*1:$] |-> $stable(alu_irq)[*1:$] );
   irq_successive_events_4b:assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable && alu_enable_b && !alu_enable_a)
	  alu_out_4b [*1:$] |-> $stable(alu_irq) [*1:$]);
  
  // sec5.1 
  unkown_inputs: assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable)
	  !$isunknown(alu_in_a && alu_in_b && alu_op_a && alu_op_b && alu_irq && alu_out) |-> $error ("UNKNOWN VALUE!"));
  
  //sec5.2 
  illegal_all_enables_high: assert property ( @(posedge clk) disable iff (!alu_rst)
	  alu_enable && alu_enable_a && alu_enable_b |-> $error ("All enable signals are asserted high at the same time"));
  
  // sec6
  Idle_state:assert property ( @(posedge clk) disable iff (!alu_rst)
	!alu_enable or (alu_enable && !alu_enable_a && !alu_enable_b) |=> $stable(alu_out) );

  //sec7
  alu_out_no_stuck: assert property ( @(posedge clk) disable iff (!alu_rst && alu_enable)
	!$stable(alu_enable_a) or  !$stable(alu_enable_b) or
	!$stable(alu_in_b)     or  !$stable(alu_in_a)     or
	!$stable(alu_op_a)     or  !$stable(alu_op_b)       |=> $stable(alu_out) [*1:10]); 


endinterface
