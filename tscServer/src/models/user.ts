import mongoose, {Types} from "mongoose";
import {productSchema} from "./product";

export enum UserType {
    USER,
    ADMIN,
    DOCTOR,
    SELLER
}

export const userSchema = new mongoose.Schema({
    name: {
        required: true,
        type: String,
        trim: true,
    },
    email: {
        required: true,
        type: String,
        trim: true,
        validate: {
            validator: (value: string) => {
                const re = /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
                return value.match(re);
            },
            message: "Please enter a valid email address",
        },
    },
    password: {
        required: true,
        type: String,
    },
    address: {
        type: String,
        default: "",
    },
    type: {
        type: typeof UserType,
        default: UserType.USER,
    },
    cart: [
        {
            product: productSchema,
            quantity: {
                type: Number,
                required: true,
            },
        },
    ],
    balance: {
        type: Number,
        default: 0,
    },
    doctor_data: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Doctor"
    }
});

const User = mongoose.model("User", userSchema);

export default User
