module axilite_s(
input s_axi_aclk,// axi clk signal
  input s_axi_aresetn,// active low reset
  input s_axi_awvalid,//master signals valid write address
  output reg s_axi_awready,//slave ready to accept write addr
  input [31:0] s_axi_awaddr,//write addr from master
  
  input s_axi_wvalid,//master siganls valid write data
  output reg s_axi_wready,//slave ready to accept write data
  input wire [31:0] s_axi_wdata,//write data
  
  output reg s_axi_bvalid,//slave signals write response valid
  input s_axi_bready,//master ready to accept write response
  output reg [1:0] s_axi_bresp,//Write response (00=OKAY, 11=SLVERR)
  
  input s_axi_arvalid,//master signals valid read addr
  output reg s_axi_arready,//slave ready to accept read addr
  input [31:0] s_axi_araddr,//read addr
  
  output reg s_axi_rvalid,//slave signals read data valid
  input wire s_axi_rready,//master ready to accept read data
  output reg [31:0] s_axi_rdata,//read data
  output reg [1:0] s_axi_rresp//Read response (00=OKAY, 11=SLVERR)

);
localparam idle=0,//no axi transaction takes place
  send_waddr_ack=1,//Accept write address (AW) and acknowledge
  
  send_raddr_ack=2,//Accept read address (AR) and acknowledge
  
  send_wdata_ack=3,//acknowledge that slave received write data(wready)
 update_mem=4,//Update internal memory/registers using WADDR and WDATA
  send_wr_err=5,//Respond with write error if address invalid
  send_wr_resp=6,//Send successful write response (BVALID, BRESP=OKAY)
  gen_data=7,//Prepare read data before sending
  send_read_err=8,//send error response for read request
  send_rdata=9;//Send valid read data (RVALID, RDATA) back to master

  ///INTERNAL REGISTERS
  reg [3:0] state=idle;
  reg [3:0] next_state=idle;
  reg [1:0] count=0;
  reg [31:0] waddr,raddr,wdata,rdata;
  
  //// Internal 128 x 32-bit memory
  reg [31:0] mem [0:127];
  
  always @(posedge s_axi_aclk)
    begin
      if(s_axi_aresetn==1'b0)
        begin
          state<=idle;
          for(int i=0;i<128;i++)
            begin
              mem[i]<=0;
            end
          s_axi_awready<=0;
          s_axi_wready<=0;
          s_axi_bvalid<=0;
          s_axi_bresp<=0;
          s_axi_arready<=0;
          s_axi_rvalid<=0;
          //s_axi_rready<=0;
          s_axi_rdata<=0;
          s_axi_rresp<=0;
          waddr<=0;
          raddr<=0;
          wdata<=0;
          rdata<=0;
          
        end
      else
        begin
          case(state)
            idle:
              begin
                s_axi_awready<=0;
                s_axi_wready<=0;
                s_axi_bvalid<=0;
                s_axi_bresp<=0;
                s_axi_arready<=0;
                s_axi_rvalid<=0;
          //s_axi_rready<=0;
                s_axi_rdata<=0;
                s_axi_rresp<=0;
                waddr<=0;
                raddr<=0;
                wdata<=0;
                rdata<=0;
                count<=0;
                s_axi_rvalid<=1'b0;
                
                if(s_axi_awvalid==1'b1)
                  begin
                    state<=send_waddr_ack;//accept write addr and acknowledge
                    waddr<=s_axi_awaddr;//write addr from master
                    s_axi_awready<=1'b1;//means slave is ready to accept write addr
                  end
                
                else if(s_axi_arvalid==1'b1)//master signals valid read addr
                  begin
                    state<=send_raddr_ack;//accept read addr and acknowledge
                    raddr<=s_axi_araddr;
                    s_axi_arready<=1'b1;//master is ready to accept read data
                  end
                
                else
                  begin
                    state<=idle;
                  end
                  
                
              end
            
            send_waddr_ack:
              begin
               s_axi_awready<=1'b0;/*The slave deasserts AWREADY because it has already accepted the write address.
                                     AXI protocol requires that once the address handshake (AWVALID & AWREADY) is complete, AWREADY must be lowered.*/
                if(s_axi_wvalid)/*This checks if the master is presenting valid write data on the bus.
                                  AXI has independent channels, so data (WVALID) may come a few cycles after the address handshake.
                                  We only proceed when WVALID = 1.*/
                  begin
                    wdata<=s_axi_wdata;/*The slave latches the incoming write data (WDATA) into an internal register wdata.
                                         This ensures the data is safely stored before we signal readiness.*/
                    s_axi_wready<=1'b1;/*The slave asserts WREADY to indicate it’s ready to accept the data.
                                         Handshake condition:
                                         When WVALID (from master) and WREADY (from slave) are both 1,
                                         → the data transfer is complete.*/
                    state<=send_wdata_ack;
                  end
                
                else
                  begin
                    state<=send_waddr_ack;
                  end
              
              end
            
            send_wdata_ack:
              begin
                s_axi_wready<=1'b0;//deasserted bcoz slave has already accepted the write data
                if(waddr<128)//checks for valid mem range
                  begin
                    state<=update_mem;
                   mem[waddr[6:0]] <= wdata;
                  end
                else
                  begin
                    state<=send_wr_err;//decode error
                    s_axi_bresp<=2'b11;//error response
                    s_axi_bvalid<=1'b1;
                  end
              end
            
            update_mem:
              
              begin
                mem[waddr]<=wdata;
                state<=send_wr_resp;
              end
            
            send_wr_resp:
              
              begin
                s_axi_bresp<=2'b00;//no error occured during write
                s_axi_bvalid<=1'b1;/*This signal tells the master that the write response is valid and ready to be read.
                                     In AXI protocol, the slave must assert bvalid when it has a valid response available.*/
                if(s_axi_bready)//So this condition checks:
                               // Has the master acknowledged the response?
                  begin
                    state<=idle;/*If the master accepted the response (bready = 1), the transaction is complete.
The state machine returns to the idle state — ready for the next transaction.*/
                  end
                
                else
                  begin
                    state<=send_wr_resp;/*If the master has not yet accepted the response (bready = 0),
                                        the slave keeps the response valid (bvalid = 1) and stays in this state.
                                        This ensures protocol compliance — the slave keeps the response stable until the master takes i*/
                    
                  end
                  
              end
            
            send_wr_err:/*So this is reached if:
                          The write address (waddr) is invalid,
                          e.g., waddr >= 128 (outside memory range).
                          The slave must respond with an error signal to the AXI master.*/
              begin
                if(s_axi_bready)/*This checks whether the master is ready to accept the write response.
                                  When the master asserts bready = 1, it means:
                                  "I’ve received and accepted the response (even if it’s an error)."
                                  → So the state machine can return to idle and get ready for the next transaction.*/
                                  //slave is waiting for the master to acknowledge the error response
                  begin
                    state<=idle;
                  end
                else
                  begin
                    state<=send_wr_err;
                  end
              end
            
            //read operation
            send_raddr_ack:
              begin
                s_axi_arready<=1'b0;
                if(raddr<128)
                  state<=gen_data;//generate data requested by master
                else
                  begin
                    s_axi_rvalid<=1'b1;
                    state<=send_read_err;
                    s_axi_rdata<=0;
                    s_axi_rresp<=2'b11;//decode error
                  end
              end
                
            gen_data:
              begin
                if(count<2)//wait for 2 clock cycles to fetch data from memory
                  begin
                    rdata<=mem[raddr];
                    state<=gen_data;
                    count<=count+1;//afetr 2 clock ticks we can say data is available on rdata 
                  end
                
                else
                  begin
                   s_axi_rvalid<=1'b1;
                    s_axi_rdata<=rdata;//send rdata on outputu data bus
                    s_axi_rresp<=2'b00;//okay
                    
                    if(s_axi_rready)//wait for master to receive this response
                      state<=idle;//as soon as master receives we jump back to idle state
                    else
                      state<=gen_data;//else stay in same state
                    
                  end
                  
              end
            
            send_read_err:
              begin
                if(s_axi_rready)//wait for master to receive the response
                  begin
                    state<=idle;
                  end
              end
            
            default:
              state<=idle;
          endcase
            
        end
    end
  
endmodule
  
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
  
  
  
