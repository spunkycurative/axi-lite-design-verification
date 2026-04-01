class driver;
  virtual axi_if vif;
  transaction tr;
  
  mailbox #(transaction)mbxgd;
  mailbox #(transaction)mbxdm;
  
  function new(mailbox #(transaction)mbxgd,mailbox #(transaction)mbxdm);
    this.mbxgd=mbxgd;
    this.mbxdm=mbxdm;
  endfunction
  
  task reset();
    vif.resetn<=1'b0;
    vif.awvalid<=1'b0;
    vif.awaddr<=0;
    vif.wvalid<=0;
    vif.wdata<=0;
    vif.bready<=0;
    vif.arvalid<=1'b0;
    vif.araddr<=0;
    vif.araddr<=0;
    repeat(5)@(posedge vif.clk);
    vif.resetn<=1'b1;
    
    $display("[DRV]:RESET DONE");
    
  endtask
  
  task write_data(input transaction tr);
    $display("[DRV]:op:%0b , awaddr=%0d , wdata=%0d",tr.op,tr.awaddr,tr.wdata);
    mbxdm.put(tr);
    ///sent an addr
    vif.resetn<=1'b1;
    vif.awvalid<=1'b1;//valid addrs
    vif.arvalid<=1'b0;
    vif.araddr<=0;
    vif.awaddr<=tr.awaddr;//awaddr will be the addr sent by gen
    ///wait for the slave to recieve it
    wait (vif.awready);
    @(posedge vif.clk);
    //sent a data
    vif.awvalid<=1'b0;
    vif.awaddr<=0;
    vif.wvalid<=1'b1;
    vif.wdata<=tr.wdata;
    ///wait for slave to receive it 
    wait (vif.awready);
    @(posedge vif.clk);
    vif.wvalid<=1'b0;
    vif.wdata<=0;
    vif.bready<=1'b1;
    vif.rready<=1'b0;
    wait(vif.bvalid);//wait for the response of write transaction
    @(posedge vif.clk);
    vif.bready<=1'b0;
  endtask
  
  task read_data(input transaction tr);//addr generated for the read addr by the generator
    $display("[DRV]: op : %0b , araddr=%0d",tr.op,tr.araddr);
    mbxdm.put(tr);
    vif.resetn<=1'b1;
    vif.awvalid<=1'b0;
    vif.awaddr<=0;
    vif.wvalid<=1'b0;
    vif.wdata<=0;
    vif.bready<=1'b0;
    vif.arvalid<=1'b1;
    vif.araddr<=tr.araddr;
    wait(vif.arready);//wait for slave to receive this addr
    @(posedge vif.clk);
    vif.araddr<=0;
    vif.arvalid<=1'b0;
    vif.rready<=1'b1;//notifying the slave we are ready to receive , the read data as well as response
    wait (vif.rvalid);//slave will make rvalid 1 when its ready with the data
    @(posedge vif.clk);
    vif.rready<=1'b0;
  endtask
  
  task run();
    forever begin
      mbxgd.get(tr);
      @(posedge vif.clk);
      if(tr.op==1)
        write_data(tr);
      else
        read_data(tr);
    end
    
  endtask
