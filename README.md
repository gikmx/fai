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
[utilerías](#util) se detalla el procedimiento para usar una versión específica._

* **Mac**: Instalación vía [HomeBrew](http://brew.sh)
* **Linux**: Instalación vía `apt-get`, `yum`, `pacman`, o equivalente.
* **Windows**: A pesar de que es posible instalar Node en Windows, y que el framework está
  preparado para un funcionamiento multiplataforma, las pruebas que se han realizado han
  arrojado comportamientos inesperados, por lo que recomendamos usar un SO basado en
  [POSIX](http://en.wikipedia.org/wiki/POSIX).

### [CoffeeScript](http://coffeescript.org) v1.6+

	npm install -g coffee-script

## <a id="util"></a> Utilerías recomendas

### [N](https://github.com/visionmedia/n)

Manejo de versiones para Node, imprescindible cuando se desea trabajar con una versión
específica de la plataforma.

	# Instalar como módulo global
	npm install -g n

	# Descargar/cambiar-a versión estable
	n stable

	# Descargar/cambiar-a versión especifica
	n 0.8.22

	# Verificar cambio
	node -v

### [Nodemon](https://github.com/remy/nodemon)

Esta herramienta permite el monitoreo del código fuente, permitiendo reiniciar el servidor
automáticamente cada vez que se detecte un cambio en los archivos especificados

	# Instalar como módulo global
	npm install -g nodemon

	# Uso recomendado en una terminal por separado
	nodemon app.coffee --port=8080 --ext ".coffee|.styl|.jade"

### [Codo](https://github.com/netzpirat/codo)

Generador de documentación para CoffeeScript.

	# Instalar como módulo global
	npm install -g codo

	# Generar documentación para la aplicación (se creará una carpeta llamada "docs")
	codo --title "Título Aquí" --name "Nombre Aquí"

## Instalación

_**Nota:** Estos pasos asumen que se ha generado una configuración personalizada en SSH
para el acceso al repositiorio privado que contiene este framework._

	# Inicializar un repositorio vacío
	mkdir project && cd project && git init

	# Clonar fi como submódulo en el directorio "fi"
	git submodule add ssh://bitbucket.yapp/yapp/web.fi.git fi

	# Instalar las dependencias de fi
	cd fi && npm install && cd ..

	# Crear archivo principal e incluir fi, para que se genere estructura base
	echo "require './fi'\nfi.listen()" > app.coffee
	nodemon app.coffee --port=8080 --ext ".coffee|.styl|.jade"


## Autor

* [Héctor Menéndez](http://hectormenendez.com) ([@hectormenendez](http://twitter.com/#!/hectormenendez))
