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

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "E:/Hardware/About-Hardware/Documents/Code/ISE14.3-Project/video_decode_encode/filter.v";
static unsigned int ng1[] = {1U, 0U};
static unsigned int ng2[] = {0U, 0U};
static int ng3[] = {295000, 0};
static int ng4[] = {1, 0};
static int ng5[] = {590000, 0};
static int ng6[] = {885000, 0};



static void Always_12_0(char *t0)
{
    char t4[8];
    char t23[8];
    char t28[8];
    char t32[8];
    char t38[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t29;
    char *t30;
    char *t31;
    char *t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    char *t37;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    char *t42;
    char *t43;
    char *t44;
    unsigned int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    char *t52;
    char *t53;
    unsigned int t54;
    unsigned int t55;
    unsigned int t56;
    unsigned int t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    int t62;
    int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    char *t76;
    char *t77;

LAB0:    t1 = (t0 + 2848U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(12, ng0);
    t2 = (t0 + 3168);
    *((int *)t2) = 1;
    t3 = (t0 + 2880);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(13, ng0);
    t5 = (t0 + 1208U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t5 = (t6 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (~(t7));
    t9 = *((unsigned int *)t6);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB8;

LAB6:    if (*((unsigned int *)t5) == 0)
        goto LAB5;

LAB7:    t12 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t12) = 1;

LAB8:    t13 = (t4 + 4);
    t14 = *((unsigned int *)t13);
    t15 = (~(t14));
    t16 = *((unsigned int *)t4);
    t17 = (t16 & t15);
    t18 = (t17 != 0);
    if (t18 > 0)
        goto LAB9;

LAB10:    xsi_set_current_line(21, ng0);

LAB13:    xsi_set_current_line(22, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng3)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    if (*((unsigned int *)t12) != 0)
        goto LAB15;

LAB14:    t13 = (t6 + 4);
    if (*((unsigned int *)t13) != 0)
        goto LAB15;

LAB18:    if (*((unsigned int *)t5) < *((unsigned int *)t6))
        goto LAB16;

LAB17:    t20 = (t4 + 4);
    t7 = *((unsigned int *)t20);
    t8 = (~(t7));
    t9 = *((unsigned int *)t4);
    t10 = (t9 & t8);
    t11 = (t10 != 0);
    if (t11 > 0)
        goto LAB19;

LAB20:    xsi_set_current_line(30, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng3)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    if (*((unsigned int *)t12) != 0)
        goto LAB24;

LAB23:    t13 = (t6 + 4);
    if (*((unsigned int *)t13) != 0)
        goto LAB24;

LAB27:    if (*((unsigned int *)t5) < *((unsigned int *)t6))
        goto LAB26;

LAB25:    *((unsigned int *)t4) = 1;

LAB26:    memset(t23, 0, 8);
    t20 = (t4 + 4);
    t7 = *((unsigned int *)t20);
    t8 = (~(t7));
    t9 = *((unsigned int *)t4);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB28;

LAB29:    if (*((unsigned int *)t20) != 0)
        goto LAB30;

LAB31:    t22 = (t23 + 4);
    t14 = *((unsigned int *)t23);
    t15 = *((unsigned int *)t22);
    t16 = (t14 || t15);
    if (t16 > 0)
        goto LAB32;

LAB33:    memcpy(t38, t23, 8);

LAB34:    t70 = (t38 + 4);
    t71 = *((unsigned int *)t70);
    t72 = (~(t71));
    t73 = *((unsigned int *)t38);
    t74 = (t73 & t72);
    t75 = (t74 != 0);
    if (t75 > 0)
        goto LAB47;

LAB48:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng5)));
    memset(t4, 0, 8);
    t12 = (t5 + 4);
    if (*((unsigned int *)t12) != 0)
        goto LAB52;

LAB51:    t13 = (t6 + 4);
    if (*((unsigned int *)t13) != 0)
        goto LAB52;

LAB55:    if (*((unsigned int *)t5) < *((unsigned int *)t6))
        goto LAB54;

LAB53:    *((unsigned int *)t4) = 1;

LAB54:    memset(t23, 0, 8);
    t20 = (t4 + 4);
    t7 = *((unsigned int *)t20);
    t8 = (~(t7));
    t9 = *((unsigned int *)t4);
    t10 = (t9 & t8);
    t11 = (t10 & 1U);
    if (t11 != 0)
        goto LAB56;

LAB57:    if (*((unsigned int *)t20) != 0)
        goto LAB58;

LAB59:    t22 = (t23 + 4);
    t14 = *((unsigned int *)t23);
    t15 = *((unsigned int *)t22);
    t16 = (t14 || t15);
    if (t16 > 0)
        goto LAB60;

LAB61:    memcpy(t38, t23, 8);

LAB62:    t70 = (t38 + 4);
    t71 = *((unsigned int *)t70);
    t72 = (~(t71));
    t73 = *((unsigned int *)t38);
    t74 = (t73 & t72);
    t75 = (t74 != 0);
    if (t75 > 0)
        goto LAB75;

LAB76:    xsi_set_current_line(46, ng0);

LAB79:    xsi_set_current_line(47, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1608);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(48, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1768);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);

LAB77:
LAB49:
LAB21:
LAB11:    goto LAB2;

LAB5:    *((unsigned int *)t4) = 1;
    goto LAB8;

LAB9:    xsi_set_current_line(14, ng0);

LAB12:    xsi_set_current_line(15, ng0);
    t19 = ((char*)((ng1)));
    t20 = (t0 + 1608);
    xsi_vlogvar_wait_assign_value(t20, t19, 0, 0, 1, 0LL);
    xsi_set_current_line(16, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1768);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(18, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1928);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    goto LAB11;

LAB15:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB17;

LAB16:    *((unsigned int *)t4) = 1;
    goto LAB17;

LAB19:    xsi_set_current_line(23, ng0);

LAB22:    xsi_set_current_line(24, ng0);
    t21 = ((char*)((ng1)));
    t22 = (t0 + 1608);
    xsi_vlogvar_wait_assign_value(t22, t21, 0, 0, 1, 0LL);
    xsi_set_current_line(25, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1768);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(27, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng4)));
    memset(t4, 0, 8);
    xsi_vlog_unsigned_add(t4, 32, t5, 32, t6, 32);
    t12 = (t0 + 1928);
    xsi_vlogvar_wait_assign_value(t12, t4, 0, 0, 32, 0LL);
    goto LAB21;

LAB24:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB26;

LAB28:    *((unsigned int *)t23) = 1;
    goto LAB31;

LAB30:    t21 = (t23 + 4);
    *((unsigned int *)t23) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB31;

LAB32:    t24 = (t0 + 1928);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    t27 = ((char*)((ng5)));
    memset(t28, 0, 8);
    t29 = (t26 + 4);
    if (*((unsigned int *)t29) != 0)
        goto LAB36;

LAB35:    t30 = (t27 + 4);
    if (*((unsigned int *)t30) != 0)
        goto LAB36;

LAB39:    if (*((unsigned int *)t26) < *((unsigned int *)t27))
        goto LAB37;

LAB38:    memset(t32, 0, 8);
    t33 = (t28 + 4);
    t17 = *((unsigned int *)t33);
    t18 = (~(t17));
    t34 = *((unsigned int *)t28);
    t35 = (t34 & t18);
    t36 = (t35 & 1U);
    if (t36 != 0)
        goto LAB40;

LAB41:    if (*((unsigned int *)t33) != 0)
        goto LAB42;

LAB43:    t39 = *((unsigned int *)t23);
    t40 = *((unsigned int *)t32);
    t41 = (t39 & t40);
    *((unsigned int *)t38) = t41;
    t42 = (t23 + 4);
    t43 = (t32 + 4);
    t44 = (t38 + 4);
    t45 = *((unsigned int *)t42);
    t46 = *((unsigned int *)t43);
    t47 = (t45 | t46);
    *((unsigned int *)t44) = t47;
    t48 = *((unsigned int *)t44);
    t49 = (t48 != 0);
    if (t49 == 1)
        goto LAB44;

LAB45:
LAB46:    goto LAB34;

LAB36:    t31 = (t28 + 4);
    *((unsigned int *)t28) = 1;
    *((unsigned int *)t31) = 1;
    goto LAB38;

LAB37:    *((unsigned int *)t28) = 1;
    goto LAB38;

LAB40:    *((unsigned int *)t32) = 1;
    goto LAB43;

LAB42:    t37 = (t32 + 4);
    *((unsigned int *)t32) = 1;
    *((unsigned int *)t37) = 1;
    goto LAB43;

LAB44:    t50 = *((unsigned int *)t38);
    t51 = *((unsigned int *)t44);
    *((unsigned int *)t38) = (t50 | t51);
    t52 = (t23 + 4);
    t53 = (t32 + 4);
    t54 = *((unsigned int *)t23);
    t55 = (~(t54));
    t56 = *((unsigned int *)t52);
    t57 = (~(t56));
    t58 = *((unsigned int *)t32);
    t59 = (~(t58));
    t60 = *((unsigned int *)t53);
    t61 = (~(t60));
    t62 = (t55 & t57);
    t63 = (t59 & t61);
    t64 = (~(t62));
    t65 = (~(t63));
    t66 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t66 & t64);
    t67 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t67 & t65);
    t68 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t68 & t64);
    t69 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t69 & t65);
    goto LAB46;

LAB47:    xsi_set_current_line(31, ng0);

LAB50:    xsi_set_current_line(32, ng0);
    t76 = ((char*)((ng2)));
    t77 = (t0 + 1608);
    xsi_vlogvar_wait_assign_value(t77, t76, 0, 0, 1, 0LL);
    xsi_set_current_line(33, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1768);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(35, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng4)));
    memset(t4, 0, 8);
    xsi_vlog_unsigned_add(t4, 32, t5, 32, t6, 32);
    t12 = (t0 + 1928);
    xsi_vlogvar_wait_assign_value(t12, t4, 0, 0, 32, 0LL);
    goto LAB49;

LAB52:    t19 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t19) = 1;
    goto LAB54;

LAB56:    *((unsigned int *)t23) = 1;
    goto LAB59;

LAB58:    t21 = (t23 + 4);
    *((unsigned int *)t23) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB59;

LAB60:    t24 = (t0 + 1928);
    t25 = (t24 + 56U);
    t26 = *((char **)t25);
    t27 = ((char*)((ng6)));
    memset(t28, 0, 8);
    t29 = (t26 + 4);
    if (*((unsigned int *)t29) != 0)
        goto LAB64;

LAB63:    t30 = (t27 + 4);
    if (*((unsigned int *)t30) != 0)
        goto LAB64;

LAB67:    if (*((unsigned int *)t26) < *((unsigned int *)t27))
        goto LAB65;

LAB66:    memset(t32, 0, 8);
    t33 = (t28 + 4);
    t17 = *((unsigned int *)t33);
    t18 = (~(t17));
    t34 = *((unsigned int *)t28);
    t35 = (t34 & t18);
    t36 = (t35 & 1U);
    if (t36 != 0)
        goto LAB68;

LAB69:    if (*((unsigned int *)t33) != 0)
        goto LAB70;

LAB71:    t39 = *((unsigned int *)t23);
    t40 = *((unsigned int *)t32);
    t41 = (t39 & t40);
    *((unsigned int *)t38) = t41;
    t42 = (t23 + 4);
    t43 = (t32 + 4);
    t44 = (t38 + 4);
    t45 = *((unsigned int *)t42);
    t46 = *((unsigned int *)t43);
    t47 = (t45 | t46);
    *((unsigned int *)t44) = t47;
    t48 = *((unsigned int *)t44);
    t49 = (t48 != 0);
    if (t49 == 1)
        goto LAB72;

LAB73:
LAB74:    goto LAB62;

LAB64:    t31 = (t28 + 4);
    *((unsigned int *)t28) = 1;
    *((unsigned int *)t31) = 1;
    goto LAB66;

LAB65:    *((unsigned int *)t28) = 1;
    goto LAB66;

LAB68:    *((unsigned int *)t32) = 1;
    goto LAB71;

LAB70:    t37 = (t32 + 4);
    *((unsigned int *)t32) = 1;
    *((unsigned int *)t37) = 1;
    goto LAB71;

LAB72:    t50 = *((unsigned int *)t38);
    t51 = *((unsigned int *)t44);
    *((unsigned int *)t38) = (t50 | t51);
    t52 = (t23 + 4);
    t53 = (t32 + 4);
    t54 = *((unsigned int *)t23);
    t55 = (~(t54));
    t56 = *((unsigned int *)t52);
    t57 = (~(t56));
    t58 = *((unsigned int *)t32);
    t59 = (~(t58));
    t60 = *((unsigned int *)t53);
    t61 = (~(t60));
    t62 = (t55 & t57);
    t63 = (t59 & t61);
    t64 = (~(t62));
    t65 = (~(t63));
    t66 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t66 & t64);
    t67 = *((unsigned int *)t44);
    *((unsigned int *)t44) = (t67 & t65);
    t68 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t68 & t64);
    t69 = *((unsigned int *)t38);
    *((unsigned int *)t38) = (t69 & t65);
    goto LAB74;

LAB75:    xsi_set_current_line(39, ng0);

LAB78:    xsi_set_current_line(40, ng0);
    t76 = ((char*)((ng1)));
    t77 = (t0 + 1608);
    xsi_vlogvar_wait_assign_value(t77, t76, 0, 0, 1, 0LL);
    xsi_set_current_line(41, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 1768);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(43, ng0);
    t2 = (t0 + 1928);
    t3 = (t2 + 56U);
    t5 = *((char **)t3);
    t6 = ((char*)((ng4)));
    memset(t4, 0, 8);
    xsi_vlog_unsigned_add(t4, 32, t5, 32, t6, 32);
    t12 = (t0 + 1928);
    xsi_vlogvar_wait_assign_value(t12, t4, 0, 0, 32, 0LL);
    goto LAB77;

}


extern void work_m_00000000000889424405_0408886691_init()
{
	static char *pe[] = {(void *)Always_12_0};
	xsi_register_didat("work_m_00000000000889424405_0408886691", "isim/top_isim_beh.exe.sim/work/m_00000000000889424405_0408886691.didat");
	xsi_register_executes(pe);
}
