import jwt from "jsonwebtoken";
import User, {UserType} from "../models/user";
import express from "express";

const admin = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
    try {
        const token = req.header("x-auth-token");
        if (!token)
            return res.status(401).json({msg: "No auth token, access denied"});

        const verified = jwt.verify(token, "passwordKey") as jwt.JwtPayload;
        if (!verified)
            return res
                .status(401)
                .json({msg: "Token verification failed, authorization denied."});
        const user = await User.findById(verified.id);
        if (!user) return res.status(401).json({msg: "User does not exist"});
        if (user.type !== UserType.ADMIN) {
            return res.status(401).json({msg: "You are not an admin!"});
        }
        req.user = verified.id;
        req.token = token;
        next();
    } catch (err: any) {
        res.status(500).json({error: err.message});
    }
};
export default admin;
