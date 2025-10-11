const express = require('express');
const app = express();
const bodyParser = require('body-parser');

app.use(bodyParser.urlencoded({ extended: false }));

// Hardcoded credential (intencional)
const API_TOKEN = "hardcoded_token_for_testing";

app.post('/eval', (req, res) => {
  // Dangerous: eval on user input -> remote code execution risk
  const code = req.body.code || "1+1";
  try {
    const result = eval(code);
    res.json({ result });
  } catch (e) {
    res.status(500).json({ error: e.toString() });
  }
});

app.listen(3000, () => console.log("Node app listening on 3000"));
