interface APB3 ();

    wire [31:0] PADDR;
    wire        PENABLE;
    wire        PWRITE;
    wire [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;

    modport MASTER (
        input   PREADY, PSLVERR, PRDATA,
        output  PADDR, PENABLE, PWRITE, PWDATA
    );

    modport SLAVE (
        input   PADDR, PENABLE, PWRITE, PWDATA,
        output  PREADY, PSLVERR, PRDATA
    );

endinterface
