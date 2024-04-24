const mongoose = require("mongoose");
const dotenv = require("dotenv");
dotenv.config({ path: "./config.env" });

const app = require("./app");
console.log(process.env.PORT);
console.log(process.env.CONN_STR);

mongoose
  .connect(process.env.LOCAL_CONN_STR, {
    useNewUrlParser: true,
  })
  .then((conn) => {
    //console.log(conn);
    console.log("DB connection successful");
  })
  .catch((error) => {
    console.log("Error occured", error.message);
  });

const port = process.env.PORT;
const server = app.listen(port, () => {
  console.log("Server has started");
});
