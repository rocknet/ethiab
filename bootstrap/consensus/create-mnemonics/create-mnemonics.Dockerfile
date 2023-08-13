FROM node

WORKDIR /opt

COPY ["package.json", "package-lock.json", "./"]

RUN npm install

COPY create-mnemonics.js .

CMD ["node", "create-mnemonics.js"]
