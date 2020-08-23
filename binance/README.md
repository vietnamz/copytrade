# Prime generator Application

## Ubuntu 18.04 
This is a golang structure was cloned from https://github.com/golang-standards/project-layout. It is important to have well structured at the beginning of the project, otherwise we will  suffer from painful like improper import, etc... 
With Go 1.14 [`Go Modules`](https://github.com/golang/go/wiki/Modules) are finally ready for production. We should use unless we have a special reason for that.
# My current environment is
* MacOS Catalina 10.15.1
* Clang version 11.0.0
* Go 1.14.6
* Docker version 19.03.2, build 6a30dfc
* docker-compose version 1.24.1, build 4667896b


Originally, Build a simple CLI application. Consider using cobra [`Cobra`](https://github.com/spf13/cobra) a very powerful library to build cli.
secondly, Logging is critical part. Should pay attention first to make sure, We can track our mistake during development. Consider using [`Logrus`](https://github.com/sirupsen/logrus)

#### Code structure and design is based on [`Go moby`] project (https://github.com/moby/moby)


## How to build locally
```bash
go build github.com/vietnamz/prime-generator/cmd/prime_cal
```
## How to build from local.

```bash
./scripts/build.sh
```

## How to build dependencies on clean ubuntu 18.04 linux machine.

```bash
./scripts/build-dependencies.sh
```
## How to run.
```bash
./bin/prime
```

## How to use docker
at the root folder run below command. docker and docker compose are required.
```bash
docker-compose up -d --build
```

### Make sure port 5000 and 5001 are available for use.

### access into UI via http://localhost:5000
### testing api via http://localhost:5001/prime?number=56

## AWS Host

http://52.12.23.4/