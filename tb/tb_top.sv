
module tb;
  
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  event nextgd;
  event nextgm;
  
  mailbox #(transaction) mbxgd,mbxms,mbxdm;
  
  axi_if vif();
  
  axilite_s dut(vif.clk,vif.resetn,vif.awvalid,vif.awready,vif.awaddr,vif.wvalid,vif.wready,vif.wdata,vif.bvalid,vif.bready,vif.bresp,vif.arvalid,vif.arready,vif.araddr,vif.rvalid,vif.rready,vif.rdata,vif.rresp);
  
  axi_assertions asrt(vif);
  
  initial begin
    vif.clk<=0;
  end
  always #5 vif.clk=~vif.clk;
  
  initial begin
    mbxgd=new();
    mbxms=new();
    mbxdm=new();
    gen=new(mbxgd);
    drv=new(mbxgd,mbxdm);
    mon=new(mbxms,mbxdm);
    sco=new(mbxms);
    gen.count=200;
    drv.vif=vif;
    mon.vif=vif;
    gen.sconext=nextgm;
    sco.sconext=nextgm;
    
  end
  
  initial begin
    drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none
    wait(gen.done.triggered);
    #100;
    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
  
  initial begin
    #100000;
    $finish;
    
  end
  
endmodule


