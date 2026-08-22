`ifndef TB_FUNCT_SVH
`define TB_FUNCT_SVH

`include "../design/memory/memory.svh"
`include "tb_define.svh"
`include "tb_typedef.svh"

//////////////
// Function //
//////////////
function automatic t_memory_buffer load_mem_file (
    input   string          i_file_path,
    output  integer         o_line_count
    );
    
    //@ 1. Init Local Variable
    t_memory_buffer         o_buffer_array;
    integer                 file_discriptor = 0;                // File Discriptor
    integer                 status          = 0;                // Flag for Line Read
    integer                 index           = 0;                // 
    string                  line            = "";               // String Data per Line
    reg [`DATA_BIT - 1:0]   temp_buffer     = {`DATA_BIT{1'b0}};// Temporary Buffer

    begin
        o_line_count = 0;
        //@ 2. Open and Check Memory File
        file_discriptor = $fopen(i_file_path, "r");
        //@ 2a. If Cannot Open Memory File:
        if (file_discriptor == 0) begin
            //@ 2a1. Print ERROR Log and finish TestBench;
            $display("[ERROR] Cannot Open File : %s", i_file_path);
            $finish;
        end
        //@ 2b. In All Other Cases:
        else begin
            //@ 2b1. Check File Discriptor
            //@ 2b1a. If File Discriptor's Pointer is not End Point:
            while ($feof(file_discriptor) == 0) begin
                //@ 2b1a1. Read Line Data and Compute Status
                status  = $fgets(line, file_discriptor);
                //@ 2b1a2. Check Line Status
                //@ 2b1a2a. If Status is not Zero:
                if (status != 0) begin
                    //@ 2b1a2a1. Add Line Count
                    o_line_count = o_line_count + 1;
                end
                //@ 2b1a3. Go to 2b1.
            end
            //@ 2b2. Close Memory File
            $fclose(file_discriptor);
        end
        //@ 3. Allocate Output Buffer Array
        o_buffer_array  = new[o_line_count * `WORD_BYTES];
        //@ 4. Re-Open Memory File
        file_discriptor = $fopen(i_file_path, "r");

        //@ 5. Check File Discriptor
        //@ 5a. If File Discriptor's Pointer is not End Point:
        while ($feof(file_discriptor) == 0) begin
            //@ 5a1. Copy Line Data to Temporary Buffer
            status  = $fscanf(file_discriptor, "%h", temp_buffer);
            //@ 5a2. Check Line Status
            //@ 5a2a. If Status is not Zero:
            if (status != 0) begin
                //@ 5a2a1. Copy Temporary Buffer to Output Buffer Array
                integer bytes;
                for (bytes = 0; bytes < `WORD_BYTES; bytes = bytes + 1) begin
                    o_buffer_array[index + bytes] = temp_buffer[(`BYTE_SIZE * bytes) +: `BYTE_SIZE]; 
                end
                //@ 5a2a2. Add Output Buffer Array's Index as WORD_BYTES
                index = index + `WORD_BYTES;
            end
            //@ 5a3. Go to 5.
        end
        //@ 6. Close Memory File
        $fclose(file_discriptor);

        return o_buffer_array;

    end

endfunction

`endif  // TB_FUNCT_SVH
