class transaction;

  randc bit op;//if op=1->write else read
  rand bit [31:0] awaddr;
  rand bit [31:0] wdata;
  rand bit [31:0] araddr;
  bit [31:0] rdata;
  bit [1:0] bresp;
  bit [1:0] rresp;
  
  constraint valid_addr_range{
    awaddr inside {2,3,4,8,5,7};
    araddr inside {11,15,13,16,12,14};
                             }
  constraint valid_data_range{wdata<10;rdata<10;}
  
endclass
