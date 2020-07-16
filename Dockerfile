FROM golang:alpine as builder

# Creating the directory where we will put all our files (nginx, php, golang)
RUN mkdir /app

ADD . /app/

WORKDIR /app

# Compiling the golang app
RUN go build -o undostres .
# -----------------
FROM nginx:alpine

#Installing the packages to run php
RUN apk add php7 php7-fpm

# Creating a dummy dir just to put the golang binary
RUN mkdir /golang

# Copying the binary undostres to previous dir
COPY --from=builder /app/undostres /golang/

# Adding the nginx conf and php test file
COPY --from=builder /app/test.php /usr/share/nginx/html/.
COPY --from=builder /app/default.conf /etc/nginx/conf.d/.

#This will be the script that initializes the golang app, php-fpm7 and nginx 
COPY --from=builder /app/wrapper_script.sh wrapper_script.sh

#For documentation only
EXPOSE 8082 8083

CMD ./wrapper_script.sh
