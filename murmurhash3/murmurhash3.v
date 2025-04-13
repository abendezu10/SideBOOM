module murmurhash3 #(parameter LENGTH = 0, parameter [31:0] SEED = 32'h0)(
    input  wire                 clk,
    input  wire                 resetn,
    input  wire [1599:0]        key,
    output reg [127:0]         data_o
);

// example key = 0x61 0x62 0x63 

function [63:0] ROTL64;
    input  [63:0] x;
    input  [7:0]  r;
begin
    ROTL64 = (x << r) | (x >> (64 - r));
end

endfunction

function [63:0] fmix64;
    input  [63:0] k;
begin
    k = k ^ (k>>33);
    k = k * 128'h0000000000000000ff51afd7ed558ccd;
    k = k ^ (k>>33);
    k = k * 128'h0000000000000000c4ceb9fe1a85ec53;
    k = k ^ (k>>33);
    fmix64 = k;

end

endfunction

function [255:0] k2_process;
    input [127:0] tail;
    input [63:0] num_k1;
    input [63:0] num_k2;
    input [63:0] num_h1;
    input [63:0] num_h2;
    input [127:0] c1;
    input [127:0] c2;

    reg [63:0] k1, k2, h1, h2;
    reg [255:0] tail_process;

    begin
        k1 = num_k1;
        k2 = num_k2;
        h1 = num_h1;
        h2 = num_h2;

      
        if ((LENGTH & 15) >= 1)  k1 = k1 ^ ({56'd0, tail[8*0 +: 8]} << 0);
        if ((LENGTH & 15) >= 2)  k1 = k1 ^ ({56'd0, tail[8*1 +: 8]} << 8);
        if ((LENGTH & 15) >= 3)  k1 = k1 ^ ({56'd0, tail[8*2 +: 8]} << 16);  
        if ((LENGTH & 15) >= 4)  k1 = k1 ^ ({56'd0, tail[8*3 +: 8]} << 24);

        if ((LENGTH & 15) >= 5)  k1 = k1 ^ ({56'd0, tail[8*4 +: 8]} << 32);
        if ((LENGTH & 15) >= 6)  k1 = k1 ^ ({56'd0, tail[8*5 +: 8]} << 40);
        if ((LENGTH & 15) >= 7)  k1 = k1 ^ ({56'd0, tail[8*6 +: 8]} << 48);
        if ((LENGTH & 15) >= 8)  k1 = k1 ^ ({56'd0, tail[8*7 +: 8]} << 56);

        k1 = k1 * c1;
        k1 = ROTL64(k1,31);
        k1 = k1 * c2;
        h1 = h1 ^ k1; 
        
        //$display("%d", k2);
       
        if ((LENGTH & 15) >= 9)  k2 = k2 ^ ({56'd0, tail[8*8 +: 8]} << 0);
        if ((LENGTH & 15) >= 10) k2 = k2 ^ ({56'd0, tail[8*9 +: 8]} << 8);
        if ((LENGTH & 15) >= 11) k2 = k2 ^ ({56'd0, tail[8*10 +: 8]} << 16);
        if ((LENGTH & 15) >= 12) k2 = k2 ^ ({56'd0, tail[8*11 +: 8]} << 24);
        if ((LENGTH & 15) >= 13) k2 = k2 ^ ({56'd0, tail[8*12 +: 8]} << 32);
        if ((LENGTH & 15) >= 14) k2 = k2 ^ ({56'd0, tail[8*13 +: 8]} << 40);
        if ((LENGTH & 15) >= 15) k2 = k2 ^ ({56'd0, tail[8*14 +: 8]} << 48);

        k2 = k2 * c2;
        k2 = ROTL64(k2,33);
        k2 = k2 * c1;
        h2 = h2 ^ k2;
        //$display("%d", k2);
       
       tail_process = {k2, k1, h2, h1};
        k2_process = tail_process;
    end
endfunction


reg [63:0] data;

reg [31:0] nblocks;

reg [63:0] h1;
reg [63:0] h2;
reg [63:0] blocks;
reg [63:0] k1;
reg [63:0] k2;
reg [5:0]  state;
reg [127:0] tail;
reg [255:0] values;


integer i;

localparam c1 = 128'h000000000000000087c37b91114253d5;
localparam c2 = 128'h00000000000000004cf5ad432745937f;
 

localparam INIT_STATE    = 6'd0;
localparam K1_OP1A_STATE  = 6'd1;
localparam K1_OP1B_STATE  = 6'd27;
localparam K1_OP2_STATE  = 6'd2;
localparam K1_OP3_STATE  = 6'd3;
localparam H1_OP1_STATE  = 6'd4;
localparam H1_OP2_STATE  = 6'd5;
localparam H1_OP3_STATE  = 6'd6;
localparam H1_OP4_STATE  = 6'd7;
localparam K2_OP1_STATE  = 6'd8;
localparam K2_OP2_STATE  = 6'd9;
localparam K2_OP3_STATE  = 6'd10;
localparam H2_OP1_STATE  = 6'd11;
localparam H2_OP2_STATE  = 6'd12;
localparam H2_OP3_STATE  = 6'd13;
localparam H2_OP4_STATE  = 6'd14;
localparam TAIL_INIT     = 6'd15;
localparam TAIL_FUNC     = 6'd16;
localparam TAIL_FIN      = 6'd17;
localparam FIN1_STATE    = 6'd18;
localparam FIN2A_STATE   = 6'd19;
localparam FIN2B_STATE   = 6'd20;
//localparam FIN3_STATE    = 6'd21;
localparam FIN4_STATE    = 6'd22;
localparam FIN5_STATE    = 6'd23;
localparam FIN6_STATE    = 6'd24;
localparam FIN7_STATE    = 6'd25;
localparam FIN8_STATE    = 6'd26;



always @(posedge clk or negedge resetn) begin

    if(!resetn) begin
        h1<=SEED;
        h2<=SEED;
        blocks <= key[63:0];
        i <= 0;
        nblocks <= LENGTH >> 4;
        state <= INIT_STATE;
        data <= key[63:0];
    end else begin
        case(state) 
        INIT_STATE: begin
            if(i < nblocks) begin
                state <= K1_OP1A_STATE;
            end else begin
                state <= TAIL_INIT;
            end
        end 

        K1_OP1A_STATE: begin
            
            k1 <= key[(64 * (i*2))+:64];
            k2 <= key[(64 * ((i*2) + 1)) +:64];
            state <=K1_OP1B_STATE;
        end

        K1_OP1B_STATE: begin
            k1 <= k1 * c1;
            state <= K1_OP2_STATE;
        end

        K1_OP2_STATE: begin
            k1 <= ROTL64(k1,31);
            state <= K1_OP3_STATE;
        end

        K1_OP3_STATE: begin
            k1 <= k1 * c2;
            state <= H1_OP1_STATE;
        end

        H1_OP1_STATE: begin
            h1 <= h1 ^ k1;
            state <= H1_OP2_STATE;
        end

        H1_OP2_STATE: begin
            h1 <= ROTL64(h1, 27);
            state <= H1_OP3_STATE;
        end

        H1_OP3_STATE: begin
            h1 <= h1 + h2;
            state <= H1_OP4_STATE;
        end

        H1_OP4_STATE: begin
            h1 <= h1 * 5 + 64'h52dce729;
            state <= K2_OP1_STATE;
        end

        K2_OP1_STATE: begin
            k2<= k2 * c2;
            state <= K2_OP2_STATE;
        end

        K2_OP2_STATE: begin
            k2 <= ROTL64(k2,33);
            state <= K2_OP3_STATE;
        end

        K2_OP3_STATE: begin
            k2 <= k2 * c1;
            state <= H2_OP1_STATE;
        end

        H2_OP1_STATE: begin
            h2 <= h2 ^ k2;
            state <=H2_OP2_STATE;
        end

        H2_OP2_STATE: begin
            h2 <= ROTL64(h2,31);
            state <=H2_OP3_STATE;
        end

        H2_OP3_STATE: begin
            h2 <= h2 + h1;
            state <=H2_OP4_STATE;
        end

        H2_OP4_STATE: begin
            h2 <= h2 * 5 + 64'h38495ab5;
            state <= TAIL_FIN;
            if(i < nblocks) begin
                i <= i + 1;
                state <= INIT_STATE;
            end else begin
                state <= TAIL_INIT;
            end
            
        end

        TAIL_INIT: begin
            k1 <= 0;
            k2 <= 0;
            tail <= key[nblocks * 128 +: 128];
            state <= TAIL_FUNC;
        end

        TAIL_FUNC: begin
            values <= k2_process(tail, k1, k2, h1, h2, c1, c2);
            state <= TAIL_FIN;
        end

        TAIL_FIN: begin
            h1 <= values[63:0];
            h2 <= values[127:64];
            k1 <= values[191:128];
            k2 <= values[255:192];
            state <= FIN1_STATE;
        end

        FIN1_STATE: begin
            $display("k1: %d",k1);
            $display("k2: %d", k2);
            h1 <= h1 ^ LENGTH;
            h2 <= h2 ^ LENGTH;
            state <= FIN2A_STATE;
        end

        FIN2A_STATE: begin
         
            h1 <= h1 + h2;
            state <= FIN2B_STATE;
        end
        
        FIN2B_STATE: begin
            h2 <= h2 + h1;
            state <= FIN4_STATE;
        end


        FIN4_STATE: begin
            h1 <= fmix64(h1);
            state <= FIN5_STATE;
        end

        FIN5_STATE: begin
            h2 <= fmix64(h2);
            state <= FIN6_STATE;
        end

        FIN6_STATE: begin
            h1 <= h1 + h2;
            state <= FIN7_STATE;   
        end

        FIN7_STATE: begin
            h2 <= h2 + h1;
            state <= FIN8_STATE;
        end

        FIN8_STATE: begin
            data_o[63:0] <= h1;
            data_o[127:64] <= h2;
        end

    endcase
 end
end

endmodule
