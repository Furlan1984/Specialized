CREATE OR REPLACE PACKAGE sbc_br_pkg_direct_debit AUTHID CURRENT_USER
IS
-- +-----------------------------------------------------------------+
-- |         Specialized Bicycle Components, Morgan Hill, CA         |
-- |                       All rights reserved                       |
-- +-----------------------------------------------------------------+
-- | FILENAME                                                        |
-- |   SBC_BR_PKG_DIRECT_DEBIT.sql                                   |
-- |                                                                 |
-- | DESCRIPTION                                                     |
-- |   Package to work with process of direct debit.                 |
-- |                                                                 |
-- | CREATED BY                                                      |
-- |   Nelson R. Furlan - 09/06/2015                                 |
-- |                                                                 |
-- | UPDATED BY                                                      |
-- |                                                                 |
-- +-----------------------------------------------------------------+
--
-------------------------------
-- Function to get account info
-------------------------------
   FUNCTION fnc_get_account_info( p_direct_debit  VARCHAR2
                                , p_customer_id  NUMBER
                                ) RETURN VARCHAR2;

END sbc_br_pkg_direct_debit;
/
CREATE OR REPLACE PACKAGE BODY sbc_br_pkg_direct_debit
IS
-- +-----------------------------------------------------------------+
-- |         Specialized Bicycle Components, Morgan Hill, CA         |
-- |                       All rights reserved                       |
-- +-----------------------------------------------------------------+
-- | FILENAME                                                        |
-- |   SBC_BR_PKG_DIRECT_DEBIT.sql                                   |
-- |                                                                 |
-- | DESCRIPTION                                                     |
-- |   Package to work with process of direct debit.                 |
-- |                                                                 |
-- | CREATED BY                                                      |
-- |   Nelson R. Furlan - 09/06/2015                                 |
-- |                                                                 |
-- | UPDATED BY                                                      |
-- |                                                                 |
-- +-----------------------------------------------------------------+
--
-------------------------------
-- Function to get account info
-------------------------------
   FUNCTION fnc_get_account_info( p_direct_debit VARCHAR2
                                , p_customer_id  NUMBER
                                ) RETURN VARCHAR2 AS

      l_content VARCHAR2(19);

    BEGIN

      -- inicialized variables
      l_content := NULL;

      IF p_direct_debit = 'Y' THEN
        BEGIN
          SELECT lpad(substr(acba.bank_branch_num,1,(instr(acba.bank_branch_num,'-')-1)), 5,'0')  || -- agencia de debito
                 substr(acba.bank_branch_num,(instr(acba.bank_branch_num,'-')+1),1)               || -- digito de debito
                 '00000'                                                                          || -- razao da conta corrente
                 lpad(substr(acba.bank_account_num,1,(instr(acba.bank_account_num,'-')-1)),7,'0') || -- conta corrente
                 substr(acba.bank_account_num,(instr(acba.bank_account_num,'-')+1),1)                -- digito corrente
            INTO l_content
            FROM ar_customer_bank_accounts_v acba
           WHERE acba.customer_id  = p_customer_id
             AND acba.primary_flag = 'Y'
             AND trunc(sysdate) BETWEEN acba.start_date AND NVL(acba.end_date,trunc(SYSDATE));
        EXCEPTION 
        WHEN OTHERS THEN
         l_content := '00000 000000000000 ';
        END;
      ELSE
       l_content := '00000 000000000000 ';
      END IF;
     
      RETURN (l_content);

    END fnc_get_account_info;

END sbc_br_pkg_direct_debit;
/
