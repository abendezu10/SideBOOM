`timescale 1ns / 1ps

module murmurhash3_tb;


  //parameter LENGTH = 3;   
  parameter LENGTH = 61;                     
  parameter [31:0] SEED = 32'h00000000;       

  reg clk;
  reg resetn;
  reg [1599:0] key; 


  wire [127:0] data_o;

  murmurhash3 #(
    .LENGTH(LENGTH),
    .SEED(SEED)
  ) uut (
    .clk(clk),
    .resetn(resetn),
    .key(key),
    .data_o(data_o)
  );


  initial clk = 0;
  always #5 clk = ~clk; 


  initial begin
    
    resetn = 0;
    key = 0;

    #20;
    resetn = 1;
    key = 1600'd0;

    //key[23:0] = {8'h63, 8'h62, 8'h61}; // "abc"
    key[487:0] = {
    8'h21, 8'h73, 8'h65, 8'h6d, 8'h69, 8'h74, 8'h20, 8'h30,
    8'h39, 8'h38, 8'h37, 8'h36, 8'h35, 8'h34, 8'h33, 8'h32,
    8'h31, 8'h20, 8'h67, 8'h6f, 8'h64, 8'h20, 8'h79, 8'h7a,
    8'h61, 8'h6c, 8'h20, 8'h65, 8'h68, 8'h74, 8'h20, 8'h72,
    8'h65, 8'h76, 8'h6f, 8'h20, 8'h73, 8'h70, 8'h6d, 8'h75,
    8'h6a, 8'h20, 8'h78, 8'h6f, 8'h66, 8'h20, 8'h6e, 8'h77,
    8'h6f, 8'h72, 8'h62, 8'h20, 8'h6b, 8'h63, 8'h69, 8'h75,
    8'h71, 8'h20, 8'h65, 8'h68, 8'h54
    };
    

    #3000;

    $display("hash = %h", data_o);

    $finish;
  end

endmodule
