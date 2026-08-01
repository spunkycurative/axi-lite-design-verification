class transaction;

  randc bit op;//if op=1->write else read
  rand bit [31:0] awaddr;
  rand bit [31:0] wdata;
  rand bit [31:0] araddr;
  bit [31:0] rdata;
  bit [1:0] bresp;
  bit [1:0] rresp;
  
 constraint valid_addr_range {
    awaddr inside {[0:127]};
    araddr inside {[0:127]};
}

  constraint valid_data_range {
    wdata inside {[32'h00000000 : 32'hFFFFFFFF]};
}
  
  
endclass
