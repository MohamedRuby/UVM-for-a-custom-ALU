package alu_pkg ;
// user defined data types for the dut

typedef logic [7:0] data_t;
typedef enum logic [1:0]{
  OP1 = 2'b00,
  OP2 = 2'b01,
  OP3 = 2'b10,
  OP4 = 2'b11
}opcode_t;

// This type is used inside the transaction
typedef enum logic [2:0]{
  ENABLE_MODE_0 = 3'b000, 
  ENABLE_MODE_1 = 3'b001,
  ENABLE_MODE_2 = 3'b010,
  ENABLE_MODE_A = 3'b011, //{alu_enable_b,alu_enable_a,alu_enable}
  ENABLE_MODE_4 = 3'b100,
  ENABLE_MODE_B = 3'b101,
  ENABLE_MODE_6 = 3'b110,
  ENABLE_MODE_7 = 3'b111
}mode_t;




endpackage