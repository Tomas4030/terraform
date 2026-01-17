FROM nginx:1.27

# Copy HTML
COPY ./html /usr/share/nginx/html
# Copy nginx conf
COPY ./conf.d/ /etc/nginx/conf.d/

# Nginx deve escutar porta 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
