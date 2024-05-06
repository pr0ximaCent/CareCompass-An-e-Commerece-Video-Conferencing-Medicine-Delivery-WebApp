import mongoose from "mongoose";
import {userSchema} from "./user";

export const appointmentSchema = new mongoose.Schema({
    lastActive: {
        type: Date,
        required: true,
        default: Date.now(),
    },
    createdAt: {
        type: Date,
        required: true,
        default: Date.now(),
    },
    shouldGetDoneWithin: {
        type: Date,
        required: true,
    },
    isDone: {
        type: Boolean,
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // This should match the model name of your User model
        required: true,
    },
    doctorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor', // This should match the model name of your Doctor model
        required: true,
    },
});

const Appointment = mongoose.model("Appointment", appointmentSchema);
export default Appointment