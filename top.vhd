library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is port (    
    LED :out std_logic_vector(3 downto 0);
    D_POS: out std_logic_vector(3 downto 0);    -- display positions
    D_SEG: out std_logic_vector(6 downto 0);
    SW_EXP: in std_logic_vector(6 downto 0);
    SW0: in std_logic;
    CLK: in std_logic;
    LED_EXP: out std_logic_vector(15 downto 0));
end top;


architecture Behavioral of top is
    signal cislo:std_logic_vector(6 downto 0);
    signal vstup:std_logic_vector(6 downto 0) := (others => '0');
    signal vstup_old:std_logic_vector(6 downto 0) := (others => '1');
    signal des:std_logic_vector(3 downto 0);
    signal jed:std_logic_vector(3 downto 0);
    signal bcd:std_logic_vector(3 downto 0);
    signal position: std_logic_vector(3 downto 0);
    signal clk_10_cnt: std_logic_vector(7 downto 0);
    signal clk_10: std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            clk_10_cnt <= clk_10_cnt + 1;
            if clk_10_cnt = x"32" then
                clk_10_cnt <= (others => '0');
                clk_10 <= not clk_10;
            end if;
        end if;      
    end process;

    process(CLK)
    begin
        if SW0 = '0' then   
          if rising_edge(CLK) then
             if vstup /= vstup_old then
                vstup_old <= vstup;               --- BCD+3
                cislo <= (others => '0');
                jed <= ("0011");
                des <= (others => '0');
           
            elsif cislo = vstup then
            
                vstup_old <= vstup;
           
            --elsif change = '1' then
            else
                cislo <= cislo + 1 ;
                jed <= jed + 1;
               
                if jed = 9 then
                    des <= des + 1;
                    jed <= (others => '0');
                    elsif cislo>=97 then des <=(others=>'1');
                    jed <=("1110");
                   end if;
                end if;
            end if;
          else
          if rising_edge(CLK) then
             if vstup /= vstup_old then
                vstup_old <= vstup;               
                cislo <= (others => '0');             ----BCD
                jed <= (others => '0');
                des <= (others => '0');
           
            elsif cislo = vstup then
                vstup_old <= vstup;
           
            --elsif change = '1' then
            else
                cislo <= cislo + 1 ;
                jed <= jed + 1;
               
                if jed = 9 then
                    des <= des + 1;
                    jed <= (others => '0');
                    elsif cislo>=100 then des <=(others=>'1');
                    jed <=("1110");
                    
                   end if;
                end if;
            end if;
            end if;
          
    end process;
    
    

    process(clk_10)
    begin
        if rising_edge(clk_10) then
            if position = "1011" then
                position <= "0111";
            else
                position <= "1011";
            end if;
        end if;
    end process;
   
    process(position)
    begin
        if position="1011" then       
            bcd <= jed;
        else
            bcd <= des;
        end if; 
    end process;
   
    LED_EXP(6 downto 0) <= not SW_EXP(6 downto 0);
    LED_EXP(14 downto 8) <= SW_EXP(6 downto 0);
 
    with bcd select
     D_SEG <=        "1111001" when "0001",     -- 1       ---
                     "0100100" when "0010",     -- 2    5 |   | 1
                     "0110000" when "0011",
                     "0011001" when "0100",     -- 4    4 |   | 2
                     "0010010" when "0101",     -- 5       ---
                     "0000010" when "0110",
                     "1111000" when "0111",     -- 5       ---
                     "0000000" when "1000",
                     "0010000" when "1001",
                     "0000110" when "1111",                     --E
                     "0101111" when "1110",                     --R
                     "1000000" when others;

    D_POS <= position;
   
    vstup <= SW_EXP;
    
   

   
end Behavioral;

