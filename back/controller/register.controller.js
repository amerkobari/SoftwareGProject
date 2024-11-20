const UserServices = require('../services/registerservices');

exports.register = async (req, res, next) => {
    try {

        const { email, password } = req.body;
        const successRes = await UserServices.registerUser(email, password);

        res.json({ status: true, success: 'User registered successfully' });


    } catch (err) {
        next(err);
    }


}