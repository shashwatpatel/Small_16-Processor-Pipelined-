library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- datapath Entity Description

entity datapath is
    port( CLK   : in std_logic;
          RESET : in std_logic;
          
          -- I/O with Data Memory
          DATA_IN   : out sm16_data;
          DATA_OUT  : in  sm16_data;
          DATA_ADDR : out sm16_address;
          
          -- I/O with Instruction Memory
          INSTR_OUT  : in  sm16_data;
          INSTR_ADDR : out sm16_address;
          
          -- OpCode sent to the Control
       --   INSTR_ST1_OP : out sm16_opcode;
          INSTR_ST2_OP : out sm16_opcode;
          INSTR_ST3_OP : out sm16_opcode;
          
          -- Control Signals to the ALU
          ALU_OP : in std_logic_vector(1 downto 0);
          B_INV  : in std_logic;
          CIN    : in std_logic;
          
         
          ZERO_FLAG : out std_logic;
        
          
          -- ALU Multiplexer Select Signals
          A_SEL  : in std_logic;
          B_SEL  : in std_logic;
          EN_ABCD :in std_logic; --new
          PC_SEL :in std_logic; --added again
          EN_PC : in std_logic;
          EN_IW : in std_logic;
          EN_OP : in std_logic;
          EN_DAT :in std_logic;
          EN_VAL : in std_logic;
          EN_REG : in std_logic;
          EN_IMM  : in std_logic);
end datapath;

-- datapath Architecture Description
architecture structural of datapath is
    
    -- declare all components and their ports 
        component reg is
        generic( DWIDTH : integer := 8 );
        port( CLK : in std_logic;              
        RST : in std_logic;              
        CE : in std_logic;              
        D : in std_logic_vector( DWIDTH-1 downto 0 );              
        Q : out std_logic_vector( DWIDTH-1 downto 0 ) );    
        end component;
            

    component ABCDRegFile is
             port( CLK : in std_logic;
                 RESET : in std_logic;
             
                 RD_REG : in std_logic_vector(1 downto 0);  -- Which register to read and output
                 REG_OUT : out sm16_data;
             
                 ABCD_WE : in std_logic; -- Write enable signal
                 WR_REG : in std_logic_vector(1 downto 0);  -- Which register to write to
                 REG_IN : in sm16_data);
       end component;

    
    component alu is
        port( A : in sm16_data;
              B : in sm16_data;
              OP : in std_logic_vector(1 downto 0);
              D : out sm16_data;
              CIN : in std_logic;
              B_INV : in std_logic);
    end component;
    
    component adder is
        port( A : in sm16_address;
              B : in sm16_address;
              D : out sm16_address);
    end component;
    
    component mux2 is
        generic( DWIDTH : integer := 16 );
        port( IN0 : in std_logic_vector( DWIDTH-1 downto 0 );
              IN1 : in std_logic_vector( DWIDTH-1 downto 0 );
              SEL : in std_logic;
              DOUT : out std_logic_vector( DWIDTH-1 downto 0 ) );
    end component;
    
    component zero_extend is
        port( A : in sm16_address;
              Z : out sm16_data);
    end component;
    
    component zero_checker is
        port( A : in sm16_data;
              Z : out std_logic);
    end component;  
    
    signal zero_16 : sm16_data := "0000000000000000";
    signal one_ten : sm16_address := "0000000001";
    signal zero_ten : sm16_address := "0000000000";
    signal out_op : sm16_opcode;
    signal alu_a, alu_b, alu_out, R_V_Out, reg_dataout, reg_immout, out_instrword, out_ABCDreg : sm16_data; --New signals added
    signal pc_out, pc_in, A_PC : sm16_address;
    signal  immediate_zero_extend_out : sm16_data;
    signal reg_out :std_logic_vector (1 downto 0);
    
begin
    
    TheAlu: alu port map (
        A     => alu_a,
        B     => alu_b,
        OP    => ALU_OP,
        D     => alu_out,
        CIN   => CIN,
        B_INV => B_INV
        );
    
    PCadder: adder port map (
        A => pc_out,--Output of PC to adder
        B => one_ten, --10 bit 1
        D => A_PC -- adder output to PC
        );
    
    Amux: mux2 generic map ( DWIDTH => 16 )
        port map (
        IN0  => zero_16,  -- 00 
        IN1  => R_V_Out,  -- 01
        SEL  => A_SEL,
        DOUT => alu_a  
        );
    
    Bmux: mux2 generic map ( DWIDTH => 16 )
        port map (
        IN0  => reg_dataout,  -- 00, 
        IN1  => reg_immout,  -- 01 
        SEL  => B_SEL,
        DOUT => alu_b  
        );
    
    ProgramCounter: reg generic map ( DWIDTH => 10 )
        port map (
        CLK => CLK,
        RST => RESET,
        CE  => EN_PC,
        D   => pc_in,
        Q   => pc_out
        );
    
    ImmediateZeroExt: zero_extend port map (
        A => out_instrword(9 downto 0),
        Z => immediate_zero_extend_out
        );
 --New Components
    abcd: ABCDRegFile port map (
        CLK => CLK,
        RESET => RESET,
        RD_REG => out_instrword(11 downto 10),
        REG_OUT => out_ABCDreg, 
        ABCD_WE => EN_ABCD,
        WR_REG =>  reg_out,
       REG_IN => alu_out);
       
 InstrWord: reg generic map ( DWIDTH => 16 )
          port map (
          CLK => CLK,
          RST => RESET,
          CE => EN_IW,
          D => INSTR_OUT,
          Q => out_instrword);
          
 OPReg: reg generic map ( DWIDTH => 4 ) 
          port map (
          CLK => CLK,
          RST => RESET,
          CE => EN_OP,
          D => out_instrword(15 downto 12),
          Q => out_op);
 
 ImmediateReg: reg generic map ( DWIDTH => 16 )
           port map (
           CLK => CLK,
           RST => RESET,
           CE => EN_IMM,
           D => immediate_zero_extend_out,
           Q => reg_immout);
           
 datReg : reg generic map ( DWIDTH => 16 )
           port map (
           CLK => CLK,
           RST => RESET,
           CE => EN_DAT,
           D => DATA_OUT,
           Q => reg_dataout);
  
  RegVal: reg generic map ( DWIDTH => 16 )
          port map (
          CLK => CLK,
          RST => RESET,
          CE => EN_VAL,
          D => out_ABCDreg,
          Q => R_V_Out);    
          
  regularReg: reg generic map ( DWIDTH => 2 )
          port map(
          CLK => CLK,
          RST => RESET,
          CE => EN_REG,
          D => out_instrword(11 downto 10),
          Q => reg_out);
      
          
  PCmux: mux2 generic map ( DWIDTH => 10)
          port map (
          IN0  => A_PC,  -- 00
          IN1  => INSTR_OUT (9 downto 0),  -- 01
          SEL  => PC_SEL,
          DOUT => pc_in 
          );        
  
   ZeroCheck: zero_checker port map (
          A => R_V_Out,
          Z => ZERO_FLAG
          );      
   -- NEG_FLAG <= alu_out(15);
    
    DATA_IN   <= out_ABCDreg;
    DATA_ADDR <= out_instrword(9 downto 0);
    

    INSTR_ST2_OP   <= out_instrword(15 downto 12);
    INSTR_ST3_OP <= out_op;
    INSTR_ADDR <= pc_out;
    
end structural;
