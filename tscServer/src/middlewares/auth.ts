import jwt from "jsonwebtoken";
import express from "express";


export const passkey= process.env.passwordKey || "passwordKey";
const auth = async (req:express.Request, res:express.Response, next:express.NextFunction) => {
  try {
    const token = req.header("x-auth-token");
    if (!token)
      return res.status(401).json({ msg: "No auth token, access denied" });
    const verified = jwt.verify(token,passkey) as jwt.JwtPayload;
    if (!verified)
      return res
        .status(401)
        .json({ msg: "Token verification failed, authorization denied." });
    req.type = verified.type;
    req.user = verified.id;
    req.token = token;
    next();
  } catch (err:any) {
    res.status(500).json({ error: err.message });
  }
};

export default auth;
