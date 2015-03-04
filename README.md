# Fi

## Significado

[Fi](http://zelda.wikia.com/wiki/Fi), originalmente pronunciado "_fai_", es un personaje
ficticio que aparece en el afamado juego de Nintendo: _[Legend of Zelda: Skyward Sword](http://zelda.com/skywardsword/)_.

Es una humanoide, la representación de la _diosa espada_ que guía a _[Link](http://zelda.wikia.com/wiki/Link)_;
entre sus habilidades se encuentra el análisis de la zona, así como de los enemigos a los
que el héroe se enfrenta. Es una base de datos de conocimiento que permite agilizar
el avance durante la aventura, o en términos aún mas simplificados:
Una computadora en un contexto épico/medieval.

## Motivación

Proveer a los desarrolladores (independientemente de su experiencia) una plataforma de
desarrollo web ágil, consistente, fácil de usar, fácil de leer y sumamente flexible.
(_cof, cof, hackeable, cof_).

## Requerimientos

### [Node](http://http://nodejs.org/) v0.10+
_**Nota**: Sin importar la versión que los manejadores de paquetes instalen, en las

* **Mac**: Instalación vía [HomeBrew](http://brew.sh)
* **Linux**: Instalación vía `apt-get`, `yum`, `pacman`, o equivalente.
* **Windows**: A pesar de que es posible instalar Node en Windows, y que el framework está
  preparado para un funcionamiento multiplataforma, las pruebas que se han realizado han
  arrojado comportamientos inesperados, por lo que recomendamos usar un SO basado en
  [POSIX](http://en.wikipedia.org/wiki/POSIX).

### [CoffeeScript](http://coffeescript.org) v1.9+

	# Instalar como módulo global
	npm install -g coffee-script

### [Nodemon](https://github.com/remy/nodemon) (opcional)

Esta herramienta permite el monitoreo del código fuente, permitiendo reiniciar el servidor
automáticamente cada vez que se detecte un cambio en los archivos especificados

	# Instalar como módulo global
	npm install -g nodemon

### [BrowserSync](https://github.com/BrowserSync/browser-sync) (opcional)

Esta herramienta permite el monitoreo del código fuente, permitiendo reiniciar el servidor
automáticamente cada vez que se detecte un cambio en los archivos especificados

	# Instalar como módulo global
	npm install -g browser-sync


## Instalación

A menos que hayas usado antes Fi, es recomendado que inicialices tu proyecto usando nuestro
**[generador](https://github.com/gikmx/generator-fi)** de **[Yeoman](http://yeoman.io)**

	# Instalar yeoman y generator-fi globalmente
	npm install -g yo generator-fi

	# Crear la carpeta en donde deseas resida tu proyecto
	mkdir FiApp && cd $_

	# Recuéstate y deja que yeoman haga la magia por ti.
	yo fi

	# Una vez finalizado, simplemente ejecuta nodemon
	npm run watch

	# Y si deseas evitar recargar tu navegador, en otra ventana de terminal puedes
	# ejecutar browser-sync
	npm run sync

## Documentación

Pendiente por generar
