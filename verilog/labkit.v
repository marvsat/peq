/* *********************** *
 * Parametric Equalizer    *
 * J. Colosimo             *
 * 6.111 - Fall '10        *
 * *********************** */

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2006-Mar-08: Corrected default assignments to "vga_out_red", "vga_out_green"
//              and "vga_out_blue". (Was 10'h0, now 8'h0.)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   /*
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input
   */

   // VGA Output
   /*
   assign vga_out_red = 8'h0;
   assign vga_out_green = 8'h0;
   assign vga_out_blue = 8'h0;
   assign vga_out_sync_b = 1'b1;
   assign vga_out_blank_b = 1'b1;
   assign vga_out_pixel_clock = 1'b0;
   assign vga_out_hsync = 1'b0;
   assign vga_out_vsync = 1'b0;
   */

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   /*
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   // disp_data_in is an input
   */

   // Buttons, Switches, and Individual LEDs
   assign led[3:1] = 3'b111;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs


   /* **************************************
    * PARAMETRIC EQUALIZER HARDWARE
      ************************************** */
   
    //////////////////////////////////
    // 65MHz clock (from lab 5)
    //////////////////////////////////
        // use FPGA's digital clock manager to produce a
        // 65MHz clock (actually 64.8MHz)
        wire clock_65mhz_unbuf,clock_65mhz;
        DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
        // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
        // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
        // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
        // synthesis attribute CLKIN_PERIOD of vclk1 is 37
        BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));


    //////////////////////////////////
    // power-on reset generation (from lab 5)
    //////////////////////////////////
        wire power_on_reset;    // remain high for first 16 clocks
        SRL16 reset_sr (.D(1'b0), .CLK(clock_27mhz), .Q(power_on_reset),
                .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
        defparam reset_sr.INIT = 16'hFFFF;

    //////////////////////////////////
    // debounce buttons (from many labs)
    //////////////////////////////////
        wire btn_rst, btn_add, btn_left, btn_right, btn_up, btn_down, btn_vup, btn_vdn;
        wire btn_a, btn_b, btn_c;
        debounce db1(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button3),.clean(btn_rst));
        debounce db2(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button_enter),.clean(btn_add));
        debounce db3(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button_left),.clean(btn_left));
        debounce db4(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button_right),.clean(btn_right));
        debounce db5(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button_up),.clean(btn_up));
        debounce db6(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button_down),.clean(btn_down));
        debounce db7(.reset(power_on_reset), .clock(clock_27mhz), .noisy(~button_right), .clean(btn_vup));
        debounce db8(.reset(power_on_reset), .clock(clock_27mhz), .noisy(~button_left), .clean(btn_vdn));
        debounce db9(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button2),.clean(btn_a));
        debounce db10(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button1),.clean(btn_b));
        debounce db11(.reset(power_on_reset),.clock(clock_27mhz),.noisy(~button0),.clean(btn_c));

    //////////////////////////////////
    // vga controller (from lab 5)
    //////////////////////////////////
        // generate basic XVGA video signals
        wire [10:0] hcount;
        wire [9:0]  vcount;
        wire [2:0] pixel;
        wire hsync,vsync,blank;

        // pipelined syncs
        wire phsync,pvsync,pblank;

        xvga xvga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
                   .hsync(hsync),.vsync(vsync),.blank(blank));

        // VGA Output.  In order to meet the setup and hold times of the
        // AD7125, we send it ~clock_65mhz.
        assign vga_out_red = {8{pixel[2]}};
        assign vga_out_green = {8{pixel[1]}};
        assign vga_out_blue = {8{pixel[0]}};
        assign vga_out_sync_b = 1'b1;    // not used
        assign vga_out_blank_b = ~pblank;
        assign vga_out_pixel_clock = ~clock_65mhz;
        assign vga_out_hsync = phsync;
        assign vga_out_vsync = pvsync;

    //////////////////////////////////
    // 16-digit hex display (from lab 3)
    //////////////////////////////////
        wire [15:0] hexdisplayinput;
        wire [15:0] hexdebug, hexdebug2;
        display_16hex hexdisplay(.reset(power_on_reset), .clock_27mhz(clock_27mhz),
            .data({hexdebug, hexdebug2, 16'h0000, hexdisplayinput}),
            .disp_blank(disp_blank), .disp_clock(disp_clock),
            .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_reset_b(disp_reset_b),
            .disp_data_out(disp_data_out));

    //////////////////////////////////
    // ac97 control module (from labkit audio test)
    //////////////////////////////////
        wire [3:0] vol;
        wire volume_up, volume_down;

        wire audio_ready;

        wire [15:0] from_ac97_data, to_ac97_data;

        fft_audio audio1 (
            .clock_27mhz(clock_27mhz),
            .reset(power_on_reset), 
            .volume({vol, 1'b0}), 
            .audio_in_data(from_ac97_data), 
            .audio_out_data(to_ac97_data), 
            .ready(audio_ready),
            .audio_reset_b(audio_reset_b), 
            .ac97_sdata_out(ac97_sdata_out),
            .ac97_sdata_in(ac97_sdata_in), 
            .ac97_synch(ac97_synch),
            .ac97_bit_clock(ac97_bit_clock),
            .mode_in(switch[3]), 
            .mode_out(switch[2]),
            .insource(switch[6])
        );

        volume vol1 (power_on_reset, clock_27mhz, btn_vup, btn_vdn, vol);
 
    //////////////////////////////////
    // main parametric equalizer module
    //////////////////////////////////
        wire [11:0] to_ac97_data_adj;
        wire [11:0] from_ac97_data_adj;

        pequalizer peq(
           .clk(clock_27mhz),
           .clk65(clock_65mhz),
           .rst(power_on_reset),

           // serial com
           .rs232_rxd(rs232_rxd),
           
           // buttons
           .btn_rst(btn_rst),
           .btn_add(btn_add),
           .btn_up(btn_up),
           .btn_down(btn_down),
           .btn_a(btn_a),
           .btn_b(btn_b),
           .btn_c(btn_c),
           .sw_inpmtd(switch[1:0]),

           // vga
           .hcount(hcount),
           .vcount(vcount),
           .hsync(hsync),
           .vsync(vsync),
           .blank(blank),
           .pixel(pixel),
           .phsync(phsync),
           .pvsync(pvsync),
           .pblank(pblank),

           // hex display
           .hex(hexdisplayinput),

           // ac97
           .from_ac97_data(from_ac97_data_adj),
           .to_ac97_data(to_ac97_data_adj),
           .audio_ready(audio_ready),

           .ifft_select(switch[7]),
           .fft_delay(4),
           .ifft_reg(switch[5]),

           //debug
           .debug(hexdebug),
           .debug2(hexdebug2),

           .dbg_fftidx(analyzer2_data),
           .dbg_fftdone(analyzer1_data),
           .dbg_fftout(analyzer3_data)
       );

       assign to_ac97_data = {to_ac97_data_adj, 4'b0000};
       assign from_ac97_data_adj = from_ac97_data[15:16-12];

       // debug
       assign led[0] = rs232_rxd;
       assign led[7:6] = switch[7:6];
       assign led[5:4] = ~switch[5:4];

       // Logic Analyzer
       // analyzer1 -> fft index
       // analyzer2 -> {ifft_done, fft_dv, fft_done}
       // analyzer3 -> fft output
       assign analyzer4_data = to_ac97_data;
       assign analyzer1_clock = audio_ready;
       assign analyzer2_clock = audio_ready;
       assign analyzer3_clock = clock_27mhz;
       assign analyzer4_clock = clock_65mhz;
endmodule
