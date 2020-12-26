library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- processor Entity Description

entity processor is
    port( CLK : in std_logic;
          RESET : in std_logic;
          START : in std_logic  -- signals to run the processor
          );
end processor;

-- processor Architecture Description
architecture structural of processor is
    
    -- declare all components and their ports 
    component datapath is
        port( CLK   : in std_logic;
              RESET : in std_logic;
              
              -- I/O with Data Memory
              DATA_IN   : out sm16_data;
              DATA_OUT  : in  sm16_data;
              DATA_ADDR : out sm16_address;
              
              -- I/O with Instruction Memory
              INSTR_OUT  : in  sm16_data;
              INSTR_ADDR : out sm16_address;
              
              -- OpCode for new control for both stage 1, 2, and 3
        
              INSTR_ST2_OP   : out sm16_opcode; --new
              INSTR_ST3_OP   : out sm16_opcode; --new
              
              -- Control Signals to the ALU
              ALU_OP : in std_logic_vector(1 downto 0);
              B_INV  : in std_logic;
              CIN    : in std_logic;
              
              -- Control Signals from the Accumulator
              ZERO_FLAG : out std_logic;
              
              -- ALU Multiplexer Select Signals
              A_SEL  : in std_logic;
              B_SEL  : in std_logic;
              PC_SEL : in std_logic; --added back
              -- Enable Signals for all registers
              EN_ABCD  : in std_logic; --new 
              EN_PC : in std_logic;
              EN_IW : in std_logic;
              EN_OP : in std_logic;
              EN_DAT :in std_logic;
              EN_VAL : in std_logic;
              EN_REG : in std_logic;
              EN_IMM  : in std_logic);
    end component;
    
    component instr_memory is
        port( DIN : in sm16_data;
              ADDR: in sm16_address;
              DOUT: out sm16_data;
              WE: in std_logic);
    end component;
    
    component data_memory is
        port( DIN : in sm16_data;
              ADDR : in sm16_address;
              DOUT : out sm16_data;
              WE : in std_logic);
    end component;
 
 component control is
      port(CLK   : in std_logic;
           RESET : in std_logic;
           START : in std_logic;
           
           WE     : out std_logic;
           ALU_OP : out std_logic_vector(1 downto 0);
           B_INV  : out std_logic;
           CIN    : out std_logic;
           A_SEL  : out std_logic;
           B_SEL  : out std_logic;
           PC_SEL : out std_logic;
           EN_PC  : out std_logic;
           EN_IW : out std_logic;
           EN_OP : out std_logic;
           EN_DAT : out std_logic;
           EN_VAL : out std_logic;
           EN_REG : out std_logic;
           EN_IMM : out std_logic;
           
           Z_FLAG   : in std_logic;
           
           INSTR_ST2_OP : in sm16_opcode;
           INSTR_ST3_OP : in sm16_opcode;
           EN_ABCD : out std_logic);
 end component;   

    
    signal DataAddress_Connect, PCAddress_Connect : sm16_address;
    signal Data_IntoMem_Connect : sm16_data;
    signal DataOut_OutofMem_Connect, Instruction_Connect : sm16_data;
    signal ReadWrite_Connect : std_logic;
    
    signal InstrOpCode2_Connect : sm16_opcode; --new
    signal InstrOpCode3_Connect : sm16_opcode; --new
    
    signal ALUOp_Connect : std_logic_vector(1 downto 0);
    signal Binv_Connect  : std_logic;
    signal Cin_Connect   : std_logic;
    signal Zflag_Connect : std_logic;
    signal Nflag_Connect : std_logic;
    
    signal ASel_Connect  : std_logic;
    signal BSel_Connect  : std_logic;
    signal PCSel_Connect : std_logic;--added again
    
    signal EnableABCD_Connect  : std_logic; --new
    signal EnPC_Connect : std_logic;
    signal EnIW_Connect : std_logic;
    signal EnOP_Connect : std_logic;
    signal EnDAT_Connect : std_logic;
    signal EnVAL_Connect : std_logic;
    signal EnREG_Connect : std_logic;
    signal EnIMM_Connect : std_logic;
    
begin
    
    the_instr_memory: instr_memory port map (
        DIN => "0000000000000000",
        ADDR => PCAddress_Connect,
        DOUT => Instruction_Connect,
        WE => '0'  -- always read
        );
        
    the_data_memory: data_memory port map (
        DIN => Data_IntoMem_Connect,
        ADDR => DataAddress_Connect,
        DOUT => DataOut_OutofMem_Connect,
        WE => ReadWrite_Connect
        );
        
    the_datapath: datapath port map (
        CLK   => CLK,
        RESET => RESET,
        DATA_IN   => Data_IntoMem_Connect,
        DATA_OUT  => DataOut_OutofMem_Connect,
        DATA_ADDR => DataAddress_Connect,
        INSTR_OUT  => Instruction_Connect,
        INSTR_ADDR => PCAddress_Connect,
        
        INSTR_ST2_OP   => InstrOpCode2_Connect, --new
        INSTR_ST3_OP   => InstrOpCode3_Connect,--new
        
        ALU_OP => ALUOp_Connect,
        B_INV  => Binv_Connect,
        CIN    => Cin_Connect,
        ZERO_FLAG => Zflag_Connect,
        
        A_SEL  => ASel_Connect,
        B_SEL  => BSel_Connect,
        PC_SEL => PCSel_Connect, --new
        EN_ABCD => EnableABCD_Connect, --new
        EN_PC => EnPC_Connect,
        EN_IW => EnIW_Connect   ,
        EN_OP => EnOP_Connect   ,
        EN_DAT => EnDAT_Connect   ,
        EN_VAL => EnVAL_Connect   ,
        EN_REG => EnREG_Connect  ,
        EN_IMM => EnIMM_Connect
        );
        
        
       the_control: control port map(
                  CLK => CLK   ,   
                  RESET => RESET  ,
                  START => START ,
                  WE => ReadWrite_Connect ,    
                  ALU_OP => ALUOp_Connect,
                  B_INV  => Binv_Connect,
                  CIN => Cin_Connect   ,   
                  A_SEL => ASel_Connect  , 
                  B_SEL => BSel_Connect , 
                  PC_SEL => PCSel_Connect ,
                  EN_PC => EnPC_Connect ,  
                  EN_IW => EnIW_Connect ,
                  EN_OP => EnOP_Connect ,
                  EN_DAT => EnDAT_Connect , 
                  EN_VAL => EnVAL_Connect,
                  EN_REG => EnREG_Connect,
                  EN_IMM => EnIMM_Connect ,
                  
                  Z_FLAG => Zflag_Connect,  
               
                  INSTR_ST2_OP => InstrOpCode2_Connect  ,
                  INSTR_ST3_OP => InstrOpCode3_Connect  ,
                  EN_ABCD => EnableABCD_Connect
       ); 
          

 
end structural;
