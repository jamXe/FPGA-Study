//---------------------------------------------------------------------------
//-- �ļ���		:	zircon_avalon_ps2_keyboard_logic.v
//-- ����		:	PS/2����IP�˵�Ӳ���߼��ļ�
//-- �޶���ʷ	:	2014-1-1
//-- ����		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_keyboard_logic
(
	//ʱ�Ӹ�λ
	clock,reset,
	//����ܽ����
	ps2_clk_in,ps2_data_in,  
	//�û��߼����������
	continued_press,shift_key_on,ascii_output,interrupt,rx_read
);  
  
input 				clock;          					//ϵͳʱ��
input 				reset;          					//ϵͳ��λ
input 				ps2_clk_in;        				//PS/2ʱ����,�����
input 				ps2_data_in;          			//PS/2������,�����
output 				continued_press;         		//�������°�����־λ
output 				shift_key_on;	    				//shift��״̬��־
output 	[7:0] 	ascii_output;						//��PS/2�ж�����ASICC����
output				interrupt;      					//avalon�ж��ź�
input 				rx_read;       					//Avalon��������������ߵ�ʹ�ܱ�־λ

reg 					continued_press;					//�������°�����־λ
reg 					continued_press_n;				//continued_press����һ��״̬
reg 		[7:0] 	ascii_output;						//��PS/2�ж�����ASICC����
reg 		[7:0] 	ascii_output_n;					//ascii_out����һ��״̬
reg					interrupt;							//avalon�ж��ź�
reg 					interrupt_n;						//interrupt����һ��״̬
reg 					sync_ps2_clk;     				//ͬ��PS/2ʱ���ź�
reg 					sync_ps2_data;    				//ͬ��PS/2�����ź�
reg 		[ 1:0] 	fsm_cs;        					//״̬���ĵ�ǰ״̬
reg 		[ 1:0] 	fsm_ns;								//״̬������һ��״̬
reg 		[ 3:0] 	bit_count;       					//��λ������
reg 		[ 3:0] 	bit_count_n;       				//bit_count����һ��״̬
reg 		[14:0] 	time_cnt_400us; 					//400us������
reg 		[14:0] 	time_cnt_400us_n; 				//time_cnt_400us����һ��״̬
reg 					time_cnt_400us_done;				//400us��������ɱ�ʶλ
reg 					time_cnt_400us_done_n;			//time_cnt_400us_done����һ��״̬
reg 		[10:0] 	read_data;   						//��λ�Ĵ��������ڽ���ps2����     
reg 		[10:0] 	read_data_n;   					//read_data����һ��״̬
reg 					hold_released; 					//����ԭ�ȵ�ֵ
reg 					hold_released_n; 					//hold_released����һ��״̬
reg 					left_shift_key;      			//��SHIFT����־
reg 					left_shift_key_n;      			//left_shift_key����һ��״̬
reg 					right_shift_key;     			//��SHIFT����־
reg 					right_shift_key_n;     			//right_shift_key����һ��״̬
reg 		[ 6:0] 	ascii;           					//ASCII��

wire 					read_data_done; 					//����һ֡������ɱ�ʶλ
wire 					output_strobe; 					//�յ����̷��͹�����һ֡������λ,��0xF0��SHIFT��ֵ 
wire 					released;          				//�����־    
wire 		[ 8:0] 	shift_key_plus_code; 			//����shift��״̬��ɨ����

//״̬����״̬������
parameter   		FSM_CLK_LOW  		= 2'd0,		//��ʱ�ӵ͵�ƽ
						FSM_CLK_HIGH  		= 2'd1,		//��ʱ�Ӹߵ�ƽ
						FSM_FALLING_EDGE	= 2'd2,		//��ʱ���½��ر�־
						FSM_RISING_EDGE 	= 2'd3;		//��ʱ�������ر�־


//ͬ��PS/2������ʱ��
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		sync_ps2_clk <= 1'b0;					
	else
		sync_ps2_clk <= ps2_clk_in;			
end

//ͬ��PS/2�������ź�
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		sync_ps2_data <= 1'b0;					
	else
		sync_ps2_data <= ps2_data_in;			
end
				
//ʱ���·,������fsm_cs��ֵ��
always @ (posedge clock or negedge reset)
begin 
	if(!reset) 
		fsm_cs <= FSM_CLK_HIGH;
	else 
		fsm_cs <= fsm_ns;
end

//��ϵ�·,��PS/2���̶����ݵ�������״̬��
always @ (*)
begin 
	case (fsm_cs)
		FSM_CLK_LOW:			//��״̬ʱ�ӵ͵�ƽ
		begin
			if(sync_ps2_clk) 
				fsm_ns = FSM_RISING_EDGE;
			else 
				fsm_ns = FSM_CLK_LOW;
		end
 
		FSM_CLK_HIGH:			//��״̬ʱ�Ӹߵ�ƽ
		begin
			if(!sync_ps2_clk)                      
				fsm_ns = FSM_FALLING_EDGE;  
			else
				fsm_ns = FSM_CLK_HIGH;
		end

		FSM_FALLING_EDGE:		//��״̬ʱ���½��ر�־
		begin
			fsm_ns = FSM_CLK_LOW;
		end

		FSM_RISING_EDGE:		//��״̬ʱ�������ر�־
		begin
			fsm_ns = FSM_CLK_HIGH;
		end

		default: fsm_ns = FSM_CLK_HIGH; 
	endcase
end

//ʱ���·,������time_cnt_400us��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		time_cnt_400us <= 1'b0;
	else
		time_cnt_400us <= time_cnt_400us_n;
end

//��ϵ�·,400us��ʱ��������
always @ (*)
begin
	if(!((fsm_cs == FSM_CLK_HIGH) || (fsm_cs == FSM_CLK_LOW))) 
		time_cnt_400us_n = 1'b0;
	else if(!time_cnt_400us_done) 
		time_cnt_400us_n = time_cnt_400us + 1;
	else 
		time_cnt_400us_n = time_cnt_400us;
end

//ʱ���·,������time_cnt_400us_done��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		time_cnt_400us_done <= 1'b0;
	else
		time_cnt_400us_done <= time_cnt_400us_done_n;
end

//��ϵ�·,400us��ʱ��ɱ�ʶλ
always @ (*)
begin
	if(time_cnt_400us == 15'd19199) 
		time_cnt_400us_done_n = 1'b1;
	else
    	time_cnt_400us_done_n = 1'b0;
end

//ʱ���·,��bit_count��ֵ
always @ (posedge clock or negedge reset)
begin
	if(!reset)
		bit_count <= 4'd0;
	else
		bit_count <= bit_count_n;
end

//��ϵ�·,��λ������
always @ (*)
begin
	if(read_data_done)
		bit_count_n = 4'd0;  
	else if(time_cnt_400us_done && (fsm_cs == FSM_CLK_HIGH) && (sync_ps2_clk)) 
		bit_count_n = 4'd0; 
	else if(fsm_cs == FSM_FALLING_EDGE)
    	bit_count_n = bit_count + 4'd1;
	else
		bit_count_n = bit_count;
end

//ʱ���·,������read_data��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		read_data <= 11'd0;
	else
    	read_data <= read_data_n;
end

//��ϵ�·,����������λ�Ĵ���,���ڽ���ps2��ֵ
always @ (*)
begin
	if(fsm_cs == FSM_FALLING_EDGE) 
		read_data_n = {sync_ps2_data,read_data[10:1]};
	else
		read_data_n = read_data;
end

//����һ֡������ɱ�ʶλ
assign read_data_done = (bit_count == 4'd11);

//��������־
assign released = (read_data[8:1] == 16'hF0) && read_data_done;

//ʱ���·,������hold_released��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset)     
		hold_released <= 1'b0;
	else
		hold_released <= hold_released_n;
end

//��ϵ�·,�������Ϊ����ʱ����Ӧ��־λ
always @(*)
begin
	if(read_data_done && (!released))     
		hold_released_n = 1'b0;
	else if(read_data_done && released)
		hold_released_n = 1'b1;
end

//ʱ���·,������left_shift_key��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		left_shift_key <= 1'b0;
	else
		left_shift_key <= left_shift_key_n;
end

//��ϵ�·,shift�������,��shift��
always @ (*)
begin
	if((read_data[8:1] == 16'h12) && read_data_done && ~hold_released)  //shift��ͨ��
		left_shift_key_n = 1'b1;	
	else if ((read_data[8:1] == 16'h12) && read_data_done && hold_released)   //shift������
    	left_shift_key_n = 1'b0;
	else
		left_shift_key_n = left_shift_key;
end

//ʱ���·,������right_shift_key��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset) 
		right_shift_key <= 1'b0;
	else
		right_shift_key <= right_shift_key_n;
end

//��ϵ�·,shift�������,��shift��
always @ (*)
begin
	if((read_data[8:1] == 16'h59) && read_data_done && ~hold_released)  //shift��ͨ��
		right_shift_key_n = 1'b1;
	else if((read_data[8:1] == 16'h59) && read_data_done && hold_released)   //shift������
    	right_shift_key_n = 1'b0;
	else
		right_shift_key_n = right_shift_key;
end

//���shift״̬��־,���1��shift���а�ס,���0��shift���ް�ס
assign shift_key_on = left_shift_key || right_shift_key;

//�յ����̷��͹����ļ��룬����0xF0������ǰ����0xF0������shift�ļ�ֵ
assign output_strobe = (read_data_done && !(released) 
														&& ( ( (read_data[8:1] != 16'h59)
														&& (read_data[8:1] != 16'h12 ) ) ));
													
//ʱ���·,������interrupt��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		interrupt <= 1'b0;					
	else
		interrupt <= interrupt_n;			
end

//�����ж��ź� interrupt = 1 ʱ�����������interrupt_n = 0 ʱ���������
//��ϵ�·,��ȡ����ʱ(rx_read = 1) interrupt = 0.
always @ (*)
begin
	if(rx_read)							
		interrupt_n = 1'b0;					
	else if(output_strobe)	
		interrupt_n = 1'b1;
	else	
		interrupt_n = interrupt;			
end

//ʱ���·,������continued_press��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		continued_press <= 1'b0;					
	else
		continued_press <= continued_press_n;			
end

//��ϵ�·,����������°�����־λ
always @ (*)
begin
	if(output_strobe)
    	continued_press_n = hold_released;  
	else
		continued_press_n = continued_press;
end

//ʱ���·,������ascii_output��ֵ��
always @ (posedge clock or negedge reset)
begin
	if(!reset)							
		ascii_output <= 1'b0;					
	else
		ascii_output <= ascii_output_n;			
end

//��ϵ�·,���ASICC����
always @ (*)
begin
	if(output_strobe)
    	ascii_output_n = {1'b0,ascii};    //����֮ǰ�����״ֵ̬
	else
		ascii_output_n = ascii_output;
end

//�ⲿ�ֽ����̵�ɨ����ת�ҳ�ASCII�룬����ֻ����һ���֣������Ҫ
//���Ӹ���ļ��룬�����ҵ���ص�ɨ��������ӵ�����CASE����С�
assign shift_key_plus_code = {shift_key_on,read_data[8:1]};

//����9'hXXX���λΪ1��ʾ��SHIFT������
always @(shift_key_plus_code)
begin
	casez (shift_key_plus_code)
		9'h?66 : ascii <= 7'h08;  // ɾ���� "backspace"key
		9'h?0d : ascii <= 7'h09;  // Tab��
		9'h?5a : ascii <= 7'h0d;  // �س��� "enter"key
		9'h?76 : ascii <= 7'h1b;  // Escape "esc"key
		9'h?29 : ascii <= 7'h20;  // �ո��"Space"key
		9'h116 : ascii <= 7'h21;  // !
		9'h152 : ascii <= 7'h22;  // "
		9'h126 : ascii <= 7'h23;  // #
		9'h125 : ascii <= 7'h24;  // $
		9'h12e : ascii <= 7'h25;  // %
		9'h13d : ascii <= 7'h26;  // &
		9'h052 : ascii <= 7'h27;  // '
		9'h146 : ascii <= 7'h28;  // (
		9'h145 : ascii <= 7'h29;  // )
		9'h13e : ascii <= 7'h2a;  // *
		9'h155 : ascii <= 7'h2b;  // +
		9'h041 : ascii <= 7'h2c;  // ,
		9'h04e : ascii <= 7'h2d;  // -
		9'h049 : ascii <= 7'h2e;  // .
		9'h04a : ascii <= 7'h2f;  // /
		9'h045 : ascii <= 7'h30;  // 0
		9'h016 : ascii <= 7'h31;  // 1
		9'h01e : ascii <= 7'h32;  // 2
		9'h026 : ascii <= 7'h33;  // 3
		9'h025 : ascii <= 7'h34;  // 4
		9'h02e : ascii <= 7'h35;  // 5
		9'h036 : ascii <= 7'h36;  // 6
		9'h03d : ascii <= 7'h37;  // 7
		9'h03e : ascii <= 7'h38;  // 8
		9'h046 : ascii <= 7'h39;  // 9
		9'h14c : ascii <= 7'h3a;  // :
		9'h04c : ascii <= 7'h3b;  // ;
		9'h141 : ascii <= 7'h3c;  // <
		9'h055 : ascii <= 7'h3d;  // =
		9'h149 : ascii <= 7'h3e;  // >
		9'h14a : ascii <= 7'h3f;  // ?
		9'h11e : ascii <= 7'h40;  // @
		9'h11c : ascii <= 7'h41;  // A
		9'h132 : ascii <= 7'h42;  // B
		9'h121 : ascii <= 7'h43;  // C
		9'h123 : ascii <= 7'h44;  // D
		9'h124 : ascii <= 7'h45;  // E
		9'h12b : ascii <= 7'h46;  // F
		9'h134 : ascii <= 7'h47;  // G
		9'h133 : ascii <= 7'h48;  // H
		9'h143 : ascii <= 7'h49;  // I
		9'h13b : ascii <= 7'h4a;  // J
		9'h142 : ascii <= 7'h4b;  // K
		9'h14b : ascii <= 7'h4c;  // L
		9'h13a : ascii <= 7'h4d;  // M
		9'h131 : ascii <= 7'h4e;  // N
		9'h144 : ascii <= 7'h4f;  // O
		9'h14d : ascii <= 7'h50;  // P
		9'h115 : ascii <= 7'h51;  // Q
		9'h12d : ascii <= 7'h52;  // R
		9'h11b : ascii <= 7'h53;  // S
		9'h12c : ascii <= 7'h54;  // T
		9'h13c : ascii <= 7'h55;  // U
		9'h12a : ascii <= 7'h56;  // V
		9'h11d : ascii <= 7'h57;  // W
		9'h122 : ascii <= 7'h58;  // X
		9'h135 : ascii <= 7'h59;  // Y
		9'h11a : ascii <= 7'h5a;  // Z
		9'h054 : ascii <= 7'h5b;  // [
		9'h05d : ascii <= 7'h5c;  // '\'
		9'h05b : ascii <= 7'h5d;  // ]
		9'h136 : ascii <= 7'h5e;  // ^
		9'h14e : ascii <= 7'h5f;  // _    
		9'h00e : ascii <= 7'h60;  // `
		9'h01c : ascii <= 7'h61;  // a
		9'h032 : ascii <= 7'h62;  // b
		9'h021 : ascii <= 7'h63;  // c
		9'h023 : ascii <= 7'h64;  // d
		9'h024 : ascii <= 7'h65;  // e
		9'h02b : ascii <= 7'h66;  // f
		9'h034 : ascii <= 7'h67;  // g
		9'h033 : ascii <= 7'h68;  // h
		9'h043 : ascii <= 7'h69;  // i
		9'h03b : ascii <= 7'h6a;  // j
		9'h042 : ascii <= 7'h6b;  // k
		9'h04b : ascii <= 7'h6c;  // l
		9'h03a : ascii <= 7'h6d;  // m
		9'h031 : ascii <= 7'h6e;  // n
		9'h044 : ascii <= 7'h6f;  // o
		9'h04d : ascii <= 7'h70;  // p
		9'h015 : ascii <= 7'h71;  // q
		9'h02d : ascii <= 7'h72;  // r
		9'h01b : ascii <= 7'h73;  // s
		9'h02c : ascii <= 7'h74;  // t
		9'h03c : ascii <= 7'h75;  // u
		9'h02a : ascii <= 7'h76;  // v
		9'h01d : ascii <= 7'h77;  // w
		9'h022 : ascii <= 7'h78;  // x
		9'h035 : ascii <= 7'h79;  // y
		9'h01a : ascii <= 7'h7a;  // z
		9'h154 : ascii <= 7'h7b;  // {
		9'h15d : ascii <= 7'h7c;  // |
		9'h15b : ascii <= 7'h7d;  // }
		9'h10e : ascii <= 7'h7e;  // ~
		9'h?71 : ascii <= 7'h7f;  //  Delete����С���̵�DEL��
		default: ascii <= 7'h2e;  // '.' ��������û�г����ַ�
	endcase
end

endmodule
