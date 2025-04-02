## API paran renderizar y almacenar planes de pago

La herramienta de proyectos inmobiliarios se apoya en los endpoints de este API para
eficientizar el renderizado y gestión de los planes de pago en PDF.

### Corre localmente

```r
library(plumber)

pr("payment-plan/plumber.R") %>% pr_run(port = 8000)
```
El  API será accesible en la siguiente dirección `http://127.0.0.1:8000`. Aquí un
ejemplo de como correr el `report` endpoint.

```bash
curl -o ~/Desktop/test2.pdf "http://127.0.0.1:8000/report?firebase_id=-OJxjuK1wA1NET3WvzwW"
```

Ejemplo en Digital Ocean:

```bash
 curl -o ~/Desktop/tests.pdf "https://octopus-app-axggo.ondigitalocean.app/report?firebase_id=-OJxjuK1wA1NET3WvzwW"
```

### Docker

Hay un `Dockerfile` con las configuraciones y dependencias del sistema.

Para compilar la imagen:

```bash
docker build -t payment-plan-api ./
```

Para correr el contenedor:

```bash
docker run -p 8000:8000 -v ./.Renviron:/app/.Renviron payment-plan-api
```

### Variables

Agregar las siguients variables en tu .Renviron: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`, `FIREBASE_DB_URL`, `AWS_S3_BUCKE`T