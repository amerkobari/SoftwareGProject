const UserModel = require("D:/SoftwareGradProject/SoftwareGProject/back/models/register.model");

class UserServices{
 
    static async registerUser(email,password){
        try{
                
                const createUser = new UserModel({email,password});
                return await createUser.save();
        }catch(err){
            throw err;
        }
    }
}

module.exports = UserServices;