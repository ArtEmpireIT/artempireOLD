FROM node:12

WORKDIR /usr/src/app

EXPOSE 9000
RUN mkdir -p /uploads
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list && apt-get update && apt-get install -y imagemagick ghostscript

COPY package*.json /usr/src/app/
RUN npm ci 

COPY . /usr/src/app
CMD ["npm", "start"]
