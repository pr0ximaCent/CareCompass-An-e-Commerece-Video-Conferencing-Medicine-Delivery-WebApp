import mongoose from "mongoose";
import {userSchema} from "./user";

export enum MessageType {
    TEXT,
    VIDEOCALL,
    MEDICINE,
}

export const messageSchema = new mongoose.Schema({
    data: {
        type: String,
        required: true
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    receiver: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    type: {
        type: String,
        required: true
    },
    sentAt: {
        type: Date,
        required: true
    },
});

const Message = mongoose.model("Message", messageSchema);
export default Message