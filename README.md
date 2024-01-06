# power-image-template

_Este repositorio contiene el script en bash que importa automáticamente la imagen de una instancia virtual Power en IBM Cloud y la exporta en un IBM Cloud Object Storage. Para la implementación es necesario tener ya creado y configurado tanto un Workspace como una instancia virtual Power VS precargada y configurada._

## Contenido 📋
1. [Crear una IBM Cloud API key](#crear-una-ibm-cloud-api-key)
2. [Crear un bucket en IBM Cloud Object Storage](#crear-un-bucket-en-ibm-cloud-object-storage)
3. [Crear una credencial de servicio en IBM Cloud Object Storage](#crear-una-credencial-de-servicio-en-ibm-cloud-object-storage)
4. [Clonar el repositorio](#clonar-el-respositorio)
5. [Subir la imagen a IBM Cloud Container Registry](#subir-la-imagen-a-ibm-cloud-container-registry)
6. [Crear el Batch Job en Code Engine](#crear-el-batch-job-en-code-engine)

## Procedimiento

### Crear una IBM Cloud API key

Ingresar en IAM para crear una API-KEY que permita la conexión a ibmcloud mediante la identificación del usuario.

- Ingresar a Manage -> Access IAM -> Api keys -> My IBM Cloud API keys -> Create.

<img width="920" alt="ApiKey" src="images/power-image-template-1.jpg">

- Generamos la llave y la copiamos para más adelante.

<img width="920" alt="Apikey2" src="images/power-image-template-2.jpg">

### Crear un bucket en IBM Cloud Object Storage

- Ingresar al catálogo de IBM Cloud y buscar IBM Cloud Object Storage.
- Seleccionar los siguientes parámetros:
    - Infraestructura: IBM Cloud 
    - Plan: Lite si no existe una instancia gratuita o Standard de ya ocupar una.
    - Nombre de servicio: Ingresar un nombre a elección.
    - Grupo de recurso: Ingresar el grupo de recurso a utilizar, de no colocar se creará en Default.
    - Tags (opcional).

<img width="920" alt="COS" src="images/power-image-template-4.jpg">

- Ingresar a la instancia de Object Storage y selecciona Crear Bucket.

<img width="920" alt="COS" src="images/power-image-template-5.jpg">

- Seleccionar los siguientes parámetros:
    - Nombre de bucket: Ingresa un nombre único a nivel global para tu bucket.
    - Resiliencia: Regional.
    - Locación: Dallas (us-south).
    - Clase de almacenamiento: Smart tier.
    - Versionamiento de objetos: Deshabilitado.
    - Configuración avanzada: Agregar regla de vencimiento (el objeto se eliminará automáticamente después de 30 días).
        - Tipo: Simple.
        - Regla de vencimiento: Habilitada.
        - Vencimiento de versión: 30 días.
        - Seleccionar Guardar.

<img width="920" alt="COS" src="images/power-image-template-6.jpg">

Seleccionar Crear Bucket

### Crear una credencial de servicio en IBM Cloud Object Storage

- Seleccionar la opción de Credencial de Servicio y seleccionar Nueva Credencial.

<img width="920" alt="COS" src="images/power-image-template-7.jpg">

- Ingresar los siguientes parámetros:
    - Nombre.
    - Rol: Escritura.
    - ID de servicio: Autogenerado.
    - Incluir credencial HMAC: Habilitar.

- Seleccionar Agregar.

Al esperar que termine de crear, desplegar las credenciales y copiar las `cos_hmac_keys`, tanto el `access_key_id` como el `secret_access_key` y las copiamos para más adelante.

<img width="920" alt="COS" src="images/power-image-template-8.jpg">

### Clonar el respositorio

- Ingresar al repositorio principal y seleccionar la opción ´Code´ -> HTTPS y copiar el URL.

<img width="920" alt="RepoClone" src="images/power-image-template-3.jpg">

- Abrir una terminal y cambiar el directorio de trabajo actual a la ubicación en donde quieres clonar el directorio.

- Escribir `git clone` y pegar el URL del repositorio.

```
git clone https://github.com/JoCGM09/power-image-template.git
```
### Subir la imagen a IBM Cloud Container Registry

- Instalar la [CLI de IBM Cloud](https://cloud.ibm.com/docs/containers?topic=containers-cli-install)
- Instalar la [CLI de docker](https://docs.docker.com/engine/install/)
- Instalar el plugin de IBM Cloud Container Registry

```
ibmcloud plugin install container-registry -r 'IBM Cloud'
```

- Ingresar a la cuenta de IBM Cloud desde la CLI, luego ingresar el código otorgado en el buscador.

```
ibmcloud login --sso
```

- Verificar que estemos apuntando a la región correcta de IBM Cloud Container Registry

```
ibmcloud cr region-set us-south
```

- Seleccionar un nombre para el namespace y crearlo usando el comando:

```
ibmcloud cr namespace-add <nombre_para_el_namespace>
```
- Loguea el deamon local de Docker en el IBM Cloud container Registry:

```
ibmcloud cr login
```

- Posicionado sobre el directorio del proyecto clonado de Github donde está el Dockerfile, crear la imagen:

```
docker build -t us.icr.io/<nombre_del_namespace>/<nombre_para_el_repositorio>:latest .
```

- Sube la imagen creada:

```
docker push us.icr.io/<nombre_del_namespace>/<nombre_para_el_repositorio>:latest
```
- Verifica que tu imagen se haya subido al repositorio privado:

```
ibmcloud cr image-list
```

### Crear el Batch Job en Code Engine

- Buscar el servicio de Code Engine y crear un nuevo proyecto.

<img width="920" alt="RepoClone" src="images/power-image-template-9.jpg">

- Ingresar los siguientes parámetros:
    - Ubicación: Dallas (us-south)
    - Nombre del proyecto
    - Grupo de recursos

Luego seleccionar Crear.

- Seleccionar la opción de Jobs para crear un nuevo ejecutable.

Aquí seleccionamos la siguiente información:
    - Nombre del Job
    - Código: Código fuente
    - Imagen de referencia: Pegar el URL del repositorio de Github.
    - Seleccionar `Especificar detalles del build`
Ahora seleccionar los siguientes parámetros:
- Source: 
    - URL del repositorio: URL del repositorio de Github
    - Acceso al código del repositorio: None
    - Nombre de la rama: master
    - Directorio de referencia: <dejar en blanco>

Seleccionamos `Siguiente`.

<img width="920" alt="RepoClone" src="images/power-image-template-10.jpg">

- Strategy:
    - Dockerfile: Dockerfile
    - Timeout: 10m
    - Build resources: M (1 vCPU / 4GB)

<img width="920" alt="RepoClone" src="images/power-image-template-11.jpg">    

- Output:
Aparecerá la opción de crear un nuevo Registry Secret, ingresar los siguientes parámetros:
    - Nombre del secreto
    - Contenido del secreto: IBM Container Registry
    - Ubicación: Dallas (private.us.icr.io)
    - IAM API Key: Ingresar el API Key del usuario
    - Email (opcional)

Ahora seleccionar Crear.

<img width="920" alt="RepoClone" src="images/power-image-template-12.jpg">  

> [!NOTE]  
> Si estás usando un IBM Container Registry de otra cuenta, ingresar una API Key generada en esa otra cuenta.

Ahora revisar en Output los siguientes parámetros.
    - Registry server: private.us.icr.io
    - Registry Sectret: <Seleccionar el nombre del secreto>
    - Verificar que los datos se completen automáticamente y estén correctos tanto el Namespace como el Repositorio.

<img width="920" alt="RepoClone" src="images/power-image-template-13.jpg">  

> [!IMPORTANT]  
> Al crear el Batch Job en Code Engine deberás crear las siguientes variables de entorno usando los mismos nombres en el apartado de `variables de entorno (opcional)`:

- `IBM_CLOUD_API_KEY`: API Key de IBM Cloud
- `IBM_POWER_WORKSPACE_NAME`: Nombre del Workspace de Power VS
- `IBM_POWER_INSTANCE_NAME`: Nombre de la instancia a capturar
- `COS_ACCESS_KEY`: Access_key_id de las credenciales cos_hmac_keys de las Credenciales de Servicio de IBM COS
- `COS_SECRET_KEY`: Secret_access_key de las credenciales cos_hmac_keys de las Credenciales de Servicio de IBM COS

Finalmente seleccionar Crear y al cargar la imagen, seleccionar Submit Job:

<img width="920" alt="RepoClone" src="images/power-image-template-14.jpg">  
