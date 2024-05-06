import mongoose from "mongoose";
import { userSchema } from "./user";
import { messageSchema } from "./message";

const chatSchema = new mongoose.Schema({
    on_video_call: {
        type: Boolean,
        required: true,
        default: false
    },
    start_consultation_request_by_doctor: {
        type: Boolean,
        required: true,
        default: false
    },
    user_one: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    user_two: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    messages: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Message"
    }],
    updated_at: {
        type: Date,
        default: Date.now
    }
});

const Chat = mongoose.model("Chat", chatSchema);
export default Chat;