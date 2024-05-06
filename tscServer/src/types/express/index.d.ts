import {Language, token, type, User} from "../custom";

// to make the file a module and avoid the TypeScript error
export {}

declare global {
    namespace Express {
        export interface Request {
            token?: token;
            user?: User;
            type?: type;
        }
    }
}