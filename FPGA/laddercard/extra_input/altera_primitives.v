module    dffe    (
    prn,
    clrn,
    d,
    clk,
    q,
    ena);



    input    prn;
    input    clrn;
    input    d;
    input    clk;
    output    q;
    input    ena;

endmodule //dffe

module    carry_sum    (
    sin,
    sout,
    cout,
    cin);



    input    sin;
    output    sout;
    output    cout;
    input    cin;

endmodule //carry_sum

module    soft    (
    out,
    in);



    output    out;
    input    in;

endmodule //soft

module    cascade    (
    out,
    in);



    output    out;
    input    in;

endmodule //cascade

module    latch    (
    q,
    ena,
    d);



    output    q;
    input    ena;
    input    d;

endmodule //latch

module    TRI    (
    out,
    oe,
    in);



    output    out;
    input    oe;
    input    in;

endmodule //TRI

module    dffeas    (
    devclrn,
    prn,
    clrn,
    d,
    sclr,
    sload,
    asdata,
    devpor,
    clk,
    q,
    aload,
    ena);

    parameter    is_wysiwyg    =    "false";
    parameter    power_up    =    "DONT_CARE";


    input    devclrn;
    input    prn;
    input    clrn;
    input    d;
    input    sclr;
    input    sload;
    input    asdata;
    input    devpor;
    input    clk;
    output    q;
    input    aload;
    input    ena;

endmodule //dffeas

