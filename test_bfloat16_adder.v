module test_bfloat16_adder;

logic [15:0] sum; 
logic ready;
logic [15:0] a, b;
logic clock, nreset;

shortreal reala, realb, realsum;
logic [31:0] ra, rb;

bfloat16_adder a1 (.*);

initial
  begin
  nreset = '1;
  clock = '0;
  #5ns nreset = '1;
  #5ns nreset = '0;
  #5ns nreset = '1;
  forever #5ns clock = ~clock;
  end
  
initial
  begin
  //Test 1 -- reset
  @(posedge ready); // wait for ready
  
  //Test 2 -- 1.0 + 1.0 
  @(posedge clock); //wait for next clock tick
  reala = 1.0;
  ra = $shortrealtobits(reala);
  realb = 1.0;
  rb = $shortrealtobits(realb);
  a = ra[31:16];
  b = rb[31:16];
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal({sum, 16{1'b0});
  $display("Test 2 %f\n", realsum);
  
  //Test 3 -- 42.0 + 3.14159 
  //@(posedge clock);
  reala = 42.0;
  ra = $shortrealtobits(reala);
  realb = 3.14159;
  rb = $shortrealtobits(realb);
  a = ra[31:16];
  b = rb[31:16];
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal({sum, 16{1'b0});
  $display("Test 3 %f\n", realsum);
  
  //next test
  
  //Test 11 -- 1.0 + NaN 
  //@(posedge clock);
  reala = 1.0;
  a = $shortrealtobits(reala);
  realb = (0.0/0.0);
  b = $shortrealtobits(realb);
  a = ra[31:16];
  b = rb[31:16];
  @(posedge ready);
  @(posedge clock);
  realsum = $bitstoshortreal({sum, 16{1'b0});
  $display("Test 12 %f\n", realsum);
  end
endmodule
  