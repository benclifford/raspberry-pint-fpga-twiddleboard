// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    input PIN_14,
    input PIN_15,
    input PIN_16,
    output LED,   // User/boot LED next to power LED
    output PIN_1,
    output PIN_2,
    output PIN_3,
    output USBPU  // USB pull-up resistor
);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    // some symbolic names for LEDs
    wire EXT_LED;
    assign PIN_1 = EXT_LED;

    wire RED_LED;
    assign PIN_2 = RED_LED;

    wire GREEN_LED;
    assign PIN_3 = GREEN_LED;


    reg [26:0] blink_counter;
    always @(posedge CLK)
      blink_counter <= blink_counter + 1;

    wire button_debounced;

    debounced_pullup pushbutton(.clk(CLK), .pin(PIN_14), .out(button_debounced));


    wire rot_a;
    wire rot_b;

    // pullup rot_a_in(.pin(PIN_15), .v(rot_a));
    // pullup rot_b_in(.pin(PIN_16), .v(rot_b));
    debounced_pullup rot_a_in(.clk(CLK), .pin(PIN_15), .out(rot_a));
    debounced_pullup rot_b_in(.clk(CLK), .pin(PIN_16), .out(rot_b));

    wire rot_count_up;
    wire rot_count_down;

    rotary_encoder dial(.clk(CLK), .a(rot_a), .b(rot_b), .counter(rotary_count), .err(error_signal));

    wire [7:0] rotary_count;
    wire error_signal;

    wire blink;
    assign blink = !button_debounced && blink_counter[21];
    assign LED = rotary_count[0] || blink;
    //    assign EXT_LED = rotary_count[1] || blink;
    assign EXT_LED = blink;
    assign RED_LED = (rotary_count[4] ^ rotary_count[5]) || blink;
    assign GREEN_LED = rotary_count[5] || blink;



/*

ctr  green     red
00    0         0 
01    0         1
10    1         1
11    1         0

green = ctr[1]
red = ctr[0] xor ctr[1]
*/

endmodule

module pullup (
    input pin,
    output v 
);

SB_IO #(
  .PIN_TYPE(6'b 0000_01),
  .PULLUP(1'b 1)
) button_input(
  .PACKAGE_PIN(pin),
  .D_IN_0(v)
);

endmodule

module debounce (
  input clk,
  input in,
  output out,
);

parameter BITS = 11; // bits of counter
reg step1;
reg step2;
reg outreg;

always @(posedge clk)
  begin
    step1 <= in;
    step2 <= step1;
  end

wire different;
assign different = step1 ^ step2;

reg [BITS:0] counter;

always @(posedge clk)
  begin
    if(different)
      counter <= 11'b0;
    else
      counter <= counter + 1;
  end

always @(posedge clk)
  begin
    if(counter[BITS-1] == 1'b1)
      outreg <= step2;
    else
      outreg <= outreg;
  end

assign out = outreg;

endmodule


module debounced_pullup(
  input clk,
  input pin,
  output out);

  wire pulled_up;
  debounce pushbutton_debouncer(.clk(clk), .in(pulled_up), .out(out));
  pullup pushbutton (.pin(pin), .v(pulled_up));

endmodule


// rotary_encoder dial(.clk(CLK), .a(rot_a), .b(rot_b), .up(rot_count_up), .down(rot_count_down));
module rotary_encoder (
  input clk,
  input a,
  input b,
  output[7:0] counter,
  output err
);

  reg prev[1:0];
  reg[7:0] counter_reg;
  reg err;

  always @(posedge clk) begin

    prev[0] <= a;
    prev[1] <= b;

    case ( { prev[0], prev[1], a, b } ) 
      4'b0010: counter_reg <= counter_reg + 1;
      4'b1011: counter_reg <= counter_reg + 1;
      4'b1101: counter_reg <= counter_reg + 1;
      4'b0100: counter_reg <= counter_reg + 1;

      4'b0001: counter_reg <= counter_reg - 1;
      4'b0111: counter_reg <= counter_reg - 1;
      4'b1110: counter_reg <= counter_reg - 1;
      4'b1000: counter_reg <= counter_reg - 1;

      4'b0000: counter_reg <= counter_reg;
      4'b0101: counter_reg <= counter_reg;
      4'b1010: counter_reg <= counter_reg;
      4'b1111: counter_reg <= counter_reg;

      // error condition
      default: err <= !err;
    endcase

  end

  assign counter = counter_reg;

endmodule

