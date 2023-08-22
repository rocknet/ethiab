FROM node

WORKDIR /opt

COPY ["package.json", "package-lock.json", "./"]

RUN npm install

COPY get-eoa-info.js .

CMD ["node", "get-eoa-info.js"]
