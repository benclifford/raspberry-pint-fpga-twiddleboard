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

    // keep track of time and location in blink_pattern
    reg [26:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b10101010101010101010101011111111;


    wire rot1_wire;
    wire rot2_wire;


    wire button_debounced;

    debounced_pullup pushbutton(.clk(CLK), .pin(PIN_14), .out(button_debounced));

    pullup rot1 (.pin(PIN_15), .v(rot1_wire));
    pullup rot2 (.pin(PIN_16), .v(rot2_wire));
 
    // increment the blink_counter every clock
    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;
    end

    reg [3:0] num;

    always @(posedge button_debounced) begin
      num <= num + 1;
    end

    assign LED = num[0];
    assign PIN_1 = num[1];
    assign PIN_2 = num[2];
    assign PIN_3 = num[3];
    // assign PIN_1 = num[0:1] == 1;
    // assign PIN_2 = num[0:1] == 2;
    // assign PIN_3 = num[0:1] == 3;
/*
    // light up the LED according to the pattern
    assign LED = (blink_counter[23] && blink_counter[26])
              || ((!blink_counter[26]) && blink_counter[10]
                 && blink_counter[11] && blink_counter[12]
                 && blink_counter[21] && blink_counter[9]);

    // also output this on pin 1
    assign PIN_1 = blink_counter[25] && blink_counter[23];
    assign PIN_2 = (~PIN_1) && blink_counter[20];
    assign PIN_3 = blink_counter[20];
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

parameter BITS = 9; // bits of counter
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
      counter <= 9'b0;
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

