module axi_assertions(axi_if vif);
  
  property p_reset;
    @(posedge vif.clk)
    !vif.resetn |=> (!vif.awready &&
                     !vif.wready &&
                     !vif.bvalid &&
                     !vif.arready &&
                     !vif.rvalid
                        );
  endproperty
  
  assert property(p_reset)
    else
      $error("Reset failed");
    
    property p_aw_handshake;//write addr handshake
      @(posedge vif.clk)
      disable iff(!vif.resetn)
      vif.awvalid |-> ##[0:2] vif.awready;
    endproperty
    
    assert property(p_aw_handshake)
      else
        $error("Handshake failed");
      
      property p_write_data_handshake;
        @(posedge vif.clk)
        disable iff(!vif.resetn)
        vif.wvalid|-> ##[0:2] (vif.wready);
      endproperty
      
      assert property(p_write_data_handshake)
        else
          $error("Write data handshake failed");
        
        property p_write_response;
          @(posedge vif.clk)
          disable iff(!vif.resetn)
          (vif.wvalid && vif.wready) |-> ##[1:3] vif.bvalid;          
        endproperty
        
        assert property(p_write_response)
          else
            $error("Write response failed");
          
          property p_bresp;
            @(posedge vif.clk)
            disable iff(!vif.resetn)
            vif.bvalid |-> (vif.bresp==2'b00 || vif.bresp==2'b11);
          endproperty
          
          assert property(p_bresp)
            else
              $error("Response is not Okay neither SLVERR");
            
            property p_read_addr_handshake;
              @(posedge vif.clk)
              disable iff(!vif.resetn)
              vif.arvalid |-> ##[0:2] vif.arready;              
            endproperty
            
            assert property(p_read_addr_handshake)
              else
                $error("Read address handshake failed");
              
            property p_read_addr_response;
              @(posedge vif.clk)
              disable iff(!vif.resetn)
              (vif.arvalid && vif.arready) |-> ##[1:5] vif.rvalid;
            endproperty
              
              assert property(p_read_addr_response)
                else
                  $error("Read response failed");
                
            property p_rresp;
              @(posedge vif.clk)
              disable iff(!vif.resetn)
              vif.rvalid |-> (vif.rresp==2'b00 || vif.rresp==2'b11);
            endproperty
                
                assert property(p_rresp)
                  else
                    $error("Read response failed");
                  
            property p_rvalid_hold;
              @(posedge vif.clk)
              disable iff(!vif.resetn)
              vif.rvalid && !vif.rready |=> vif.rvalid until_with vif.rready;
            endproperty
                  
                  assert property(p_rvalid_hold)
                    else
                      $error("Assertion failed");
            
            property p_bvalid_hold;
              @(posedge vif.clk)
              disable iff(!vif.resetn)
              vif.bvalid && !vif.bready |=> vif.bvalid until_with (vif.bready);
            endproperty
                    
                    assert property(p_bvalid_hold)
                      else
                        $error("AXI-Lite Protocol Violation: BVALID deasserted before BREADY handshake completed");
                      
             property p_awaddr_stable;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               vif.awvalid && !vif.awready |=> $stable(vif.awaddr);               
             endproperty
                      
                      assert property(p_awaddr_stable)
                        else
                          $error("AWADDR changed before write address handshake completed");
                   
             property p_wdata_stable;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               vif.wvalid && !vif.wready |=> $stable(vif.wdata);               
             endproperty
                        
                        assert property(p_wdata_stable)
                          else
                            $error("WDATA changed before WVALID/WREADY handshake completed.");
                    
             property p_araddr_stable;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               vif.arvalid && !vif.arready |=> $stable(vif.araddr);               
             endproperty
                          
                          assert property(p_araddr_stable)
                            else
                              $error("ARADDR changed before arvalid and arready handshake");
                            
             property p_valid_write_addr;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               (vif.awvalid && vif.awready) |-> (vif.awaddr<128);
             endproperty
                            
                            assert property(p_valid_write_addr)
                              else
                                $error("Write address is out of range");
                              
                              
             property p_valid_read_addr;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               (vif.arvalid && vif.arready) |-> (vif.araddr<128);
             endproperty
                              
                              assert property(p_valid_read_addr)
                                else
                                  $error("Read address is out of range");
                                
                                
             property p_rdata_stable;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               vif.rvalid && !vif.rready |=> $stable(vif.rdata);
             endproperty 
                                
                      
                                assert property(p_rdata_stable)
                                  else
                                    $error("RDATA changed before read transaction completed");
                              
                       
             property p_no_unknown;
               @(posedge vif.clk)
               disable iff(!vif.resetn)
               !$isunknown({
                            vif.awvalid,
                            vif.awready,
                            vif.wvalid,
                            vif.wready,
                            vif.bvalid,
                            vif.bready,
                            vif.arvalid,
                            vif.arready,
                            vif.rvalid,
                            vif.rready
                          });
             endproperty

                                  assert property(p_no_unknown)
                                    else
                                      $error("Unknown (X/Z) detected on AXI protocol");
                                    endmodule

                 
