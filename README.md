# Hola Mundo Tomcat JEE

Este es un proyecto de ejemplo que demuestra una aplicación web Java EE básica que se conecta a una base de datos PostgreSQL y muestra un listado de usuarios utilizando Apache Tomcat 9.

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener instalado en tu sistema:

- **Java 8 o superior**
- **Apache Maven 3.6+**
- **Apache Tomcat 9**
- **PostgreSQL 12+**

## 🗄️ Configuración de la Base de Datos

### 1. Instalar PostgreSQL

```bash
# En Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# En CentOS/RHEL
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### 2. Crear la Base de Datos y Usuario

Accede al cliente de PostgreSQL:

```bash
sudo -u postgres psql
```

Ejecuta los siguientes comandos SQL:

```sql
-- Crear la base de datos
CREATE DATABASE testdb;

-- Crear el usuario
CREATE USER testuser WITH PASSWORD 'testpass';

-- Otorgar permisos
GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;

-- Salir de psql
\q
```

### 3. Cargar los Datos desde el Archivo Dump

El proyecto incluye un archivo SQL con la estructura y datos necesarios. Para cargar la base de datos:

```bash
# Restaurar la base de datos usando el archivo dump incluido
psql -h localhost -U testuser -d testdb -f samples/postgresql-conf/testdb_dump.sql
```

### 4. Verificar la Configuración

Verifica que la tabla y datos se cargaron correctamente:

```bash
# Conectarse a la base de datos
psql -h localhost -U testuser -d testdb

# Consultar los usuarios
SELECT * FROM usuarios;

# Salir
\q
```

## 🚀 Configuración de Apache Tomcat 9

### 1. Descargar e Instalar Tomcat

Descarga Apache Tomcat 9 desde el sitio oficial de Apache:

**Sitio web**: https://tomcat.apache.org/download-90.cgi

Busca la versión más reciente de Tomcat 9.0.x disponible (este proyecto fue probado con la versión 9.0.107).

```bash
# Ejemplo con versión específica - ajusta la versión según la más reciente disponible
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.107/bin/apache-tomcat-9.0.107.tar.gz

# Extraer
tar -xzf apache-tomcat-9.0.107.tar.gz

# Mover a /opt (opcional)
sudo mv apache-tomcat-9.0.107 /opt/tomcat9
```

### 2. Configurar el Driver PostgreSQL

**Importante**: El driver PostgreSQL está configurado con scope `provided` en el `pom.xml`, lo que significa que NO se incluye en el WAR generado. Esto es intencional para evitar conflictos de versiones y permitir que Tomcat gestione el driver.

Copia el driver JDBC de PostgreSQL al directorio `lib` de Tomcat:

```bash
# El driver se descarga automáticamente con Maven al repositorio local
# Buscar y copiar desde el repositorio Maven local (~/.m2/repository/)
cp ~/.m2/repository/org/postgresql/postgresql/42.6.2/postgresql-42.6.2.jar $TOMCAT_HOME/lib/

# Si no existe en el repositorio local, ejecutar primero para descargar las dependencias:
mvn dependency:resolve
```

**Verificación**: Después de copiar el driver, asegúrate de que esté presente:
```bash
ls -la $TOMCAT_HOME/lib/postgresql-42.6.2.jar
```

### 3. Configurar el Context de Tomcat

**Importante**: Examina el archivo `$TOMCAT_HOME/conf/context.xml` existente. Si ya tienes configuraciones previas, **NO reemplaces** el archivo completo. En su lugar, agrega únicamente el recurso para PostgreSQL dentro del elemento `<Context>`:

#### Opción A: Si es una instalación nueva de Tomcat
```bash
# Copiar el context.xml completo del proyecto
cp samples/tomcat-conf/context.xml $TOMCAT_HOME/conf/
```

#### Opción B: Si ya tienes configuraciones en context.xml
Abre el archivo `$TOMCAT_HOME/conf/context.xml` y agrega únicamente este recurso dentro de las etiquetas `<Context>`:

```xml
<Resource name="jdbc/PostgreSQLDS" auth="Container" type="javax.sql.DataSource"
       maxActive="100" maxIdle="30" maxWait="10000"
       username="testuser" password="testpass"
       driverClassName="org.postgresql.Driver"
       url="jdbc:postgresql://localhost:5432/testdb"/>
```

**Nota**: Modifica los parámetros `username`, `password`, `url` si tu configuración de base de datos es diferente.

### 4. Configurar Variables de Entorno

```bash
# Agregar al archivo ~/.bashrc o ~/.profile
export CATALINA_HOME=/opt/tomcat9
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64  # Ajustar según tu instalación de Java
```

Recarga las variables:

```bash
source ~/.bashrc
```

## 🔨 Compilación y Despliegue

### 1. Compilar el Proyecto

```bash
# Limpiar y compilar
mvn clean package

# Esto generará el archivo WAR en target/hola-mundo-tomcat-jee.war
```

### 2. Desplegar en Tomcat

```bash
# Copiar el WAR al directorio webapps de Tomcat
cp target/hola-mundo-tomcat-jee.war $TOMCAT_HOME/webapps/

# O renombrarlo para desplegar en la raíz
cp target/hola-mundo-tomcat-jee.war $TOMCAT_HOME/webapps/ROOT.war
```

### 3. Iniciar Tomcat

```bash
# Iniciar Tomcat
$TOMCAT_HOME/bin/startup.sh

# Verificar que se inició correctamente
tail -f $TOMCAT_HOME/logs/catalina.out
```

## 🌐 Acceso a la Aplicación

Una vez que Tomcat esté funcionando y la aplicación desplegada:

1. Abre tu navegador web
2. Accede a: `http://localhost:8080/hola-mundo-tomcat-jee/`
3. Deberías ver una página con el título "Hola Mundo" y una tabla con el listado de usuarios

## 🔧 Solución de Problemas

### Error de Conexión a la Base de Datos

1. **Verificar que PostgreSQL esté funcionando**:
   ```bash
   sudo systemctl status postgresql
   ```

2. **Verificar la conexión**:
   ```bash
   psql -h localhost -U testuser -d testdb
   ```

3. **Revisar los logs de Tomcat**:
   ```bash
   tail -f $TOMCAT_HOME/logs/catalina.out
   ```

### Error 404 - Página no encontrada

1. Verificar que el WAR se desplegó correctamente en `webapps/`
2. Revisar los logs de Tomcat para errores de despliegue
3. Verificar que la URL sea correcta: `http://localhost:8080/hola-mundo-tomcat-jee/`

### Error de Driver JDBC

1. Verificar que `postgresql-42.6.2.jar` esté en `$TOMCAT_HOME/lib/`
2. Reiniciar Tomcat después de copiar el driver
3. Verificar que la configuración del DataSource en `context.xml` sea correcta

## 📁 Estructura del Proyecto

```
hola-mundo-tomcat-jee/
├── pom.xml                     # Configuración de Maven
├── samples/
│   ├── postgresql-conf/        # Scripts SQL y configuración de BD
│   └── tomcat-conf/
│       └── context.xml         # Configuración del DataSource
├── src/
│   └── main/
│       ├── java/
│       │   └── py/com/sodep/academy/jee/
│       │       └── HolaMundo.java    # Clase Java de ejemplo
│       └── webapp/
│           ├── index.jsp       # Página principal con listado de usuarios
│           └── WEB-INF/
│               └── web.xml     # Configuración de la aplicación web
└── target/                     # Archivos compilados y WAR generado
```

## Configuración de la Base de Datos con Docker

Este proyecto utiliza PostgreSQL para la gestión de datos, ejecutándose en un contenedor Docker para simplificar la configuración y evitar instalaciones locales.

#### Requisitos

Asegúrate de tener [Docker Desktop](https://www.docker.com/es-es/products/docker-desktop/) (para Windows/macOS) o [Docker Engine](https://docs.docker.com/engine/install/) (para Linux) instalado en tu sistema.

#### Pasos para Iniciar PostgreSQL

1.  **Navega a la carpeta de configuración de PostgreSQL:**
    Abre tu terminal y ve al siguiente directorio dentro de tu proyecto:
    ```bash
    cd samples/postgresql-conf/
    ```

2.  **Inicia el contenedor de PostgreSQL:**
    Desde esta carpeta, ejecuta el siguiente comando:
    ```bash
    docker compose up -d
    ```
    Este comando descargará la imagen de PostgreSQL (si no la tienes), creará el contenedor `holamundo_postgres` y lo iniciará en segundo plano.

3.  **Verifica el estado del contenedor:**
    Para asegurarte de que PostgreSQL esté corriendo, usa:
    ```bash
    docker compose ps
    ```
    Deberías ver el servicio `db` (PostgreSQL) listado como `running`.

#### Detalles de Conexión para la Aplicación

Tu aplicación Java debe configurarse para conectarse a PostgreSQL usando los siguientes detalles:
* **Host:** `localhost`
* **Puerto:** `5432`
* **Nombre de la Base de Datos:** `holamundo_db` (¡Verifica tu `docker-compose.yml` por si lo cambiaste!)
* **Usuario:** `holamundo_user` (¡Verifica tu `docker-compose.yml`!)
* **Contraseña:** `una_contraseña_segura` (¡Verifica tu `docker-compose.yml`!)

#### Para Detener la Base de Datos

Cuando hayas terminado de trabajar, puedes detener el contenedor de PostgreSQL navegando a `samples/postgresql-conf/` y ejecutando:
```bash
docker compose down
```
_Probado con docker-compose en macOSX_

## 🤝 Contribuciones

Este es un proyecto educativo de Sodep Academy. Si encuentras algún problema o tienes sugerencias de mejora, no dudes en contribuir.

## 📄 Licencia

Este proyecto es parte del material educativo de Sodep Academy.
