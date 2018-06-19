`include "macro.vh"
`ifdef TEST_MACRO
module test_lib(
    input i,
    output wire j
);
    assign j = i * i;
endmodule // test_lib
`else

`endif