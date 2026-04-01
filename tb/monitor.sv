class monitor;
  
  virtual axi_if vif;
  transaction tr,trd;
  
  mailbox #(transaction)mbxms;
  mailbox #(transaction) mbxdm;
  
  function new (mailbox #(transaction)mbxms,mailbox #(transaction)mbxdm);
    this.mbxms=mbxms;
    this.mbxdm=mbxdm;
  endfunction
  
  task run();
  forever begin
    tr = new();
    mbxdm.get(trd); // Get the transaction intent from the Driver
    
    if(trd.op == 1) begin // Write Operation
      tr.op = trd.op;
      tr.awaddr = trd.awaddr;
      tr.wdata = trd.wdata;
      
      // Wait for the Write Response Handshake
      wait(vif.bvalid && vif.bready);
      tr.bresp = vif.bresp; 
      // Small delay to move past the current clock edge
      @(posedge vif.clk);
      
      $display("[MON]: Write | Addr:%0d, Data:%0d, Resp:%0b", tr.awaddr, tr.wdata, tr.bresp);
      mbxms.put(tr);
    end
    else begin // Read Operation
      tr.op = trd.op;
      tr.araddr = trd.araddr;
      
      // Wait for the Read Data Handshake
      wait(vif.rvalid && vif.rready);
      tr.rdata = vif.rdata;
      tr.rresp = vif.rresp;
      @(posedge vif.clk);
      
      $display("[MON]: Read | Addr:%0d, Data:%0d, Resp:%0b", tr.araddr, tr.rdata, tr.rresp);
      mbxms.put(tr);
    end
  end
endtask
  //if write is 00 i.e ok and read is 00 then we say test is passed
  
