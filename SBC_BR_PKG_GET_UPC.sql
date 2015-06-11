CREATE OR REPLACE PACKAGE APPS.SBC_BR_PKG_GET_UPC AUTHID CURRENT_USER IS

  -- +-----------------------------------------------------------------+
  -- |         Specialized Bicycle Components, Morgan Hill, CA         |
  -- |                       All rights reserved                       |
  -- +-----------------------------------------------------------------+
  -- | FILENAME                                                        |
  -- |   sbc_br_pkg_get_upc.sql                                        |
  -- |                                                                 |
  -- | DESCRIPTION                                                     |
  -- |   Package to get UPC value for Integrated Receinving            |
  -- |                                                                 |
  -- | CREATED BY                                                      |
  -- |   Nelson Furlan - 28/07/2014                                    |
  -- |                                                                 |
  -- | UPDATED BY                                                      |
  -- |                                                                 |
  -- +-----------------------------------------------------------------+

  PROCEDURE upc_value_p ( errbuf             OUT VARCHAR2
                        , retcode            OUT NUMBER
                        , p_organization_id   IN VARCHAR2
                        , p_operation_id      IN NUMBER
                        );

END SBC_BR_PKG_GET_UPC;
/
CREATE OR REPLACE PACKAGE BODY APPS.SBC_BR_PKG_GET_UPC IS

  -- +-----------------------------------------------------------------+
  -- |         Specialized Bicycle Components, Morgan Hill, CA         |
  -- |                       All rights reserved                       |
  -- +-----------------------------------------------------------------+
  -- | FILENAME                                                        |
  -- |   sbc_br_pkg_get_upc.sql                                        |
  -- |                                                                 |
  -- | DESCRIPTION                                                     |
  -- |   Package to get UPC value for Integrated Receinving            |
  -- |                                                                 |
  -- | CREATED BY                                                      |
  -- |   Nelson Furlan - 28/07/2014                                    |
  -- |                                                                 |
  -- | UPDATED BY                                                      |
  -- |                                                                 |
  -- +-----------------------------------------------------------------+

  PROCEDURE upc_value_p ( errbuf           OUT VARCHAR2
                        , retcode          OUT NUMBER
                        , p_organization_id IN VARCHAR2
                        , p_operation_id    IN NUMBER
                        ) AS

    -- Main variables
    l_errbuf    VARCHAR2(2000);
    l_retcode   NUMBER;
    l_error_msg VARCHAR2(1000);

  BEGIN

    -- Initialize main variables
    l_errbuf    := NULL;
    l_retcode   := 0;
    l_error_msg := NULL;

    BEGIN

     fnd_file.put_line(fnd_file.log   , 'p_organization_id : '||p_organization_id);
     fnd_file.put_line(fnd_file.log   , 'p_operation_id    : '||p_operation_id);
     fnd_file.put_line(fnd_file.output, 'ITEM;NCM;UPC;DESCRIPTION');

     ----------------------------------
     -- Return cross reference for item
     ----------------------------------
     FOR r_item IN ( SELECT mcr.inv_item_concat_segs item
                          , msi.global_attribute1    ncm
                          , mcr.cross_reference      upc
                          , msi.description          descri
                       FROM mtl_cross_references_v mcr
                          , rec_invoices           ri
                          , rec_invoice_lines      ril
                          , mtl_system_items_b     msi
                      WHERE ri.invoice_id         = ril.invoice_id
                        AND ri.organization_id    = msi.organization_id
                        AND mcr.inventory_item_id = msi.inventory_item_id
                        AND mcr.inventory_item_id = ril.item_id
                        AND ri.operation_id       = p_operation_id
                        AND ri.organization_id    = p_organization_id
        ) LOOP

           fnd_file.put_line(fnd_file.output, r_item.item ||';'|| r_item.ncm ||';'|| r_item.upc ||';'|| r_item.descri);

        END LOOP;

    EXCEPTION
      WHEN others THEN
       l_errbuf  := l_error_msg;
       l_retcode := 1;
    END;

    errbuf  := l_errbuf;
    retcode := l_retcode;

  END upc_value_p;

END sbc_br_pkg_get_upc;
/
