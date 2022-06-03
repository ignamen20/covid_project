# covid_project
### Autor: Ignacio Mendia

## Objetivos y motivación del proyecto
El objetivo del proyecto es procesar datos para producir una visualización útil para entender algunas facetas de cómo el covid afectó a los distintos países.
Elegí concentrarme en cuáles habían sido los países más afectados en cuanto a cantidad de muertes y casos absolutos, y por otro lado analizar muertes y casos en relación a la población del país.

La motivación detrás del proyecto es poner en práctica algunas de las herramientas de procesamiento y visualización de datos.
En particular usé SQL para la carga de datos y queries, que después convertí en views para la parte de data viz, para lo cual elegí tableau que era una herramienta nueva para mí.


## Paso a paso
Pasando al proyecto en sí, lo que hice fue descargar datos de la sección sobre el [covid de ourworldindata](https://ourworldindata.org/covid-deaths) separadas en dos tables, una sobre las estadísticas generales de cada país, y otra con los datos sobre vacunación. Los dos archivos .csv fueron cargados a mi servidor de mysql.

### Cargado de datos a servidor MySQL
El primer inconveniente que tuve fue que el import wizard del programa de interacción con la base de datos, MySQL Workbench, no permitía importar los .csv, por lo que tuve que escribir las queries para crear y popular las 2 tables.
Las mismas se encuentran en el archivo ["Loading Data.sql"](https://github.com/ignamen20/covid_project/blob/main/Loading%20data.sql)


### Creando queries y views
Una vez que tenía los datos ya cargados, fui ejecutando queries, experimentando con los comandos y agregando complejidad, en el archivo ["Queries and views.sql"](https://github.com/ignamen20/covid_project/blob/main/Queries%20and%20views.sql) La primera query por ejemplo fue la que generó los datos sobre número de infectados y fallecidos globalmente sumado.
Como **highlights** del script tenemos:

- una primera *join* en la línea 111
- en la línea 123 una query con join, en la cual tengo el problema de hacer una calculation sobre una calculation lo cual me lleva a tener que solucionarlo
  - usando *Common Table Expressions* (línea 136)
  - usando una *Temporary Table* (línea 152)
