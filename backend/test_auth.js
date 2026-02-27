const jwt = require('jsonwebtoken');
require('dotenv').config({ path: './src/.env' });
console.log("SECRET:", process.env.JWT_SECRET);
const token = jwt.sign({email:'test@example.com', id:'123'}, 'supersecret123');
try {
  jwt.verify(token, process.env.JWT_SECRET);
  console.log("VERIFIED");
} catch(e) {
  console.log("ERROR:", e.message);
}
