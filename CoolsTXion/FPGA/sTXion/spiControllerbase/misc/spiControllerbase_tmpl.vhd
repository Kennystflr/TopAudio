component spiControllerbase is
    port(
        miso_i: in std_logic;
        sclk_o: out std_logic;
        mosi_o: out std_logic;
        ssn_o: out std_logic_vector(0 to 0);
        clk_i: in std_logic;
        rst_n_i: in std_logic;
        int_o: out std_logic;
        ahbl_hsel_i: in std_logic;
        ahbl_hready_i: in std_logic;
        ahbl_haddr_i: in std_logic_vector(5 downto 0);
        ahbl_hburst_i: in std_logic_vector(2 downto 0);
        ahbl_hsize_i: in std_logic_vector(2 downto 0);
        ahbl_hmastlock_i: in std_logic;
        ahbl_hprot_i: in std_logic_vector(3 downto 0);
        ahbl_htrans_i: in std_logic_vector(1 downto 0);
        ahbl_hwrite_i: in std_logic;
        ahbl_hwdata_i: in std_logic_vector(31 downto 0);
        ahbl_hreadyout_o: out std_logic;
        ahbl_hresp_o: out std_logic;
        ahbl_hrdata_o: out std_logic_vector(31 downto 0)
    );
end component;

__: spiControllerbase port map(
    miso_i=>,
    sclk_o=>,
    mosi_o=>,
    ssn_o=>,
    clk_i=>,
    rst_n_i=>,
    int_o=>,
    ahbl_hsel_i=>,
    ahbl_hready_i=>,
    ahbl_haddr_i=>,
    ahbl_hburst_i=>,
    ahbl_hsize_i=>,
    ahbl_hmastlock_i=>,
    ahbl_hprot_i=>,
    ahbl_htrans_i=>,
    ahbl_hwrite_i=>,
    ahbl_hwdata_i=>,
    ahbl_hreadyout_o=>,
    ahbl_hresp_o=>,
    ahbl_hrdata_o=>
);
