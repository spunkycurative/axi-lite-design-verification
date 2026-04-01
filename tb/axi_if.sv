interface axi_if;
  logic clk,resetn;
  logic awvalid,awready;
  logic arvalid,arready;
  logic wvalid,wready;
  logic bready,bvalid;
  logic rvalid,rready;
  logic [31:0] awaddr,araddr,wdata,rdata;
  logic [1:0] wresp,rresp,bresp;
  
  
endinterface
  
