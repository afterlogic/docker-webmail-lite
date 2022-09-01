afterlogic/docker-webmail-lite
==============================

[Afterlogic WebMail Lite](https://afterlogic.org/webmail-lite) image for Docker using Nginx, PHP-FPM 8.1, MySQL on Alpine Linux. Loosely based on [khromov/alpine-nginx-php8 package](https://github.com/khromov/alpine-nginx-php8).

Getting the image
-----------------

* Option 1 - from GitHub - recommended:

```
git clone https://github.com/afterlogic/docker-webmail-lite .
docker compose up
```

* Option 2 - from DockerHub:
	
```
curl https://raw.githubusercontent.com/afterlogic/docker-webmail-lite/master/docker-hub-compose.yml --output docker-compose.yml
docker compose up
```

Running Docker image
--------------------

Whether you get the image from DockerHub directly, or build it from GitHub repository, `docker compose up` will run the image, starting Nginx, PHP and MySQL. 

In case of GitHub repository, the latest version of WebMail Lite is downloaded from the website. DockerHub image is not guaranteed to contain the latest version of the product.

The installation will be available at http://localhost/ - if you wish to use another port instead of default 80, adjust `docker-compose.yml` file and edit the following section:

```
    ports:
      - "80:80"
```

Supplying "800:80" will make sure port 800 is used, and the installation will be available at http://localhost:800

Accessing admin interface
------------------------------

To configure WebMail Lite installation, log into admin interface using main installation URL and `/adminpanel` path.

Default credentials are **superadmin** login and empty password. 

**NB:** Be sure to press "Create/Update Tables" button in "Database settings" screen of admin interface.

Licensing Terms & Conditions
----------------------------

Content of this repository is available in terms of The MIT License (see `LICENSE.txt` file)
