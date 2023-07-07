DATABASE bd

MAIN

##-------------------  Parametros  ----------------------------##

##---------------- Ficheros de Salida ----------------##
DEFINE arch_sal     CHAR(200)

DEFINE men_err      CHAR(200)

##---------------  Variables de Trabajo  ----------------------##
DEFINE  c_usuario    LIKE CLIPERCL.LOGUSUAR
DEFINE  c_nieprof    LIKE CLIPERCL.NIEPROF
DEFINE  i_dniprof    LIKE CLIPERCL.DNIPROF
DEFINE  c_nifprof    LIKE CLIPERCL.NIFPROF

DEFINE  i_cnopro     LIKE CTIDEP.CNOPRO
DEFINE  i_subcnopro  LIKE CTIDEP.SUBCNOPRO
DEFINE  i_prvcol     LIKE CTCOLE.PRVCOL
DEFINE  i_seccol     LIKE CTCOLE.SECCOL
DEFINE  i_dcseccol   LIKE CTCOLE.DCSECCOL

DEFINE  indError SMALLINT

##-------------------------------------------------------------##

SET ISOLATION TO DIRTY READ
WHENEVER ERROR CONTINUE

CALL inicio_4gl()

##----------------- Inicialización del listado  -------------##
LET arch_sal  = aq_nombre_fichero("usbcoleg",0)
START REPORT uslcoleg TO arch_sal

let indError = 0

## Busco todos los registros dados de alta en clipercl
DECLARE c_datos CURSOR FOR 
 SELECT UNIQUE LOGUSUAR, NIEPROF, DNIPROF, NIFPROF
   FROM CLIPERCL , USERS
  WHERE LOGUSUAR IS NOT NULL
    AND USERS.USUARIO = CLIPERCL.LOGUSUAR
    AND USERS.CLAVEIPF IS NOT NULL

FOREACH c_datos INTO c_usuario, c_nieprof, i_dniprof, c_nifprof

   ## Reviso la especialidad
   IF c_nieprof IS NULL THEN
      DECLARE c_datos1 CURSOR FOR 
       SELECT CNOPRO, SUBCNOPRO
        FROM CTIDEP
       WHERE LNIFPRO IS NULL
         AND NIFPRO = i_dniprof 
         AND CNOPRO IS NOT NULL

      FOREACH c_datos1 INTO i_cnopro, i_subcnopro
         SELECT USUARIO
           FROM USESPMED
          WHERE USUARIO = c_usuario
            AND CNOPRO = i_cnopro
            AND SUBCNOPRO = i_subcnopro

         IF sqlca.sqlcode = 100 THEN
            INSERT INTO USESPMED
              (USUARIO, DNIPROF, NIFPROF, CNOPRO, SUBCNOPRO)
             VALUES
              (c_usuario, i_dniprof, c_nifprof, i_cnopro, i_subcnopro)

            IF sqlca.sqlcode < 0 THEN
               LET men_err   = "ERROR : ", sqlca.sqlcode USING "-<<<<&",
                   "Usuario: ", c_usuario, 
                   ". DNI: ", i_dniprof,
                   ". Especialidad: ", i_cnopro, "/", i_subcnopro 

               OUTPUT TO REPORT uslcoleg (men_err)
               LET indError = 1
               EXIT FOREACH
            END IF
         END IF
      END FOREACH
   ELSE
      DECLARE c_datos2 CURSOR FOR 
       SELECT CNOPRO, SUBCNOPRO
        FROM CTIDEP
       WHERE LNIFPRO = c_nieprof
         AND NIFPRO = i_dniprof 
         AND CNOPRO IS NOT NULL

      FOREACH c_datos2 INTO i_cnopro, i_subcnopro
         SELECT USUARIO
           FROM USESPMED
          WHERE USUARIO = c_usuario
            AND CNOPRO = i_cnopro
            AND SUBCNOPRO = i_subcnopro

         IF sqlca.sqlcode = 100 THEN
            INSERT INTO USESPMED
              (USUARIO, NIEPROF, DNIPROF, NIFPROF, CNOPRO, SUBCNOPRO)
             VALUES
              (c_usuario, c_nieprof, i_dniprof, c_nifprof, i_cnopro, i_subcnopro)

            IF sqlca.sqlcode < 0 THEN
               LET men_err   = "ERROR : ", sqlca.sqlcode USING "-<<<<&",
                   "Usuario: ", c_usuario, 
                   ". DNI: ", i_dniprof,
                   ". Especialidad: ", i_cnopro, "/", i_subcnopro 

               OUTPUT TO REPORT uslcoleg (men_err)
               LET indError = 1
               EXIT FOREACH
            END IF

         END IF
      END FOREACH
   END IF


   ## Reviso el numero de colegiado
   IF c_nieprof IS NULL THEN
      DECLARE c_datos1b CURSOR FOR 
       SELECT PRVCOL, SECCOL, DCSECCOL
        FROM CTCOLE
       WHERE LNIFPRO IS NULL
         AND NIFPRO = i_dniprof 

      FOREACH c_datos1b INTO i_prvcol, i_seccol, i_dcseccol
         SELECT USUARIO
           FROM USCOLEG
          WHERE PRVCOL = i_prvcol
            AND SECCOL = i_seccol
            AND DCSECCOL = i_dcseccol

         IF sqlca.sqlcode = 100 THEN
            INSERT INTO USCOLEG
              (USUARIO, DNIPROF, NIFPROF, PRVCOL, SECCOL, DCSECCOL)
             VALUES
              (c_usuario, i_dniprof, c_nifprof, i_prvcol, i_seccol, i_dcseccol)

            IF sqlca.sqlcode < 0 THEN
               LET men_err   = "ERROR : ", sqlca.sqlcode USING "-<<<<&",
                   "Usuario: ", c_usuario, 
                   ". DNI: ", i_dniprof,
                   ". Colegiado: ", i_prvcol, "/", i_seccol, "/", i_dcseccol

               OUTPUT TO REPORT uslcoleg (men_err)
               LET indError = 1
               EXIT FOREACH
            END IF

         END IF
      END FOREACH
   ELSE
      DECLARE c_datos2b CURSOR FOR 
       SELECT PRVCOL, SECCOL, DCSECCOL
        FROM CTCOLE
       WHERE LNIFPRO = c_nieprof
         AND NIFPRO = i_dniprof 

      FOREACH c_datos2b INTO i_prvcol, i_seccol, i_dcseccol

         SELECT USUARIO
           FROM USCOLEG
          WHERE PRVCOL = i_prvcol
            AND SECCOL = i_seccol
            AND DCSECCOL = i_dcseccol

         IF sqlca.sqlcode = 100 THEN
            INSERT INTO USCOLEG
              (USUARIO, NIEPROF, DNIPROF, NIFPROF, PRVCOL, SECCOL, DCSECCOL)
             VALUES
              (c_usuario, c_nieprof, i_dniprof, c_nifprof, i_prvcol, i_seccol, i_dcseccol)

            IF sqlca.sqlcode < 0 THEN
               LET men_err   = "ERROR : ", sqlca.sqlcode USING "-<<<<&",
                   "Usuario: ", c_usuario, 
                   ". DNI: ", i_dniprof,
                   ". Colegiado: ", i_prvcol, "/", i_seccol, "/", i_dcseccol

               OUTPUT TO REPORT uslcoleg (men_err)
               LET indError = 1
               EXIT FOREACH
            END IF

         END IF
      END FOREACH
   END IF

   IF  indError = 1 THEN
       EXIT FOREACH
   END IF
END FOREACH  # Fin del cursor   


##------------------ Se finaliza el listado -------------------##
FINISH REPORT uslcoleg
CALL finaliza_4gl()

END MAIN

##-[------------------------------------------------------------]-##
##-[-----           REPORT                                 -----]-##
##-[------------------------------------------------------------]-##
REPORT uslcoleg(c_mensaje)

DEFINE c_mensaje       CHAR(100)

OUTPUT
   TOP    MARGIN 0
   LEFT   MARGIN 0
   RIGHT  MARGIN 0
   BOTTOM MARGIN 0
   PAGE   LENGTH 1

FORMAT

ON EVERY ROW

  PRINT c_mensaje CLIPPED

END REPORT
