Inventory Tracker (Django + Flutter)

Proyecto tipo gestor de inventario personal que permite:

Gestión de productos en inventario.
Agregar productos mediante compra inteligente.
Merge automático si el producto ya existe.
Historial de compras.
Autenticación con JWT.

El usuario puede:

Login / Registro.
Ver inventario.
Agregar productos.
Editar y eliminar productos.
Comprar productos.
Ver historial de compras.

---

Tecnologías utilizadas

Backend

Python
Django
Django REST Framework
SimpleJWT (JWT Authentication)
SQLite
Django CORS Headers

Frontend

Flutter
Riverpod (State Management)
Dio (HTTP Client)
Material 3 UI
SharedPreferences (tokens JWT)

---

Backend (Django API)

Creado usando PyCharm.

1️. Crear proyecto

django-admin startproject config .

Crear apps:

python manage.py startapp usuarios
python manage.py startapp inventario

---

2️. Crear entorno virtual

python -m venv .venv

Activar:

.venv\Scripts\activate

---

3️. Instalar dependencias usadas

pip install django
pip install djangorestframework
pip install djangorestframework-simplejwt
pip install django-cors-headers

---

4️. Migraciones

python manage.py makemigrations
python manage.py migrate

---

5️. Crear superusuario

python manage.py createsuperuser

---

6️. Ejecutar backend

IMPORTANTE (para conexión con Flutter):

python manage.py runserver 0.0.0.0:8000

API disponible en:

http://127.0.0.1:8000/

---

Frontend (Flutter)

Proyecto creado con Visual Studio Code.

Para usar emuladores Android fue necesario instalar:

Android Studio (Android Emulator)

---

Instalar dependencias

flutter pub get

---

Ver dispositivos disponibles

flutter devices

---

Ejecutar app

flutter run

Ejecutar en navegador:

flutter run -d Chrome

---

Configuración especial

Editar archivo:

lib/core/constants.dart

Opciones:

Android Emulator:

http://10.0.2.2:8000

Navegador:

http://localhost:8000

Celular físico:

http://IP_DE_TU_PC:8000

---

Funciones

Login JWT.
Registro de usuario.
Inventario CRUD.
Compra inteligente con validación previa.
Merge automático de productos duplicados.
Historial de compras.

---

Notas importantes

Backend debe estar activo antes de iniciar Flutter.
JWT tokens se guardan en SharedPreferences.
Interceptor Dio agrega Authorization header automáticamente.
CORS habilitado para desarrollo.
