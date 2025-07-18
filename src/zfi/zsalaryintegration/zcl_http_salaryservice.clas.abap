class ZCL_HTTP_SALARYSERVICE definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .


   CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
   CLASS-METHODS saveData
    IMPORTING
      VALUE(request)  TYPE REF TO if_web_http_request
    RETURNING
      VALUE(message)  TYPE STRING .


protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_SALARYSERVICE IMPLEMENTATION.


  METHOD getCID.
    TRY.
        cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.


  Method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
  CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        response->set_text( saveData( request ) ).
    ENDCASE.


  ENDMETHOD.


  METHOD saveData.
    TYPES: BEGIN OF ty_json_structure,
             ProfitCenter  TYPE prctr,
             CostCenter    TYPE kostl,
             GLAccount     TYPE saknr,
             PayMonth      TYPE c LENGTH 3,
             BusinessPlace TYPE werks_d,
             Branch        TYPE C LENGTH 40,
             CompanyCode   TYPE bukrs,
             Debit         TYPE p LENGTH 15 DECIMALS 2,
             Credit        TYPE p LENGTH 15 DECIMALS 2,

           END OF ty_json_structure.

    DATA tt_json_structure TYPE TABLE OF ty_json_structure WITH EMPTY KEY.

    TRY.

        xco_cp_json=>data->from_string( request->get_text( ) )->write_to( REF #( tt_json_structure ) ).

        LOOP AT tt_json_structure INTO DATA(wa).

         IF wa-ProfitCenter    IS INITIAL OR
           wa-CostCenter      IS INITIAL OR
           wa-GLAccount       IS INITIAL OR
           wa-PayMonth        IS INITIAL OR
           wa-BusinessPlace   IS INITIAL OR
           wa-Branch          IS INITIAL OR
           wa-CompanyCode     IS INITIAL.

          message = |All fields (ProfitCenter, CostCenter, GLAccount, PayMonth, BusinessPlace, Branch, CompanyCode) must be filled.|.
          RETURN.
        ENDIF.

          DATA(cid) = getcid( ).
          MODIFY ENTITIES OF ZR_SALARYINT
         ENTITY ZRSALARYINT
         CREATE FIELDS (
              ProfitCenter
              CostCenter
              GLAccount
              PayMonth
              BusinessPlace
              Branch
              CompanyCode
              PostingDate
              AccountingDocument
              Debit
              Credit
              Currency
            )
            WITH VALUE #( (
              %cid                        = cid
              ProfitCenter                = wa-ProfitCenter
              CostCenter                  = wa-CostCenter
              GLAccount                   = wa-GLAccount
              PayMonth                    = wa-PayMonth
              BusinessPlace               = wa-BusinessPlace
              Branch                      = wa-branch
              CompanyCode                 = wa-CompanyCode
              Debit                       = wa-Debit
              Credit                      = wa-Credit
              Currency                    = 'INR'
            ) )

          REPORTED DATA(ls_po_reported)
          FAILED   DATA(ls_po_failed)
          MAPPED   DATA(ls_po_mapped).

          COMMIT ENTITIES BEGIN
             RESPONSE OF ZR_SALARYINT
             FAILED DATA(ls_save_failed)
             REPORTED DATA(ls_save_reported).

          IF ls_po_failed IS NOT INITIAL OR ls_save_failed IS NOT INITIAL.
            message = 'Failed to save data'.
          ELSE.
            message = 'Data saved successfully'.
          ENDIF.

          COMMIT ENTITIES END.
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_root).
        message = |General Error: { lx_root->get_text( ) }|.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
