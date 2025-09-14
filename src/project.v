/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_7FM_ShadyPong (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [3:0] R;
  wire [3:0] G;
  wire [3:0] B;

  // User input
  wire player1YUp, player1YDown, player2YUp, player2YDown;
  wire [3:0] btns;
  assign btns = {player1YUp, player1YDown, player2YUp, player2YDown};

  assign player1YUp = ui_in[0];
  assign player1YDown = ui_in[1];
  assign player2YUp = ui_in[2];
  assign player2YDown = ui_in[3];

  // Force
  wire forceFallback = ui_in[4];

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Dummy outputs
  assign uio_out = 8'b0;
  // We need more inputs
  assign uio_oe = {8{1'b0}};

  reg [3:0] ballSpeed, playerSpeed;
  always @(posedge clk) begin
    ballSpeed <= forceFallback ? 4 : uio_in[3:0];
    playerSpeed <= forceFallback ? 4 : uio_in[7:4];
  end

  top shadyPong(
    .CLK(clk),
    .rst_n(rst_n),
    .ballSpeed(ballSpeed),
    .playerSpeed(playerSpeed),
    .vga_h_sync(hsync),
    .vga_v_sync(vsync),
    .vga_R(R),
    .vga_G(G),
    .vga_B(B),
    .btns(btns)
  );


  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:5], 1'b0};

endmodule
