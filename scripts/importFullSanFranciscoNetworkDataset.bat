:: This file should run in an empty directory, all the way through.

:: DTA Anyway code location
set DTA_CODE_DIR=Y:\lmz\dta

:: let PYTHON know where to find it
set PYTHONPATH=%DTA_CODE_DIR%

::
:: 1) create the network from the Cube network
::
python %DTA_CODE_DIR%\scripts\createSFNetworkFromCubeNetwork.py -n sf_nodes.shp -l sf_links.shp notused notused Y:\dta\SanFrancisco\2010\SanFranciscoSubArea_2010.net Y:\dta\SanFrancisco\2010\turnspm.pen Q:\GIS\Road\SFCLINES\AttachToCube\stclines.shp
:: primary output: Dynameq files sf_{scen,base,advn,ctrl}.dqt
:: log     output: createSFNetworkFromCubeNetwork.{DEBUG,INFO}.log
:: debug   output: sf_{links,nodes}.shp
IF ERRORLEVEL 1 goto done

::
:: 2) attach the signal data to the DTA network
::
python %DTA_CODE_DIR%\scripts\importExcelSignals.py . sf Y:\dta\SanFrancisco\2010\excelSignalCards 15:30 18:30
:: primary output: Dynameq files sf_signals_{scen,base,advn,ctrl}.dqt
:: log     output: importExcelSignals.{DEBUG,INFO}.log
IF ERRORLEVEL 1 goto done

::
:: 3) attach the transit lines to the DTA network
:: 
python %DTA_CODE_DIR%\scripts\importTPPlusTransitRoutes.py . sf Y:\dta\SanFrancisco\2010\transit\sfmuni.lin Y:\dta\SanFrancisco\2010\transit\bus.lin
:: primary output: Dynameq files sf_ptrn.dqt
:: log     output: importTPPlusTransitRoutes.{DEBUG,INFO}.log
IF ERRORLEVEL 1 goto done

::
:: 4) create the demand
::
:createDemand
FOR %%V IN (Car_NoToll Truck_NoToll) DO (
  python %DTA_CODE_DIR%\scripts\importCubeDemand.py . sf Y:\dta\SanFrancisco\2010\demand\SanFranciscoSubArea_2010.csv %%V 15:30 18:30 00:15 demand_%%V.dat
  IF ERRORLEVEL 1 goto done
)
:: primary output: demand_{Car,Truck}_NoToll.dat
:: log     output: importCubeDemand.{DEBUG,INFO}.log

goto done
::
:: 5) import the counts into userdata files for Dynameq to read
::
:importCounts
set PYTHONPATH=%DTA_CODE_DIR%;Y:\lmz\CountDracula
python %DTA_CODE_DIR%\scripts\attachCountsFromCountDracula.py . sf
IF ERRORLEVEL 1 goto done

:done