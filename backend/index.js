import http from 'http';
import PG from 'pg';

const database_user = process.env.POSTGRES_USER;
const database_password = process.env.POSTGRES_PASSWORD;
const database_host = 'database';
const database_port = 5432;
const database_name = process.env.POSTGRES_DB;
const database_server_port = 8080;

const client = new PG.Client(
  `postgres://${database_user}:${database_password}@${database_host}:${database_port}/${database_name}`
);

let successfulConnection = false;

http.createServer(async (req, res) => {
  console.log(`Request: ${req.url}`);

  if (req.url === "/api") {
    client.connect()
      .then(() => { successfulConnection = true })
      .catch(err => console.error('Database not connected -', err.stack));

    res.setHeader("Content-Type", "application/json");
    res.writeHead(200);

    let result;

    try {
      result = (await client.query("SELECT * FROM users")).rows[0];
    } catch (error) {
      console.error(error)
    }

    const data = {
      database: successfulConnection,
      userAdmin: result?.role === "admin"
    }

    res.end(JSON.stringify(data));
  } else {
    res.writeHead(503);
    res.end("Internal Server Error");
  }

}).listen(database_server_port, () => {
  console.log(`Server is listening on port ${database_server_port}`);
});
