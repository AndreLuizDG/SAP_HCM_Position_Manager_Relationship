REPORT z_algj_42.

TABLES: pa0001,     "INFOTIPO 0001
        hrp1001,    "RELACIONAMENTOS
        pa0003.     "INFOTIPO 0002 - PERSONAL DATA

DATA: t_1001 LIKE p1001 OCCURS 0 WITH HEADER LINE,
      t_1002 LIKE p1001 OCCURS 0 WITH HEADER LINE,
      t_1003 LIKE p1001 OCCURS 0 WITH HEADER LINE,
      t_1004 LIKE p1001 OCCURS 0 WITH HEADER LINE,
      t_0001 LIKE p0001 OCCURS 0 WITH HEADER LINE,
      t_0002 LIKE p0002 OCCURS 0 WITH HEADER LINE.

DATA: g_sobid1 LIKE p1001-objid,
      g_sobid2 LIKE p1001-objid,
      g_sobid3 LIKE p1001-objid,
      g_pernr  LIKE pa0002-pernr.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001. "TELA DE SELEÇÃO

PARAMETERS p_pernr LIKE pa0002-pernr.

SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.

* - RECUPERAR A POSIÇÃO PARA O CÓDIGO DE EMPREGADO DIGITADO NA TELA.

  CALL FUNCTION 'RH_READ_INFTY'
    EXPORTING
      plvar                = '01'
      otype                = 'P'        "PERSONAL
      objid                = p_pernr    "PERSONAL NUMBER
      infty                = '1001'     "LUGAR ONDE ESTA GRAVADO O RELACIONAMENTO DE EMPREGADO PARA POSIÇÃO
      subty                = 'B008'     "HOLDER - PERTENCE A UMA POSIÇÃO
    TABLES
      innnn                = t_1001
    EXCEPTIONS
      all_infty_with_subty = 1
      nothing_found        = 2
      no_objects           = 3
      wrong_condition      = 4
      wrong_parameters     = 5
      OTHERS               = 6.

  IF sy-subrc <> 0.
    MESSAGE 'NÃO EXISTEM POSIÇÕES PARA O EMPREGADO!' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  SORT t_1001 BY begda.

  READ TABLE t_1001 WITH KEY
                    objid = p_pernr "NUMERO EMPREGADO
                    otype = 'P'     "PERSON
                    rsign = 'B'     "HIERARQUIA " A - DE BAIXO PARA CIMA: NÍVEL MAIS BAIXO DA HIERARQUIA E SUBIR PARA OS NÍVEIS MAIS ALTOS. EXEMPLO FUNCIONÁRIO -> GERENTE -> DIRETOR
                                                " B - DE CIMA PARA BAIXO: NÍVEL MAIS ALTO DA HIERARQUIA E DESCE PARA OS NÍVEIS MAIS BAIXOS. EXEMPLO DIRETORES -> GERENTES -> FUNCIONÁRIOS
                    relat = '008'   "HOLDER - PERTENCE A UMA POSIÇÃO
                    sclas = 'S'.    "POSIÇÃO

  IF t_1001 IS NOT INITIAL.

    g_sobid1 = t_1001-sobid.  "ID DO OBJETO CAPTURADO NA PRIMEIRA PARTE

* - RECUPERAR A ORG UNIT DESTA POSIÇÃO RECUPERADA NO PASSO ANTERIOR.

    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        plvar = '01'
        otype = 'S'
        objid = g_sobid1
        infty = '1001'
        subty = 'A003'
      TABLES
        innnn = t_1002.

  ENDIF.   "IF T_1001 IS NOT INITIAL.


  SORT t_1002 BY begda.

  READ TABLE t_1002 WITH KEY
                  objid = g_sobid1 "ID DA POSIÇÃO
                  otype = 'S'      "TIPO S = POSIÇÃO
                  rsign = 'A'      "HIERARQUIA " A - DE BAIXO PARA CIMA: NÍVEL MAIS BAIXO DA HIERARQUIA E SUBIR PARA OS NÍVEIS MAIS ALTOS. EXEMPLO FUNCIONÁRIO -> GERENTE -> DIRETOR
                                               " B - DE CIMA PARA BAIXO: NÍVEL MAIS ALTO DA HIERARQUIA E DESCE PARA OS NÍVEIS MAIS BAIXOS. EXEMPLO DIRETORES -> GERENTES -> FUNCIONÁRIOS
                  relat = '003'    "BELONGS TO - PERTENCE A UMA POSIÇÃO
                  sclas = 'O'.     "ORG UNIT

  IF t_1002 IS NOT INITIAL.

    g_sobid2 = t_1002-sobid. "ID DA ORG UNIT

* - RECUPERAR A GERENCIA DA POSIÇÃO DA ORG UNIT OCUPADA PELO GERENTE

    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        plvar = '01'
        otype = 'O'        "ORG UNIT
        objid = g_sobid2   "ID DA ORG UNIT
        infty = '1001'
        subty = 'B012'     ""MANAGER / GERENCIA
      TABLES
        innnn = t_1003.

  ENDIF. "  IF T_1002 IS NOT INITIAL.

  SORT t_1003 BY objid.
  READ TABLE t_1003 WITH KEY
                objid = g_sobid2 "ID DA ORG UNIT
                otype = 'O'      "ORG UNIT
                rsign = 'B'      "HIERARQUIA " A - DE BAIXO PARA CIMA: NÍVEL MAIS BAIXO DA HIERARQUIA E SUBIR PARA OS NÍVEIS MAIS ALTOS. EXEMPLO FUNCIONÁRIO -> GERENTE -> DIRETOR
                                             " B - DE CIMA PARA BAIXO: NÍVEL MAIS ALTO DA HIERARQUIA E DESCE PARA OS NÍVEIS MAIS BAIXOS. EXEMPLO DIRETORES -> GERENTES -> FUNCIONÁRIOS
                relat = '012'    "MANAGER / GERENCIA
                sclas = 'S'.     "POSITION


  IF t_1003 IS NOT INITIAL.

* - NÚMERO DE EMPREGADO DO MANAGER

    g_sobid3 = t_1003-sobid.

    CALL FUNCTION 'RH_READ_INFTY'
      EXPORTING
        plvar = '01'
        otype = 'S'
        objid = g_sobid3
        infty = '1001'
        subty = 'A008'
      TABLES
        innnn = t_1004.

  ENDIF. "IF T_1003 IS NOT INITIAL.

  READ TABLE t_1004 WITH KEY
                objid = g_sobid3 "POSITION
                otype = 'S'      "POSITION
                rsign = 'A'      "HIERARQUIA " A - DE BAIXO PARA CIMA: NÍVEL MAIS BAIXO DA HIERARQUIA E SUBIR PARA OS NÍVEIS MAIS ALTOS. EXEMPLO FUNCIONÁRIO -> GERENTE -> DIRETOR
                                             " B - DE CIMA PARA BAIXO: NÍVEL MAIS ALTO DA HIERARQUIA E DESCE PARA OS NÍVEIS MAIS BAIXOS. EXEMPLO DIRETORES -> GERENTES -> FUNCIONÁRIOS
                relat = '008'    "HOLDER - POSSUI
                sclas = 'P'.     "PERSONAL

* - NESSE PONTO DO PROGRAMA JÁ TEMOS O CÓDIGO DO MANAGER DO FUNCIONARIO DIGITADO NA TELA DE SELEÇÃO

  IF t_1004 IS NOT INITIAL.

    g_pernr = t_1004-sobid+0(8).

* - RECUPERAR OS DADOS DO MANAGER VINDOS DO MÓDULO PA

    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr           = g_pernr
        infty           = '0002'
      TABLES
        infty_tab       = t_0002
      EXCEPTIONS
        infty_not_found = 1
        OTHERS          = 2.

    SORT t_0002 BY pernr begda.

    READ TABLE t_0002 INDEX 1.

    IF t_0002 IS NOT INITIAL.

      FORMAT COLOR 7.
      SKIP 2.

      WRITE: /1(101) sy-uline.

      WRITE:/1 sy-vline,
             2 'Código empregado maneger',
            30 sy-vline,
            31 'Primeiro nome do manager',
            60 sy-vline,
            61 'Sobrenome do maneger',
           101 sy-vline.

      FORMAT COLOR OFF.

      WRITE: /1(101) sy-uline.
      WRITE: /1 sy-vline,
              2 t_0002-pernr  COLOR 4,
              30 sy-vline,
              31 t_0002-vorna COLOR 4,
              60 sy-vline,
              61 t_0002-nachn COLOR 4,
             101 sy-vline.

      WRITE: /1(101) sy-uline.



    ENDIF.
  ENDIF.
