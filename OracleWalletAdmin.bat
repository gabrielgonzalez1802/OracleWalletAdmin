@echo off
TITLE Bienvenid@ %USERNAME% a Configuracion del oracle wallet
 menu
MODE con:cols=80 lines=40

:inicio
SET var=0
cls
echo ------------------------------------------------------------------------------
echo  %DATE% ^| %TIME%      *.*   Creado por Gabriel Gonzalez   *.*
echo ------------------------------------------------------------------------------
echo  1    Crear Wallet  
echo  2    Crear Credencial  
echo  3    Listar Credenciales  
echo  4    Borrar Credencial
echo  5    Comprobar conexion con el WALLET
echo  6    Salir
echo ------------------------------------------------------------------------------

REM pasos previos, debe configurar el TNS en el archivo tnsnames.ora y agregar las lineas: 
REM SQLNET.AUTHENTICATION_SERVICES = (TNS)
REM #ORACLE WALLET
REM WALLET_LOCATION=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY="C:\Users\gabri\OneDrive\Documentos\oracle-wallet")))
REM SQLNET.WALLET_OVERRIDE=TRUE
REM #SSL_CLIENT_AUTHENTICATION = FALSE
REM #FIN ORACLE WALLET
REM names.directory_path = TNSNAMES

IF EXIST %ORACLE_HOME% (
echo.
) ELSE (
    ECHO No existe la variable de entorno ORACLE_HOME asegurese de que tenga instalado la db de oracle 11g y configurado en la variable de entorno
pause
goto salir
)

SET /p var= ^> Seleccione una opcion [1-6]:

if "%var%"=="0" goto inicio
if "%var%"=="1" goto crearWallet
if "%var%"=="2" goto crearCredencial
if "%var%"=="3" goto listarCredenciales
if "%var%"=="4" goto borrarCredencial
if "%var%"=="5" goto testWallet
if "%var%"=="6" goto salir

::Mensaje de error, validación cuando se selecciona una opción fuera de rango
echo. El numero "%var%" no es una opcion valida, por favor intente de nuevo.
echo.
pause
echo.
goto:inicio

:crearWallet
    echo.
    echo. Has elegido la opcion No. 1
    color 0C
    echo.
	SET /p walletPath= ^> Ingresa la ubicacion en donde se creara el wallet: 
        IF EXIST %walletPath% (
           ECHO El directorio %walletPath% ya existe, ingrese otro directorio vacio para crear el wallet
           PAUSE
           goto:inicio
        ) ELSE (
          ECHO %walletPath% no existe, se procedera a crear el directorio
          MKDIR %walletPath%
          echo.
        )
        IF EXIST %walletPath% (
           ECHO el directorio %walletPath% fue creado correctamente
           echo.
	   echo. Creando Wallet...
	   REM Creando el Wallet
           call mkstore -wrl %walletPath% -create
          
             IF EXIST %walletPath%\ewallet.p12 (
               ECHO. Wallet creado correctamente en la ruta: %walletPath%
              ) ELSE (
                 ECHO. No se pudo crear el Wallet
              )
           pause
           ECHO. Retornando al menu inicial
           goto:inicio
        ) ELSE (
          ECHO No se pudo crear el directorio %walletPath% verifique que tenga los permisos suficientes o que la ruta este bien escrita
          echo.
          goto inicio
        )
    echo.
    pause
    goto:inicio

:crearCredencial
    echo.
    echo. Has elegido la opcion No. 2
    echo.
        color 08    
        SET /p walletPath= ^> Ingresa la ubicacion donde esta el wallet: 
        SET /p tnsAlias= ^> Ingresa el alias de TNS: 
        SET /p usuario= ^> Ingresa el usuario: 
        SET /p clave= ^> Ingresa la clave: 
        echo. Creando credencial en el wallet
        echo.
        REM Creando la credencial en el wallet
        call mkstore -wrl %walletPath% -createCredential %tnsAlias% %usuario% %clave%
        echo.
        pause
        goto inicio
    echo.
    pause
    goto:inicio

:listarCredenciales
    echo.
    echo. Has elegido la opcion No. 3
    echo.
        color 0A
        SET /p walletPath= ^> Ingresa la ubicacion donde esta el wallet: 
        echo.
        REM Lista de credenciales del wallet
        call mkstore -wrl %walletPath% -listCredential
    echo.
    pause
    goto:inicio

:borrarCredencial
    echo.
    echo. Has elegido la opcion No. 4
    echo.
        color 0C
        SET /p walletPath= ^> Ingresa la ubicacion donde esta el wallet: 
        SET /p tnsAlias= ^> Ingresa el Alias TNS que se borrara del wallet: 
        echo.
        REM Borrar credencial del wallet
        call mkstore -wrl %walletPath% -deleteCredential %tnsAlias%
    echo.
    pause
    goto:inicio

:testWallet
    echo.
    echo. Has elegido la opcion No. 5
    echo.
        color 0C
        ::Aquí van las líneas de comando de tu opción
        SET /p tnsTest=^> Ingresa el tns para comprobar la conexion con el wallet: 
        REM Conectar con SQLPLUS
        call sqlplus /@%tnsTest%
        echo.
        
    echo.
    pause
    goto:inicio

:salir
    @cls&exit