FROM nginx:alpine

# Copiar archivos estáticos
COPY public/ /usr/share/nginx/html/

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Comando de inicio
CMD ["nginx", "-g", "daemon off;"] 