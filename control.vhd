library ieee;
use ieee.std_logic_1164.all;
use work.sm16_types.all;

-- control Entity Description

entity control is
    port( CLK   : in std_logic;
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
end control;

-- control Architecture Description
architecture behavorial of control is

    -- control signal values
        -- alu operations
        constant alu_nop : std_logic_vector(1 downto 0) := "00";
        constant alu_and : std_logic_vector(1 downto 0) := "00";
        constant alu_or  : std_logic_vector(1 downto 0) := "01";
        constant alu_add : std_logic_vector(1 downto 0) := "10";
        
        -- a select control
        constant a_0 : std_logic := '0';
        constant a_a : std_logic := '1';
        
        -- b select control
        constant b_mem : std_logic := '0';
        constant b_imm : std_logic := '1';
        
        -- pc select
        constant from_plus1 : std_logic := '0';
        constant from_newAdder : std_logic := '1';
        
        -- register load control
        constant hold : std_logic := '0';
        constant load : std_logic := '1';
        
        -- data memory write enable control
        constant rd : std_logic := '0';
        constant wr : std_logic := '1';
        
        -- b invert control
        constant pos : std_logic := '0';
        constant inv : std_logic := '1';
        
    -- op codes
    constant op_add   : sm16_opcode := "0000";
    constant op_sub   : sm16_opcode := "0001";  
    constant op_load  : sm16_opcode := "0010";
    constant op_store : sm16_opcode := "0011";
    constant op_addi  : sm16_opcode := "0100";
    constant op_seti  : sm16_opcode := "0101";
    constant op_jump  : sm16_opcode := "0110";
    constant op_jz    : sm16_opcode := "0111";
    
    -- definitions of the states the control can be in
    type states is (stopped, running);  -- single cycle now, so only one running state
    signal state, next_state : states := stopped;
    
    -- internal write enable, ungated by the clock
    signal pre_we : std_logic;
    
begin
    
    -- write enable is gated when the clock is low
    WE <= pre_we and (not CLK);
    
    -- process to state register
    state_reg: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            state <= stopped;
        elsif( rising_edge(CLK) ) then
            state <= next_state;
        end if;
    end process state_reg;
    
    -- ############################################ --
    
    -- process to define next state transitions and output signals
    next_state_and_output: process( state, START, INSTR_ST2_OP, INSTR_ST3_OP, Z_FLAG)
    begin
        case state is
            -- Stopped is the stopped state; wait for start
            when stopped =>
                
                if( START /= '1' ) then
                    -- issue nop
                    EN_PC  <= hold;
                    EN_IW <= hold;    EN_OP  <= hold;
                    EN_DAT <= hold;  EN_VAL  <= hold;
                    EN_REG <= hold;    EN_IMM  <= hold;
                    EN_ABCD <= hold;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_nop;
                    A_SEL <= a_0;     B_SEL  <= b_mem;
                    
                    next_state <= stopped;
                else
                    EN_IW <= load;    EN_PC  <= load; -- instruction word* and program counter*
                    EN_OP  <= load;   EN_REG <= load;
                    EN_IMM  <= load;   EN_DAT <= load;

                    EN_VAL  <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_and;
                    A_SEL <= a_0;     B_SEL  <= b_mem;
                    
                    next_state <= running; -- go to fetch state
                end if;
                
            -- In running state, each instruciton has its own control signals
            when running =>

                -- Stage 2
                
                if INSTR_ST2_OP = op_add then
                    -- A <- A + Mem
                    EN_PC  <= load;
                    EN_DAT <= load;  EN_VAL  <= load;
                    EN_IMM  <= hold; -- immediate not used
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                    
                elsif INSTR_ST2_OP = op_sub then
                    -- A <- A - Mem
                     EN_PC  <= load;
                    EN_VAL  <= load; EN_IMM  <= hold;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                --todo
                elsif INSTR_ST2_OP = op_load then 
                -- LDR R0, B
                -- op load set alu to do nothing, cin 0
                --  a = 0 alu returns b
                    EN_PC  <= load;
                    EN_VAL  <= load;  EN_DAT <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                    
                elsif INSTR_ST2_OP = op_store then -- op store set alu do nothing cin 0... what
                    EN_PC  <= load;
                    EN_VAL  <= hold;    
                    pre_we <= wr;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                
                elsif INSTR_ST2_OP = op_addi then -- what is add i?
                   
                    EN_PC  <= load;
                    EN_VAL  <= load; EN_IMM  <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                    
                elsif INSTR_ST2_OP = op_seti then
                    -- A <- 0 + Immediate
                    EN_PC  <= load;
                    EN_VAL  <= load; EN_IMM  <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= running;
                
                elsif INSTR_ST2_OP = op_jump then
                    -- PC <- 0 + Immediate
                    EN_VAL  <= hold;
                    EN_PC  <= load;
                    pre_we <= rd;     PC_SEL <= from_newAdder;   
                    A_SEL <= a_0;     B_SEL  <= b_imm;
                    
                    next_state <= running;
                    
                elsif INSTR_ST2_OP = op_jz then
                    -- Because the zero flag comes directly from the A register through the
                    -- zero checker component (not from the ALU), the control signals do not
                    -- affect the outcome of the check. Therefore, both conditions of the
                    -- jump can evaluated in the one cycle for the instruction.
                   
                   if Z_FLAG = '1' then
                        -- successful jump
                        -- PC <- 0 + Immediate
                        EN_PC  <= load;
                        pre_we <= rd;     PC_SEL <= from_newAdder;   
                        A_SEL <= a_0;     B_SEL  <= b_imm;
                        
                        next_state <= running;
                        
                    else
                        -- unsuccessful jump
                        -- PC <- PC + 1 (as normal)
                        EN_PC  <= load;
                        pre_we <= rd;     PC_SEL <= from_plus1;
                        A_SEL <= a_0;     B_SEL  <= b_imm;
                        
                        next_state <= running;
                        
                    end if;
                   
                    next_state <= running;
                    
                
                else -- unknown opcode
                    -- should never get here, but if it does, set PC<=0 and stop
                    EN_PC  <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    
                    next_state <= stopped;
                    
                end if;
                
                -- Stage 3
                if INSTR_ST3_OP = op_add then
                   
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_add; 
                    A_SEL <= a_a;     B_SEL  <= b_mem; EN_ABCD <= load; EN_REG <= load;
                    
                    next_state <= running;
                    
                elsif INSTR_ST3_OP = op_sub then
                    -- A <- A - Mem
                    B_INV <= inv;     CIN    <= '1';     ALU_OP <= alu_add; 
                    A_SEL <= a_a;     B_SEL  <= b_mem; EN_ABCD <= load; EN_REG <= load;
                    
                    next_state <= running;
                --todo
                elsif INSTR_ST3_OP = op_load then 
                -- LDR R0, B
                -- op load set alu to do nothing, cin 0
                --  a = 0 alu returns b

                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_add; -- keep state of loaded
                    A_SEL <= a_0;     B_SEL  <= b_mem; EN_ABCD <= load; EN_REG <= load; 
                    
                    next_state <= running;
                    
                elsif INSTR_ST3_OP = op_store then -- op store set alu do nothing cin 0... what
                    
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_nop; 
                    A_SEL <= a_0;     B_SEL  <= b_mem; EN_ABCD <= load; EN_REG <= hold;
                    
                    next_state <= running;
                
                elsif INSTR_ST3_OP = op_addi then -- what is add i?
                    -- A <- A + immediate
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_add;
                    A_SEL <= a_a;     B_SEL  <= b_imm; EN_ABCD <= load; EN_REG <= load;
                    
                    next_state <= running;
                    
                --endtodo
                elsif INSTR_ST3_OP = op_seti then
                    -- A <- 0 + Immediate
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_add; 
                    A_SEL <= a_0;     B_SEL  <= b_imm; EN_ABCD <= load; EN_REG <= load;
                    
                    next_state <= running;
                    
                elsif INSTR_ST3_OP = op_jump then
                    -- skip
                    next_state <= running;
                
                elsif INSTR_ST3_OP = op_jz then
                    -- skip
                    next_state <= running;
                 
                else -- unknown opcode
                    -- should never get here, but if it does, set PC<=0 and stop
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_and; PC_SEL <= from_plus1;
                    A_SEL <= a_0;     B_SEL  <= b_mem; EN_ABCD <= hold; EN_REG <= load;
                    
                    next_state <= stopped;
                    
                end if;
                
            when others => -- unknown state
                    -- should never get here, but if it does, set PC<=0 and stop
                    EN_PC  <= load;
                    pre_we <= rd;     PC_SEL <= from_plus1;
                    B_INV <= pos;     CIN    <= '0';     ALU_OP <= alu_and;
                    A_SEL <= a_0;     B_SEL  <= b_mem; EN_REG <= load;
                    
                    next_state <= stopped;
        end case;
    end process next_state_and_output;
    
end behavorial;
