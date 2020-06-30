//---------------------------------------------------------------------------
//-- �ļ���		:	zircon_avalon_ps2_mouse_logic.v
//-- ����		:	PS/2���IP�˵�Ӳ���߼��ļ�
//-- �޶���ʷ	:	2014-1-1
//-- ����		:	Zircon Opto-Electronic Technology CO.,Ltd.
//---------------------------------------------------------------------------
module zircon_avalon_ps2_mouse_logic
(
	//ʱ�Ӹ�λ
	clock,reset_n,
	//Avalon-MM�Ӷ˿�
	avs_read,ins_interrupt,	
	//����ܽ����
	ps2_clk_in,ps2_data_in,ps2_clk_out,ps2_data_out,ps2_clk_dir,ps2_data_dir,  
	//�û��߼����������
	left_button,right_button,middle_button,x_increment,y_increment
	
);
  
input 					clock;									//ϵͳʱ��
input 					reset_n;									//ϵͳ��λ
input 					avs_read;								//Avalon�������ź�
output reg				ins_interrupt;							//Avalon�ж��ź�
reg						ins_interrupt_n;						//ins_interrupt����һ��״̬
input 					ps2_clk_in;           				//PS/2ʱ����,�����
input 					ps2_data_in;          				//PS/2������,�����
output reg				ps2_clk_out;  							//PS/2ʱ����,�����
reg						ps2_clk_out_n;  						//ps2_clk_out����һ��״̬
output reg				ps2_data_out; 							//PS/2������,�����
reg 						ps2_data_out_n; 						//ps2_data_out����һ��״̬
output reg 				ps2_clk_dir;         				//PS/2ʱ�ӷ�����ƣ��ߵ�ƽΪ������͵�ƽΪ����
reg 						ps2_clk_dir_n;         				//ps2_clk_dir����һ��״̬
output reg				ps2_data_dir;        				//PS/2���ݷ�����ƣ��ߵ�ƽΪ������͵�ƽΪ����
reg						ps2_data_dir_n;        				//ps2_data_dir����һ��״̬
output reg				left_button;							//��������־λ
reg 						left_button_n;							//left_button����һ��״̬
output reg				right_button;							//����Ҽ���־λ
reg 						right_button_n;						//right_button����һ��״̬
output reg				middle_button;							//����м���־λ
reg 						middle_button_n;						//middle_button����һ��״̬
output reg	[ 8:0] 	x_increment;							//X������
reg 			[ 8:0] 	x_increment_n;							//x_increment����һ��״̬
output reg	[ 8:0] 	y_increment;							//Y������
reg 			[ 8:0] 	y_increment_n;							//y_increment����һ��״̬

reg 			[32:0] 	read_data;  							//��λ�Ĵ���
reg 			[32:0] 	read_data_n;  							//read_data����һ��״̬
reg 			[ 2:0] 	fsm_cs1;									//״̬��1�ĵ�ǰ״̬
reg 			[ 2:0] 	fsm_ns1;									//״̬��1����һ��״̬
reg 			[ 3:0] 	fsm_cs2;									//״̬��2�ĵ�ǰ״̬
reg 			[ 3:0] 	fsm_ns2;									//״̬��2����һ��״̬
reg 			[ 5:0] 	bit_count;                			//���ͽ��������ǵ�λ������
reg 			[ 5:0] 	bit_count_n;                		//bit_conut����һ��״̬
reg 			[14:0] 	watchdog_time_cnt; 					//���Ź���ʱ��
reg 			[14:0] 	watchdog_time_cnt_n; 				//watchdog_time_cnt����һ��״̬
reg 			[ 7:0]   time_cnt_5us;        				//5us��ʱ��
reg 			[ 7:0]   time_cnt_5us_n;         			//time_cnt_5us����һ��״̬
reg 						sync_ps2_clk;     					//ͬ�����PS2ʱ��
reg 						sync_ps2_data;    					//ͬ�����PS2����
reg 						sync_clk;         					//�˲����PS2ʱ��
reg 						sync_clk_n;         					//sync_clk����һ��״̬
reg 						rising_edge;      					//PS2ʱ�������ر�־
reg 						rising_edge_n;      					//rising_edge����һ��״̬
reg 						falling_edge;     					//PS2ʱ���½��ر�־
reg 						falling_edge_n;     					//falling_edge����һ��״̬
reg						data_ready;								//�����Ѿ���ȷ�յ� 
reg 						data_ready_n;							//data_ready����һ��״̬

wire 						watchdog_time_cnt_done; 			//���Ź�״ָ̬ʾ
wire 						time_cnt_5us_done;      			//������ʱ����
wire 						packet_good;         				//���ݰ���ȷ

//״̬��1�Ĳ�����
parameter				FSM_CLK_HIGH     		= 3'b000,	//ʱ�Ӹߵ�ƽ
							FSM_FALLING_EDGE		= 3'b001,	//ʱ���½��ر�־
							FSM_FALLING_WAIT		= 3'b011,	//ʱ���½��صȴ�
							FSM_CLK_LOW  			= 3'b010,	//ʱ�ӵ͵�ƽ
							FSM_RISING_EDGE		= 3'b110,	//ʱ�������ر�־
							FSM_RISING_WAIT		= 3'b100;	//ʱ�������صȴ�

//״̬��2�Ĳ�����
parameter 				FSM_RESET				= 4'b0000,	//��λ��,�������PS2���
							FSM_WAIT 				= 4'b0001,	//�ȴ�״̬
							FSM_GATHER 		 		= 4'b0011,	//�ж������Ƿ�����
							FSM_VERIFY 				= 4'b0010,	//�������ݰ��Ƿ���ȷ
							FSM_USE 			 		= 4'b0110,	//���ݰ���ȷ
							FSM_HOLD_CLK_LOW 		= 4'b0111,	//����ʱ����400US��׼����������
							FSM_DATA_LOW_1 		= 4'b0101,	//������ʼλ"0",d[0],d[1]
							FSM_DATA_HIGH_1		= 4'b0100,	//����λd[2]
							FSM_DATA_LOW_2 		= 4'b1100,	//����λd[3]
							FSM_DATA_HIGH_2		= 4'b1101,	//����λd[4],d[5],d[6],d[7]
							FSM_DATA_LOW_3 		= 4'b1001,	//������żУ��λ
							FSM_DATA_HIGH_3		= 4'b1011,	//ֹͣλ"1",Ӧ����
							FSM_AWAIT_RESPONSE	= 4'b1010;	//�ȴ��ظ�״̬

//ͬ��PS/2������ʱ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)							
		sync_ps2_clk <= 1'b0;					
	else
		sync_ps2_clk <= ps2_clk_in;			
end

//ͬ��PS/2�������ź�
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)							
		sync_ps2_data <= 1'b0;					
	else
		sync_ps2_data <= ps2_data_in;			
end

//ʱ���·,������fsm_cs1��ֵ��
always @ (posedge clock or negedge reset_n)
begin 
	if(!reset_n == 1'b1) 
		fsm_cs1 <= FSM_CLK_HIGH;
	else 
		fsm_cs1 <= fsm_ns1;
end

//��ϵ�·,ͬ��PS2ʱ�ӣ���PS2��ʱ�ӱ��ز������ر�־
always @ (*)
begin 
	case(fsm_cs1)
	
		FSM_CLK_HIGH:				//ʱ�Ӹߵ�ƽ
		begin

			if(~sync_ps2_clk)
				fsm_ns1 <= FSM_FALLING_EDGE;
			else 
				fsm_ns1 <= FSM_CLK_HIGH;
		end

		FSM_FALLING_EDGE:			//ʱ���½���
		begin
			fsm_ns1 <= FSM_FALLING_WAIT;
		end

		FSM_FALLING_WAIT:			//�ȴ�5US��ʱ��ֹë�̸���
		begin
			if(time_cnt_5us_done) 
				fsm_ns1 <= FSM_CLK_LOW;
			else 
				fsm_ns1 <= FSM_FALLING_WAIT;
		end

		FSM_CLK_LOW:       		//ʱ�ӵ͵�ƽ
		begin
			if(sync_ps2_clk)
				fsm_ns1 <= FSM_RISING_EDGE;
			else 
				fsm_ns1 <= FSM_CLK_LOW;
			end

		FSM_RISING_EDGE:    		//ʱ��������
		begin
			fsm_ns1 <= FSM_RISING_WAIT;
		end

		FSM_RISING_WAIT:  		//�ȴ�5US��ʱ��ֹë�̸���
		begin
			if(time_cnt_5us_done) 
				fsm_ns1 <= FSM_CLK_HIGH;
			else 
				fsm_ns1 <= FSM_RISING_WAIT;
			end

		default : fsm_ns1 <= FSM_CLK_HIGH;
	endcase
end

//ʱ���·,������falling_edge��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		falling_edge <= 1'b0;
	else
		falling_edge <= falling_edge_n;
end

//��ϵ�·,�����½���
always @ (*)
begin
	if(fsm_cs1 == FSM_FALLING_EDGE)
		falling_edge_n = 1'b1;
	else
		falling_edge_n = 1'b0;
end

//ʱ���·,������rising_edge��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		rising_edge <= 1'b0;
	else
		rising_edge <= rising_edge_n;
end

//��ϵ�·,����������
always @ (*)
begin
	if(fsm_cs1 == FSM_RISING_EDGE)
		rising_edge_n = 1'b1;
	else
		rising_edge_n = 1'b0;
end

//ʱ���·,������sync_clk��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		sync_clk <= 1'b0;
	else
		sync_clk <= sync_clk_n;
end

//��ϵ�·,����״̬��ͬ�����ʱ��
always @ (*)
begin
	if((fsm_cs1 == FSM_CLK_HIGH) || (fsm_cs1 == FSM_RISING_WAIT))
		sync_clk_n = 1'b1;
	else
		sync_clk_n = 1'b0;
end

//ʱ���·,������fsm_cs2��ֵ��
always @ (posedge clock or negedge reset_n)
begin 
	if(!reset_n == 1'b1) 
		fsm_cs2 <= FSM_RESET;
	else 
		fsm_cs2 <= fsm_ns2;
end

//��ϵ�·,��ʼ��PS2��꣬����PS2������ݰ�
always @ (*)
begin 
	case(fsm_cs2)
  
		FSM_RESET: 					//��λ��,�������PS2���
		begin
			fsm_ns2 = FSM_HOLD_CLK_LOW;
		end

		FSM_WAIT:     
		begin
			if(falling_edge) 
				fsm_ns2 = FSM_GATHER;
			else
				fsm_ns2 = FSM_WAIT;
		end

		FSM_GATHER:        		//�ж������Ƿ�����
		begin
			if(watchdog_time_cnt_done && (bit_count == 6'd33))
				fsm_ns2 = FSM_VERIFY;
			else if(watchdog_time_cnt_done && (bit_count < 6'd33))
				fsm_ns2 = FSM_HOLD_CLK_LOW;
			else
				fsm_ns2 = FSM_GATHER;
		end

		FSM_VERIFY:         		//�������ݰ��Ƿ���ȷ
		begin
			if(packet_good) 
				fsm_ns2 = FSM_USE;
			else 
				fsm_ns2 = FSM_WAIT;
		end

		FSM_USE:            		//���ݰ���ȷ
		begin
			fsm_ns2 = FSM_WAIT;
		end

//��λ�����ʱ��������״̬,������PS2���͸�λָ��0xFF,PS2����յ�
//��λָ��ʱӦ��0xFA,��Լ360mS���������Լ�,�Լ�ɹ�����0xAA,
//���ɹ�����0xFC;Ȼ����ID��0x00.֮�����Stream ģʽStream ģʽ.
//��ʱPS2���Ĭ������Ϊ:��������100 ������/��;�ֱ���4 ������ֵ/����;
//���ű���1:1;���ݱ��汻��ֹ,Ϊ�򻯳���,���޸�Ĭ�����ԡ�
//�����0xF4����ʹ�����ݱ���,��PS2���Ӧ��0xFA.�´�,��ʹ��PS2������.
//Ϊ�򻯳��򣬷��͸�λָ���ʡ��(��λ������ϵ縴λ���)��ֻ����ʹ�����ݱ���ָ�
	   
		FSM_HOLD_CLK_LOW:  		//����ʱ����400US��׼����������
		begin
			if(watchdog_time_cnt_done && ~sync_clk)
				fsm_ns2 = FSM_DATA_LOW_1;
			else 
				fsm_ns2 = FSM_HOLD_CLK_LOW;
		end

		FSM_DATA_LOW_1:     		//������ʼλ"0",d[0],d[1]
		begin
			if(falling_edge && (bit_count == 6'd2))
				fsm_ns2 = FSM_DATA_HIGH_1;
			else 
				fsm_ns2 = FSM_DATA_LOW_1;
		end

		FSM_DATA_HIGH_1: 			//����λd[2]
		begin
			if(falling_edge)
				fsm_ns2 = FSM_DATA_LOW_2;
			else
				fsm_ns2 = FSM_DATA_HIGH_1;
		end

		FSM_DATA_LOW_2:			//����λd[3]
		begin							
			if(falling_edge)
				fsm_ns2 = FSM_DATA_HIGH_2;
			else 
				fsm_ns2 = FSM_DATA_LOW_2;
		end

		FSM_DATA_HIGH_2:    		//����λd[4],d[5],d[6],d[7]
		begin
			if(falling_edge && (bit_count == 6'd8))
				fsm_ns2 = FSM_DATA_LOW_3;
			else 
				fsm_ns2 = FSM_DATA_HIGH_2;
		end

		FSM_DATA_LOW_3: 			//������żУ��λ
		begin
			if(falling_edge)
				fsm_ns2 = FSM_DATA_HIGH_3;
			else
				fsm_ns2 = FSM_DATA_LOW_3;
		end

		FSM_DATA_HIGH_3:			//ֹͣλ"1",Ӧ����
		begin
			if(falling_edge && sync_ps2_data)
				fsm_ns2 = FSM_HOLD_CLK_LOW; 	//�д������,���¸�λ
			else if(falling_edge && ~sync_ps2_data)
				fsm_ns2 = FSM_AWAIT_RESPONSE;
			else 
				fsm_ns2 = FSM_DATA_HIGH_3;
		end
		
//�ȴ�SP2����Ӧ�����ﲻ�Ի�Ӧ������,���ָ��û�б������ȷ�յ���
//�����Ӧ(0xFC)Ҫ�����·���ָ�Ҳ���ܻ�Ӧ(0xFE)��ʾ�յ�����
//�ݳ��������ȷ�յ����Ӧ(0xFA)��
//ע��������Ļ�Ӧʱ�䳬��400us��bit_count������λ����ʱӦ�յ�
//��λ��Ӧ����11����һ�����Ļ�Ӧʱ��϶̣�����bit_countû������
//��ʱ��λ��ֵӦ����22��

		FSM_AWAIT_RESPONSE :		//�ȴ��ظ�����ɲ���
		begin
			if(bit_count == 6'd22)
				fsm_ns2 = FSM_VERIFY;
			else 
				fsm_ns2 = FSM_AWAIT_RESPONSE;
		end

		default: fsm_ns2 = FSM_WAIT;
  endcase
end

//ʱ���·,������data_ready��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		data_ready <= 1'b0;
	else
		data_ready <= data_ready_n;
end

//��ϵ�·,�ж������Ƿ��Ѿ���ȷ�յ�  
always @ (*)
begin
	if(fsm_cs2 == FSM_USE)
		data_ready_n = 1'b1;
	else
		data_ready_n = 1'b0;
end

//ʱ���·,������ps2_data_dir��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_data_dir <= 1'b0;
	else
		ps2_data_dir <= ps2_data_dir_n;
end

//��ϵ�·,PS/2���ݷ�����ƣ��ߵ�ƽΪ������͵�ƽΪ����
always @ (*)
begin
	if(fsm_cs2 == FSM_DATA_LOW_1 	|| fsm_cs2 == FSM_DATA_HIGH_1 || 
		fsm_cs2 == FSM_DATA_LOW_2 	||	fsm_cs2 == FSM_DATA_HIGH_2 || 
		fsm_cs2 == FSM_DATA_LOW_3	)
		ps2_data_dir_n = 1'b1;
	else
		ps2_data_dir_n = 1'b0;
end

//ʱ���·,������ps2_clk_dir��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_clk_dir <= 1'b0;
	else
		ps2_clk_dir <= ps2_clk_dir_n;
end

//��ϵ�·,PS/2ʱ�ӷ�����ƣ��ߵ�ƽΪ������͵�ƽΪ����
always @ (*)
begin
	if(fsm_cs2 == FSM_HOLD_CLK_LOW)
		ps2_clk_dir_n = 1'b1;
	else
		ps2_clk_dir_n = 1'b0;
end

//ʱ���·,������ps2_clk_out��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_clk_out <= 1'b1;
	else
		ps2_clk_out <= ps2_clk_out_n;
end

//��ϵ�·,����PS/2ʱ���ź�,�����
always @ (*)
begin
	if(fsm_cs2 == FSM_HOLD_CLK_LOW)
		ps2_clk_out_n = 1'b0;
	else
		ps2_clk_out_n = 1'b1;
end

//ʱ���·,������ps2_data_out��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		ps2_data_out <= 1'b1;
	else
		ps2_data_out <= ps2_data_out_n;
end

//��ϵ�·,����PS/2�����ź�,�����
always @ (*)
begin
	if(fsm_cs2 == FSM_DATA_LOW_1 || fsm_cs2 == FSM_DATA_LOW_2 || fsm_cs2 == FSM_DATA_LOW_3)
		ps2_data_out_n = 1'b0;
	else
		ps2_data_out_n = 1'b1;
end

//ʱ���·,������bit_count��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		bit_count <= 1'b0;
	else
		bit_count <= bit_count_n;
end

//��ϵ�·,��λ������,����PS2ʱ�ӵ��½��ؼӼ���
always @ (*)
begin
	if(falling_edge) 
		bit_count_n = bit_count + 6'd1;
	else if(watchdog_time_cnt_done) 	
		bit_count_n = 6'd0;             
	else
		bit_count_n = bit_count;
end

//ʱ���·,������read_data��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)
		read_data <= 1'b0;
	else
		read_data <= read_data_n;
end


//��ϵ�·,��λ�Ĵ���,����PS2���͵���������,��ʱ�ӵ��½�����������,
always @ (*)
begin
	if(falling_edge)
		read_data_n = {sync_ps2_data,read_data[32:1]};
	else
		read_data_n = read_data;
end

//ʱ���·,������watchdog_time_cnt��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		watchdog_time_cnt <= 1'b0;
	else
		watchdog_time_cnt <=  watchdog_time_cnt_n;
end

//��ϵ�·,���Ź���ʱ��,��������ʱ����ʱ���߱�־���������ݰ���״ָ̬ʾ��
always @ (*)
begin
	if(rising_edge || falling_edge) 
		watchdog_time_cnt_n = 1'b0;
	else if(!watchdog_time_cnt_done)
		watchdog_time_cnt_n = watchdog_time_cnt + 1;
	else
		watchdog_time_cnt_n = watchdog_time_cnt;
end

//��ϵ�·,PS/2��ʱ�����峬��400us��watchdog_time_cnt_done��λ
assign watchdog_time_cnt_done = (watchdog_time_cnt == 15'd19199);

//ʱ���·,������time_cnt_5us��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		time_cnt_5us <= 1'b0;
	else
		time_cnt_5us <=  time_cnt_5us_n;
end

//��ϵ�·,����ʱ��5US������
always @ (*)
begin
	if(falling_edge || rising_edge ) 
		time_cnt_5us_n = 0;
	else 
		time_cnt_5us_n = time_cnt_5us + 1;
end

//��ϵ�·,����5us,time_cnt_5us_done��λ
assign time_cnt_5us_done = (time_cnt_5us == 8'd239);

//��֤�յ������ݰ������Ƿ���Ч����ȷ
assign packet_good = ((read_data[0]  == 1'b0) && (read_data[10] == 1'b1) && (read_data[11] == 1'b0) &&                                                  	
                      (read_data[21] == 1'b1) && (read_data[22] == 1'b0)	&& (read_data[32] == 1'b1) && 
                      (read_data[9] == ~^read_data[8:1]) && (read_data[20] == ~^read_data[19:12]) && 
							 (read_data[31] == ~^read_data[30:23]) );
							 
//ʱ���·,������left_button��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		left_button <= 1'b0;
	else
		left_button <= left_button_n;
end							 

//��ϵ�·,��ȡ��������־λ����						 
always @ (*)
begin
	if(data_ready) 
		left_button_n = read_data[1];  
	else
		left_button_n = left_button;
end							 
		
//ʱ���·,������right_button��ֵ��		
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		right_button <= 1'b0;
	else
		right_button <= right_button_n;
end							 

//��ϵ�·,��ȡ����Ҽ���־λ����						 
always @ (*)
begin
	if(data_ready) 
		right_button_n = read_data[2];  
	else
		right_button_n = right_button;
end	

//ʱ���·,������middle_button��ֵ��	
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		middle_button <= 1'b0;
	else
		middle_button <= middle_button_n;
end							 

//��ϵ�·,��ȡ����м���־λ����							 
always @ (*)
begin
	if(data_ready) 
		middle_button_n = read_data[3];  
	else
		middle_button_n = middle_button;
end	
		
//ʱ���·,������x_increment��ֵ��		
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		x_increment <= 1'b0;
	else
		x_increment <= x_increment_n;
end	
						 
//��ϵ�·,��ȡX����������				 
always @ (*)
begin
	if(data_ready) 
		x_increment_n = {read_data[5],read_data[19:12]}; 
	else
		x_increment_n = x_increment;
end		

//ʱ���·,������y_increment��ֵ��	
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n) 
		y_increment <= 1'b0;
	else
		y_increment <= y_increment_n;
end	
						 
//��ϵ�·,��ȡY����������			 
always @ (*)
begin
	if(data_ready) 
		y_increment_n = {read_data[6],read_data[30:23]};
	else
		y_increment_n = y_increment;
end	
		
 //ʱ���·,������ins_interrupt��ֵ��
always @ (posedge clock or negedge reset_n)
begin
	if(!reset_n)								
		ins_interrupt <= 1'b0;						
	else
		ins_interrupt <= ins_interrupt_n;			
end

 //��ϵ�·,�����ж��ź�
always @ (*)
begin
	if(avs_read)									
		ins_interrupt_n = 1'b0;					
	else if(data_ready)							
		ins_interrupt_n = 1'b1;						
	else
		ins_interrupt_n = ins_interrupt;			
end
	
endmodule


