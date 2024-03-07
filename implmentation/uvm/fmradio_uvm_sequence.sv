import uvm_pkg::*;

class fmradio_uvm_transaction extends uvm_sequence_item;
    logic [31:0] audio_bytes;

    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(fmradio_uvm_transaction)
        `uvm_field_int(audio_bytes, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: fmradio_uvm_transaction

class fmradio_uvm_sequence extends uvm_sequence#(fmradio_uvm_transaction);
    `uvm_object_utils(fmradio_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        fmradio_uvm_transaction tx;
        int in_file, n_bytes=0, i=0;
        logic [31:0] audio;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", Filename), UVM_LOW);

        in_file = $fopen(Filename, "rb");
        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", Filename));
        end

        while ( !$feof(in_file) && i < BMP_DATA_SIZE ) begin
            tx = fmradio_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
            start_item(tx);
            n_bytes = $fread(audio, in_file, i, 4);
            tx.audio_bytes = audio;
            //`uvm_info("SEQ_RUN", tx.sprint(), UVM_LOW);
            finish_item(tx);
            i = i+4;
        end

        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", Filename), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: fmradio_uvm_sequence

typedef uvm_sequencer#(fmradio_uvm_transaction) fmradio_uvm_sequencer;
