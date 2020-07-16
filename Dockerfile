FROM golang:alpine as builder
RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN go build -o undostres .

FROM nginx:alpine
RUN mkdir /golang
COPY --from=builder /app/undostres /golang/
EXPOSE 8080
RUN apk add php7 php7-fpm
COPY --from=builder /app/test.php /usr/share/nginx/html/.
COPY --from=builder /app/default.conf /etc/nginx/conf.d/.
COPY --from=builder /app/wrapper_script.sh wrapper_script.sh
CMD ./wrapper_script.sh
