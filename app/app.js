const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({ message: "Hello World" });
});

app.get('/health', (req, res) => {
  res.status(200).send("OK");
});

if (require.main === module) {
  app.listen(3000, () => console.log("Server running on port 3000"));
}

module.exports = app;