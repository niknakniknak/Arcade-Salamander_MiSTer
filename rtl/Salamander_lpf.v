//one-pole low pass, y += (x - y) * COEF, state kept as 16.16
//COEF = (1 - exp(-2*pi*fc/fs)) * 65536, fs = the rate i_CEN runs at

module Salamander_lpf #(parameter COEF = 16'd552) (
    input   wire                    i_EMU_MCLK,
    input   wire                    i_EMU_CEN,
    input   wire                    i_RST_n,

    input   wire signed     [15:0]  i_SND,
    output  wire signed     [15:0]  o_SND
);

reg  signed [31:0]  acc;
wire signed [16:0]  err  = $signed({i_SND[15], i_SND}) - $signed({acc[31], acc[31:16]});
wire signed [32:0]  step = err * $signed({1'b0, COEF[15:0]});

always @(posedge i_EMU_MCLK) begin
    if(!i_RST_n) acc <= 32'sd0;
    else if(i_EMU_CEN) acc <= acc + $signed(step);
end

assign o_SND = acc[31:16];

endmodule
