// const mongoose = require('mongoose');

// const connection = mongoose.createConnection(`mongodb://127.0.0.1:27017/newCreation`).on('open',()=>{
//   console.log("MongoDB Connected");
// }).on('error',()=>{
//     console.log("MongoDB Connection error");
// });
// module.exports = connection;

const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/newSc', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log("MongoDB connected");
}).catch((err) => {
  console.log("Error connecting to MongoDB: ", err);
});
