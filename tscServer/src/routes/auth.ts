import express from "express";
import User from "../models/user";
import bcryptjs from "bcryptjs";

const authRouter = express.Router();
import jwt from "jsonwebtoken";
import auth from "../middlewares/auth";

// SIGN UP
authRouter.post("/api/signup", async (req, res) => {
    try {
        const {name, email, password} = req.body;

        const existingUser = await User.findOne({email});
        if (existingUser) {
            return res
                .status(400)
                .json({msg: "User with same email already exists!"});
        }

        const hashedPassword = await bcryptjs.hash(password, 8);

        let user = new User({
            email,
            password: hashedPassword,
            name,
        });
        user = await user.save();
        res.json(user);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

// Sign In Route
// Exercise
authRouter.post("/api/signin", async (req, res) => {
    try {
        const {email, password} = req.body;

        const user = await User.findOne({email});
        // console.log(email, password, user);
        if (!user) {
            return res
                .status(400)
                .json({msg: "User with this email does not exist!"});
        }

        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({msg: "Incorrect password."});
        }

        const token = jwt.sign({id: user._id, type: user.type}, "passwordKey");
        // @ts-ignore
        res.json({token, ...user._doc});
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        const token = req.header("x-auth-token");
        if (!token) return res.json(false);
        const verified = jwt.verify(token, "passwordKey") as jwt.JwtPayload;
        if (!verified) return res.json(false);

        const user = await User.findById(verified.id);
        if (!user) return res.json(false);
        res.json(true);
    } catch (e: any) {
        res.status(500).json({error: e.message});
    }
});

// get user data
authRouter.get("/", auth, async (req: express.Request, res: express.Response) => {
    const user = await User.findById(req.user);
    res.json({...user, token: req.token});
});

export default authRouter;
