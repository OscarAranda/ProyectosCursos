const express = require("express");
const app = express();
const server = require("http").Server(app);
const socket = require("./socket");
const router = require("./network/routes");
const bodyParser = require("body-parser");

socket.connect(server);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
router(app);

server.listen(8080, () =>
  console.log("Server corriendo en https://localhost:8080")
);

const io = socket.socket.io;

io.on("connection", socket => {
  console.log(`Socket ${socket.id} connected.`);
  //disconect
  socket.on("disconnect", () => {
    console.log(`[Disconnected] ${socket.id} .`);
  });

  //mozo recibe
  socket.on("channel1", data => {
    console.log(data);
    //mozo envia
    io.emit("channel2", data);
  });
});
