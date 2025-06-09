FROM node:18
WORKDIR /usr/src/app
COPY app.js .
RUN npm init -y && npm install express
EXPOSE 3000
CMD ["node", "app.js"]