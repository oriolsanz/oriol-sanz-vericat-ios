# Pantalla principal
## Una search bar para buscar por artista
Al principio había pensado en hacer la barra de búsqueda dinámica, cosa que se puede ver en el primer commit del desarrollo donde se implementa el shouldChangeCharactersIn para ello.
Después de varias pruebas en el siguiente commit desestimo la idea ya que eso llevaba a "cuelgues" a la hora de escribir un texto a buscar ya que se hacían constantes llamadas a la api y para ello añado un botón para buscar.

### Extra
Genero también una clase Utils estática con un método para descargar las imagenes y otros dos para controlar los spinners de carga de la aplicación.
Añado una imagen predeterminada para los perfiles sin imagen.

## Tabla con los resultados de la búsqueda
Para este apartado creé una celda personalizada con una imagen y un texto para usar en la tabla que se iba a rellenar.

# Vista de detalle
## Área con información del artista
Para este apartado decido añadir como información el nombre del artista, la imagen de perfil, los generos musicales asociados y la cantidad de seguidores. 
Decido que la información del artista se va a pasar vía "Segue" desde la pantalla principal.
Después de eso me percato de que no estoy recogiendo correctamente los followers y lo arreglo (defecto 1).
Añado también como detalles del artista su id interno (necesario para la llamada de recibir los álbumes).

## Área de colección con los ábumes
Añado el Álbum como modelo con id, nombre, imagen, total de temas y fecha de lanzamiento.
Implemento la CollectionView y añado la llamada a la API.
Añado botón de atrás, muestro el modal del detalle a pantalla completa y arreglo un glitch del componente de la colección.

## Drag&Drop
Por último añado el drag&drop con un longPress sobre el ítem a mover.

### Extra
El componente de la CollectionView es el que más problemas me ha traído, no he podido solucionarlos todos por falta de tiempo. Desde que hay veces que se muestran los ítems con el tamaño incorrecto cuando se accede a la vista (se soluciona haciendo scroll) hasta que el Drag&Drop colgaba la aplicación (solucionado posteriormente).

# Vista de detalle - Filtro
## Fecha de publicación
Aquí lo que hago es añadir 2 labels (Desde - Hasta) que al clicarlos aparece un DatePicker para elegir una fecha, cuando están los dos rellenados puedes clicar el botón de filtrar para aplicar el filtro sobre la lista.

### Extra
No se permiten fechas posteriores al día actual ni poner una fecha inicial posterior a la final.
Aprovecho para formatear un poco el código y dejarlo más presentable.

# Gestión de errores
## Persistencia
Para este apartado decido usar el FileManager para guardar los datos directamente en el disco.
Hago los modelos "Codables" y creo una clase FileManager para guardar los datos.
Añado un control de conexión para cargar los datos desde disco o hacer llamada a la API.

## Control de errores
Añado alertas de error con una cabecera estándard fija ("Ha ocurrido un error") y varios tipos de errores:
- Se requieren 3 carácteres para la búsqueda de artista
- Error inesperado
- Se deben rellenar las 2 fechas para filtrar
- No se puede buscar una fecha inicial posterior a la final
- No hay álbumes para filtrar

# Pantalla principal - Opcionales
## Parallax
Se añade el efecto Parallax cuando se hace scroll

## Compartir en RRSS
Implemento un longClick en las celdas para compartir la imagen. Esto no he podido probarlo con el simulador pero está implementada la acción.

# Vista de detalle - Filtro - Opcionales
## Otro criterio
Añado una caja de texto para, ahora sí, filtrar por título a medida que se va escribiendo.

# Gestión de errores
## Botón reintentar
Únicamente en la llamada para recibir el token desde la API añado un botón que reintentar la llamada, si te saltas este popup la aplicación va a funcionar en modo offline y va a trabajar con los últimos artistas buscados y solo estarán disponibles los álbumes de los artistas que previamente habías visto.

# Mejorar Drag&Drop
## Thumbnail
En este momento le dedico tiempo a mejorar el Drag & Drop ya que con pocos álbumes funcionaba sin problemas pero con muchos se colgaba el dispositivo. Para ello genero los Thumbnails de las imágenes de forma mucho más eficiente, cosa que hace que sea todo más fluido.

# Vista de detalle - Opcionales
## Pinch in / out
En este punto no podía controlar muy bien la cantidad exacta de ítems que se mostraban por pantalla, por lo que la forma de implementar esto es dejar 3 niveles de zoom para mostrar más o menos ítems, no he tenido suficiente tiempo para dejarlo pulido.

# Paginación REST
En este punto añado la paginación de los servicios de búsqueda de artista y de álbumes ya que no la estaba usando.
Pongo un máximo de 100 ítems ya que para más de 2000 llegaba a colgarse.
Añado en Utils un método para extraer el parámetro que me interesa (offset) para realizar la rellamada.

# Mejora gráfica
Por último le he hecho un lavado de cara a la aplicación para que se vea algo mejor.

# Ejecución
Para todo el código he usado únicamente métodos nativos sin ningún tipo de framework, solo se han utilizado las librerías Foundation y UIKit.

# TODO
Me gustaría haber mejorado la colección de álbumes, sobretodo el pinch in / out y el glitch de que a veces se ven los ítems muy pequeños.
No he implementado ningún Unit Testing ni UI Testing.
Me hubiera gustado que la aplicación hubiera sido un pelín más bonita estéticamente.


[URL del Trello usado durante el desarrollo](https://trello.com/b/FuKOpKsz)