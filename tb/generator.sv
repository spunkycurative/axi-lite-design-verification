class generator;
  transaction tr;
  mailbox #(transaction)mbxgd;
  
  event done;
  event sconext;
  int count = 0;
  function new(mailbox #(transaction)mbxgd);
    this.mbxgd=mbxgd;
    //tr=new();
  endfunction
  
  task run();
    for(int i=0;i<count;i++)begin
      tr=new();
      
        assert(tr.randomize()) else $error("randomization failed");
        $display("[GEN]: OP: %0b , awaddr=%0d , araddr=%0d , wdata=%0d",tr.op,tr.awaddr,tr.araddr,tr.wdata); 
        mbxgd.put(tr);
        @(sconext);
      end
     ->done; 
  endtask
  
  
endclass
