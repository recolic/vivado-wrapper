`include "macro.vh"

module test_main (
    output wire _j
);
    wire _j_tmp = `TEST_MACRO;
    test_lib _0(_j_tmp, _j);
endmodule
