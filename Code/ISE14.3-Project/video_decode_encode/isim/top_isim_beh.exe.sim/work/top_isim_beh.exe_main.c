/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    unisims_ver_m_00000000003266096158_2593380106_init();
    unisims_ver_m_00000000001946988858_2297623829_init();
    unisims_ver_m_00000000002399568039_3574923728_init();
    unisims_ver_m_00000000002557334010_3100994011_init();
    unisims_ver_m_00000000002557334010_0635491122_init();
    unisims_ver_m_00000000002393387159_0973828799_init();
    unisims_ver_m_00000000001639448493_1976804073_init();
    work_m_00000000001904600916_0723217319_init();
    unisims_ver_m_00000000001639448493_0537080975_init();
    work_m_00000000001904600916_3590914109_init();
    work_m_00000000000438150214_1628738415_init();
    work_m_00000000001472758620_3634728854_init();
    work_m_00000000001929508252_3332073105_init();
    work_m_00000000001021136976_1779455880_init();
    work_m_00000000003303377768_2391596808_init();
    work_m_00000000000889424405_0408886691_init();
    work_m_00000000003074442039_0725250980_init();
    work_m_00000000001624285805_0877998252_init();
    work_m_00000000000947417569_2782984984_init();
    work_m_00000000002794830131_1734676503_init();
    work_m_00000000003635580989_2247544608_init();
    work_m_00000000003424189857_3823007873_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000003424189857_3823007873");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
