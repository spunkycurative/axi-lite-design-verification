

class scoreboard;
  
  transaction tr,trd;
  event sconext;
  mailbox #(transaction)mbxms;
  
  bit [31:0] temp;
  bit [31:0] data[128]='{default:0};
  /*temp = data[addr]; // temporary read from memory
  data[5] = 32'hABCD1234;  // write to memory at index 5
  temp = data[5];           // read from memory at index 5
 ->data acts like your main memory or storage (like a small RAM).
->temp acts as a temporary register to hold intermediate or read/write data.*/
  
  function new(mailbox #(transaction)mbxms);
    this.mbxms=mbxms;
  endfunction
  
 
  function new(mailbox #(transaction)mbxms);
    this.mbxms=mbxms;
  endfunction
  
  task run();
    forever begin
      mbxms.get(tr);
      
      if(tr.op==1)
        begin
          $display("[SCO]: op=%0b , awaddr=%0d , wdata=%0d , wresp=%0d",tr.op,tr.awaddr,tr.wdata,tr.bresp);
          if(tr.bresp==3)
            $display("[SCO]: DEC error");
          else begin
            data[tr.awaddr]=tr.wdata;
            $display("[SCO] : DATA STORED ADDR = %0d and data=%0d",tr.awaddr,tr.wdata);
            
          end
          
        end
      else
        begin
          $display("[SCo] : op : %0b , araddr=%0d , rdata=%0d , rresp=%0d",tr.op,tr.araddr,tr.rdata,tr.rresp);
          temp=data[tr.araddr];
          if(tr.rresp==3)
            $display("[SCO] : DEC error");
          else if(tr.rresp==0 && tr.rdata==temp)//temp->data extracted from array ,rdata->data written by the mem
            $display("[SCO]: Data matched");
        else
            $display("[SCO]:Data mismatched");
        end
      $display("---------------------");
      ->sconext;
    end
      
  endtask
  
endclass

