FROM node:10-alpine

WORKDIR /app

ADD package* /app/
RUN npm install

COPY . /app/
RUN npm run build

EXPOSE 5000
CMD ["npm","start"]
