CLASS lhc_zi_qm_ret__slip_root DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_qm_ret__slip_root RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_qm_ret__slip_root RESULT result.

    METHODS preview FOR MODIFY
      IMPORTING keys FOR ACTION zi_qm_ret__slip_root~preview RESULT result.

ENDCLASS.

CLASS lhc_zi_qm_ret__slip_root IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD preview.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_QM_RET__SLIP_ROOT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_QM_RET__SLIP_ROOT IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
