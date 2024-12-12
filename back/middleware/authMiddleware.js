const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    // Get the token from the `Authorization` header
    const token = req.headers['authorization']?.split(' ')[1];
    // console.log("TOKEN PRINTED FROM MIDDLEWARE", token);

    if (!token) {
        return res.status(403).json({ message: 'No token provided.' });
    }

    // Verify the token
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Unauthorized: Invalid token.' });
        }

        // Attach the user ID and username from the token to the request
        req.userId = decoded.id;  // Assuming the token has 'id' as user identifier
        req.username = decoded.username;  // Assuming the token has 'username'
        req.email = decoded.email; // Assuming the token has 'email'

        next();
    });
};

module.exports = verifyToken;
